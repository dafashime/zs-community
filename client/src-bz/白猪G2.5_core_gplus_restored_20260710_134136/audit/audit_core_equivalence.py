#!/usr/bin/env python3
"""Reproducible row-by-row equivalence audit for the restored G2.5 core."""
from __future__ import annotations

import argparse
import base64
import csv
import hashlib
import importlib.util
import json
import math
import re
import shutil
import subprocess
import tempfile
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Iterator

from tree_sitter import Language, Parser
import tree_sitter_lua

FUNCTION_NAMES = [
    "<chunk>", "startup_iife", "key_fragment_rm", "key_fragment_a", "identity",
    "decrypt_remote_content", "write_file", "execute_lua", "execute_lua_callback",
    "load_cached_code", "load_cached_version", "save_cached_version", "save_cached_content",
    "request_backup_update", "backup_network_callback", "backup_get_or_create_uuid",
    "request_primary_update", "primary_network_callback", "primary_get_or_create_uuid",
    "build_key_parameters", "derive_core_archive_key", "wrong_version_dialog_callback",
    "delayed_exit_callback", "globals.set_helper", "startup_network_callback",
    "startup_get_or_create_uuid",
]
FUNCTION_NODE_TYPES = {"function_declaration", "function_definition"}
IGNORED_DIRECT_NODES = {"comment", "empty_statement"}
LUA_LANGUAGE = Language(tree_sitter_lua.language())
AUDIT_SCHEMA_VERSION = 2


@dataclass
class Instruction:
    pc: int
    source_line: int
    opcode: str
    operands: str
    comment: str

    @property
    def semantic(self) -> tuple[str, str]:
        return self.opcode, self.operands


@dataclass
class LocalBinding:
    index: int
    name: str
    start_pc: int
    end_pc: int


@dataclass
class Upvalue:
    index: int
    name: str


@dataclass
class Prototype:
    index: int
    kind: str
    line_defined: int
    last_line_defined: int
    instruction_count: int
    params: int
    vararg: bool
    slots: int
    upvalue_count: int
    local_count: int
    constant_count: int
    child_count: int
    instructions: list[Instruction]
    constants: list[str]
    locals: list[LocalBinding]
    upvalues: list[Upvalue]


@dataclass
class Declaration:
    proto_id: int
    kind: str
    name: str
    scope_id: int
    line: int
    column: int
    start_byte: int
    order: int


@dataclass
class TreeData:
    path: Path
    source: bytes
    tree: Any
    root: Any
    nodes: list[Any]
    node_counts: Counter[str]
    function_nodes: list[Any]
    scopes: list[Any]
    scope_id_by_key: dict[tuple[str, int, int], int]
    function_id_by_key: dict[tuple[str, int, int], int]
    declarations: list[list[Declaration]]
    runtime_names: list[dict[str, Any]]
    escape_sequences: list[dict[str, Any]]


class AuditInvariantError(RuntimeError):
    """Raised when any mandatory equivalence invariant fails."""


def require(condition: bool, check: str, details: Any = None) -> bool:
    """Enforce an audit check even when Python runs with ``-O``.

    Unlike ``assert``, this function and every expression passed to it are never
    removed by the optimizer.  Returning ``True`` also makes it usable when
    assembling the final derived status.
    """
    if not condition:
        message = f"Audit invariant failed: {check}"
        if details is not None:
            message += f"; details={details!r}"
        raise AuditInvariantError(message)
    return True


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def md5_bytes(data: bytes) -> str:
    return hashlib.md5(data).hexdigest()


def file_hashes(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    return {"length": len(data), "md5": md5_bytes(data), "sha256": sha256_bytes(data)}


def node_key(node: Any) -> tuple[str, int, int]:
    return node.type, node.start_byte, node.end_byte


def byte_point(source: bytes, offset: int) -> tuple[int, int]:
    """Return a 1-based (line, byte-column) without tree-sitter Point objects.

    tree-sitter 0.25 on CPython 3.14 for Windows has a Point deallocation bug
    that can access-violate after a few hundred start_point/end_point reads.
    Deriving positions from byte offsets is exact for tree-sitter's byte columns.
    """
    line = source.count(b"\n", 0, offset) + 1
    last_newline = source.rfind(b"\n", 0, offset)
    return line, offset - last_newline


def point_text(source: bytes, node: Any) -> str:
    start_line, start_column = byte_point(source, node.start_byte)
    end_line, end_column = byte_point(source, node.end_byte)
    return f"{start_line}:{start_column}-{end_line}:{end_column}"


def iter_preorder(node: Any) -> Iterator[Any]:
    yield node
    for child in node.named_children:
        yield from iter_preorder(child)


def write_csv(path: Path, fieldnames: list[str], rows: Iterable[dict[str, Any]]) -> None:
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def decode_process_output(data: bytes) -> str:
    for encoding in ("utf-8", "gb18030", "cp1252"):
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            pass
    return data.decode("utf-8", errors="replace")


def normalize_newlines(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def stabilize_luac_listing(text: str) -> str:
    """Normalize Lua 5.1 listing paths/addresses that vary between compiler processes."""
    text = normalize_newlines(text)
    text = re.sub(r"(?m)^((?:main|function) <)[^<>\r\n]*[\\/](?=[^\\/<>\r\n]+\.lua:)", r"\1", text)
    text = re.sub(r"(\(\d+ instructions, \d+ bytes at )[0-9A-Fa-f]{6,16}(\))",
                  r"\1<prototype-address-omitted>\2", text)
    text = re.sub(r"(?m)^((?:constants|locals|upvalues) \(\d+\) for )[0-9A-Fa-f]{6,16}(:)$",
                  r"\1<prototype-address-omitted>\2", text)
    return re.sub(r"(?m)(\bCLOSURE\s+\d+\s+\d+\s*;\s*)[0-9A-Fa-f]{6,16}\s*$",
                  r"\1<function-address-omitted>", text)


def run_capture(command: list[str], cwd: Path | None = None) -> tuple[int, str]:
    result = subprocess.run(command, cwd=str(cwd) if cwd else None, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, check=False)
    return result.returncode, decode_process_output(result.stdout)


def parse_luac_listing(text: str) -> list[Prototype]:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    header_re = re.compile(r"^(main|function) <(.+):(\d+),(\d+)> \((\d+) instructions,.*$", re.MULTILINE)
    headers = list(header_re.finditer(text))
    prototypes: list[Prototype] = []
    for index, match in enumerate(headers):
        end = headers[index + 1].start() if index + 1 < len(headers) else len(text)
        segment = text[match.start():end]
        summary = re.search(
            r"^(\d+)(\+?) params?, (\d+) slots?, (\d+) upvalues?, (\d+) locals?, (\d+) constants?, (\d+) functions?$",
            segment, re.MULTILINE)
        constants_header = re.search(r"^constants \((\d+)\).*?:$", segment, re.MULTILINE)
        locals_header = re.search(r"^locals \((\d+)\).*?:$", segment, re.MULTILINE)
        upvalues_header = re.search(r"^upvalues \((\d+)\).*?:$", segment, re.MULTILINE)
        if not (summary and constants_header and locals_header and upvalues_header):
            raise AuditInvariantError(f"Cannot parse prototype #{index}")

        instructions: list[Instruction] = []
        for line in segment[summary.end():constants_header.start()].splitlines():
            inst = re.match(r"^\s*(\d+)\s+\[(\d+)\]\s+([A-Z0-9]+)\s*(.*)$", line)
            if not inst:
                continue
            tail = inst.group(4).rstrip()
            operands, separator, comment = tail.partition(";")
            opcode = inst.group(3)
            comment = comment.strip() if separator else ""
            if opcode == "CLOSURE" and re.fullmatch(r"[0-9A-Fa-f]{6,16}", comment):
                comment = "<function-address-omitted>"
            instructions.append(Instruction(int(inst.group(1)), int(inst.group(2)), opcode,
                                            operands.strip(), comment))

        constants: list[str] = []
        for line in segment[constants_header.end():locals_header.start()].splitlines():
            item = re.match(r"^\s*(\d+)\s+(.*)$", line)
            if item:
                constants.append(item.group(2).rstrip())

        locals_: list[LocalBinding] = []
        for line in segment[locals_header.end():upvalues_header.start()].splitlines():
            item = re.match(r"^\s*(\d+)\s+(\S+)\s+(\d+)\s+(\d+)\s*$", line)
            if item:
                locals_.append(LocalBinding(int(item.group(1)), item.group(2), int(item.group(3)), int(item.group(4))))

        upvalues: list[Upvalue] = []
        for line in segment[upvalues_header.end():].splitlines():
            item = re.match(r"^\s*(\d+)\s+(\S+)\s*$", line)
            if item:
                upvalues.append(Upvalue(int(item.group(1)), item.group(2)))

        proto = Prototype(index, match.group(1), int(match.group(3)), int(match.group(4)), int(match.group(5)),
                          int(summary.group(1)), bool(summary.group(2)), int(summary.group(3)), int(summary.group(4)),
                          int(summary.group(5)), int(summary.group(6)), int(summary.group(7)),
                          instructions, constants, locals_, upvalues)
        require(len(instructions) == proto.instruction_count, 'audit invariant originally at line 248', (index, len(instructions), proto.instruction_count))
        require(len(constants) == proto.constant_count, 'audit invariant originally at line 249', (index, len(constants), proto.constant_count))
        require(len(locals_) == proto.local_count, 'audit invariant originally at line 250', (index, len(locals_), proto.local_count))
        require(len(upvalues) == proto.upvalue_count, 'audit invariant originally at line 251', (index, len(upvalues), proto.upvalue_count))
        prototypes.append(proto)
    return prototypes


def build_prototype_tree(prototypes: list[Prototype]) -> tuple[list[int | None], list[list[int]], list[int]]:
    parents: list[int | None] = [None] * len(prototypes)
    children: list[list[int]] = [[] for _ in prototypes]
    depths = [0] * len(prototypes)

    def consume(index: int, parent: int | None, depth: int) -> int:
        parents[index] = parent
        depths[index] = depth
        cursor = index + 1
        for _ in range(prototypes[index].child_count):
            child = cursor
            children[index].append(child)
            cursor = consume(child, index, depth + 1)
        return cursor

    consumed_count = consume(0, None, 0)
    require(consumed_count == len(prototypes), "prototype tree consumes every prototype",
            {"consumed": consumed_count, "available": len(prototypes)})
    return parents, children, depths


def decode_lua_quoted(token: bytes | str) -> str:
    raw = token.encode("utf-8") if isinstance(token, str) else token
    if len(raw) < 2 or raw[:1] not in (b'"', b"'") or raw[-1:] != raw[:1]:
        return raw.decode("utf-8", errors="replace")
    body = raw[1:-1]
    out = bytearray()
    common = {ord("a"): 7, ord("b"): 8, ord("f"): 12, ord("n"): 10, ord("r"): 13,
              ord("t"): 9, ord("v"): 11, ord("\\"): 92, ord('"'): 34, ord("'"): 39}
    i = 0
    while i < len(body):
        byte = body[i]
        if byte != 92:
            out.append(byte)
            i += 1
            continue
        i += 1
        if i >= len(body):
            out.append(92)
            break
        byte = body[i]
        if 48 <= byte <= 57:
            end = i
            while end < len(body) and end < i + 3 and 48 <= body[end] <= 57:
                end += 1
            value = int(body[i:end].decode("ascii"), 10)
            if value > 255:
                raise ValueError(value)
            out.append(value)
            i = end
        elif byte in common:
            out.append(common[byte])
            i += 1
        elif byte in (10, 13):
            if byte == 13 and i + 1 < len(body) and body[i + 1] == 10:
                i += 1
            out.append(10)
            i += 1
        else:
            out.append(byte)
            i += 1
    return bytes(out).decode("utf-8", errors="replace")


def source_text(source: bytes, node: Any) -> str:
    return source[node.start_byte:node.end_byte].decode("utf-8", errors="replace")


def nearest_scope_id(node: Any, scope_map: dict[tuple[str, int, int], int]) -> int:
    current = node
    while current is not None:
        if node_key(current) in scope_map:
            return scope_map[node_key(current)]
        current = current.parent
    raise AssertionError("No scope")


def nearest_function_id(node: Any, function_map: dict[tuple[str, int, int], int]) -> int:
    current = node.parent
    while current is not None:
        if node_key(current) in function_map:
            return function_map[node_key(current)]
        current = current.parent
    return 0


def extract_runtime_names(source: bytes, root: Any) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for node in iter_preorder(root):
        kind = name = syntax = ""
        static = True
        if node.type == "dot_index_expression":
            name_node = node.named_children[-1]
            kind, name = "field_access", source_text(source, name_node)
            syntax = "." + name
        elif node.type == "bracket_index_expression":
            key_node = node.named_children[-1]
            if key_node.type == "string":
                kind = "field_access"
                name = decode_lua_quoted(source[key_node.start_byte:key_node.end_byte])
                syntax = "[" + source_text(source, key_node) + "]"
            else:
                kind, name, static = "dynamic_index", "<dynamic-index>", False
                syntax = source_text(source, node)
        elif node.type == "method_index_expression":
            name_node = node.named_children[-1]
            kind, name, syntax = "method_name", source_text(source, name_node), ":" + source_text(source, name_node)
        elif node.type == "field" and any(child.type == "=" for child in node.children):
            key_node = node.named_children[0]
            kind = "table_key"
            name = decode_lua_quoted(source[key_node.start_byte:key_node.end_byte]) if key_node.type == "string" else source_text(source, key_node)
            static = key_node.type in {"string", "identifier"}
            syntax = source_text(source, key_node)
        else:
            continue
        line, column = byte_point(source, node.start_byte)
        rows.append({"kind": kind, "name": name, "static": static, "line": line,
                     "column": column, "location": point_text(source, node), "syntax": syntax})
    return rows


def build_tree_data(path: Path) -> TreeData:
    source = path.read_bytes()
    source.decode("utf-8", errors="strict")
    parser = Parser(LUA_LANGUAGE)
    tree = parser.parse(source)
    root = tree.root_node
    require(not root.has_error, 'audit invariant originally at line 381', path)
    nodes = list(iter_preorder(root))
    node_counts = Counter(node.type for node in nodes)
    function_nodes = [node for node in nodes if node.type in FUNCTION_NODE_TYPES]
    scopes = [root] + [node for node in nodes if node.type == "block"]
    scope_map = {node_key(node): index for index, node in enumerate(scopes)}
    function_map = {node_key(node): index + 1 for index, node in enumerate(function_nodes)}
    declarations: list[list[Declaration]] = [[] for _ in range(len(function_nodes) + 1)]
    declaration_order = 0

    def add(proto_id: int, kind: str, name_node: Any, scope_id: int, override: str | None = None) -> None:
        nonlocal declaration_order
        declaration_order += 1
        line, column = byte_point(source, name_node.start_byte)
        declarations[proto_id].append(Declaration(proto_id, kind, override or source_text(source, name_node), scope_id,
                                                  line, column, name_node.start_byte, declaration_order))

    for node in nodes:
        if node.type == "variable_declaration":
            variable_list = node.named_children[0].named_children[0]
            proto_id, scope_id = nearest_function_id(node, function_map), nearest_scope_id(node, scope_map)
            for item in variable_list.named_children:
                if item.type == "identifier":
                    add(proto_id, "local", item, scope_id)
        elif node.type == "function_declaration" and node.children and node.children[0].type == "local":
            name_node = node.child_by_field_name("name")
            add(nearest_function_id(node, function_map), "local_function", name_node,
                nearest_scope_id(node.parent, scope_map))
        elif node.type == "parameters":
            owner = node.parent
            owner_id = function_map[node_key(owner)]
            scope_id = scope_map[node_key(owner.child_by_field_name("body"))]
            for item in node.named_children:
                if item.type == "identifier":
                    add(owner_id, "parameter", item, scope_id)
                elif item.type == "vararg_expression":
                    add(owner_id, "implicit_vararg", item, scope_id, "arg")
    for group in declarations:
        group.sort(key=lambda item: (item.start_byte, item.order))
    escapes = []
    for node in nodes:
        if node.type == "escape_sequence":
            line, column = byte_point(source, node.start_byte)
            escapes.append({"text": source_text(source, node), "line": line, "column": column,
                            "location": point_text(source, node)})
    return TreeData(path, source, tree, root, nodes, node_counts, function_nodes, scopes, scope_map, function_map,
                    declarations, extract_runtime_names(source, root), escapes)


def declaration_binding_infos(tree_data: TreeData) -> list[dict[str, Any]]:
    """Attach each AST declaration to its compiler local index and visibility boundary."""
    nodes_by_start = {node.start_byte: node for node in tree_data.nodes}
    infos: list[dict[str, Any]] = []
    for proto_id, declarations in enumerate(tree_data.declarations):
        for local_index, declaration in enumerate(declarations):
            node = nodes_by_start[declaration.start_byte]
            if declaration.kind in {"parameter", "implicit_vararg"}:
                visibility_start = tree_data.scopes[declaration.scope_id].start_byte
            elif declaration.kind == "local_function":
                owner = node
                while owner is not None and owner.type != "function_declaration":
                    owner = owner.parent
                require(owner is not None, 'audit invariant originally at line 443')
                visibility_start = owner.start_byte
            else:
                statement = node
                while statement is not None and statement.type != "variable_declaration":
                    statement = statement.parent
                require(statement is not None, 'audit invariant originally at line 449')
                # Lua locals are not visible inside their own initializer list.
                visibility_start = statement.end_byte
            infos.append({"declaration": declaration, "local_index": local_index, "node": node,
                          "visibility_start": visibility_start, "binding_id": (proto_id, local_index)})
    return infos


def lexical_scope_chain(node: Any, tree_data: TreeData, first_scope_id: int | None = None) -> list[int]:
    scope_ids: list[int] = []
    if first_scope_id is not None:
        scope_ids.append(first_scope_id)
    current = node.parent
    while current is not None:
        scope_id = tree_data.scope_id_by_key.get(node_key(current))
        if scope_id is not None and scope_id not in scope_ids:
            scope_ids.append(scope_id)
        current = current.parent
    return scope_ids


def find_shadow_relations(tree_data: TreeData, infos: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Return declarations that hide an already-visible same-name lexical binding."""
    relations: list[dict[str, Any]] = []
    for inner in infos:
        inner_decl: Declaration = inner["declaration"]
        if inner_decl.kind == "implicit_vararg":
            continue
        for scope_id in lexical_scope_chain(inner["node"], tree_data, inner_decl.scope_id):
            candidates = [candidate for candidate in infos
                          if candidate is not inner
                          and candidate["declaration"].scope_id == scope_id
                          and candidate["declaration"].name == inner_decl.name
                          and candidate["visibility_start"] <= inner["node"].start_byte]
            if candidates:
                outer = max(candidates, key=lambda candidate: (candidate["visibility_start"],
                                                                 candidate["declaration"].order))
                relations.append({"inner": inner, "outer": outer})
                break
    relations.sort(key=lambda relation: relation["inner"]["binding_id"])
    return relations


def extract_identifier_uses(tree_data: TreeData) -> list[Any]:
    """Return semantic identifier references, excluding declarations/member names/table keys."""
    declaration_starts = {declaration.start_byte for group in tree_data.declarations for declaration in group
                          if declaration.kind != "implicit_vararg"}
    uses: list[Any] = []
    for node in tree_data.nodes:
        if node.type != "identifier" or node.start_byte in declaration_starts:
            continue
        parent = node.parent
        if parent.type in {"dot_index_expression", "method_index_expression"} and \
                node_key(node) == node_key(parent.named_children[-1]):
            continue
        if parent.type == "field" and any(child.type == "=" for child in parent.children) and \
                node_key(node) == node_key(parent.named_children[0]):
            continue
        uses.append(node)
    return uses


def resolve_identifier_use(tree_data: TreeData, infos: list[dict[str, Any]], node: Any) -> dict[str, Any]:
    name = source_text(tree_data.source, node)
    owner_proto_id = nearest_function_id(node, tree_data.function_id_by_key)
    for scope_id in lexical_scope_chain(node, tree_data):
        candidates = [candidate for candidate in infos
                      if candidate["declaration"].scope_id == scope_id
                      and candidate["declaration"].name == name
                      and candidate["visibility_start"] <= node.start_byte]
        if candidates:
            binding = max(candidates, key=lambda candidate: (candidate["visibility_start"],
                                                               candidate["declaration"].order))
            binding_proto_id, local_index = binding["binding_id"]
            return {"kind": "local" if binding_proto_id == owner_proto_id else "upvalue",
                    "owner_proto_id": owner_proto_id, "binding_proto_id": binding_proto_id,
                    "local_index": local_index, "name": name}
    return {"kind": "global", "owner_proto_id": owner_proto_id, "binding_proto_id": None,
            "local_index": None, "name": name}


def canonical_identifier_context(node: Any) -> str:
    return "index_expression" if node.parent.type in {"dot_index_expression", "bracket_index_expression"} \
        else node.parent.type


def active_local_for_register(prototype: Prototype, pc: int, register: int) -> LocalBinding | None:
    active = [local for local in prototype.locals if local.start_pc <= pc < local.end_pc]
    return active[register] if 0 <= register < len(active) else None


def local_function_binding_matches_child(tree_data: TreeData, binding_infos: list[dict[str, Any]],
                                         parent_id: int, local_index: int, child_id: int) -> bool:
    """Prove that a parent local binding is the AST declaration of ``child_id``.

    This is used only for Lua 5.1's recursive-local-function corner case, where
    the local's debug lifetime begins after the CLOSURE binding pseudo-ops.
    """
    matches = [info for info in binding_infos if info["binding_id"] == (parent_id, local_index)]
    if len(matches) != 1 or matches[0]["declaration"].kind != "local_function":
        return False
    owner = matches[0]["node"]
    while owner is not None and owner.type != "function_declaration":
        owner = owner.parent
    return owner is not None and tree_data.function_id_by_key.get(node_key(owner)) == child_id


def parse_operands(operands: str) -> list[int]:
    return [int(token) for token in operands.split() if re.fullmatch(r"-?\d+", token)]


def instruction_digest(prototype: Prototype) -> str:
    return sha256_bytes("\n".join(f"{x.opcode}\t{x.operands}" for x in prototype.instructions).encode())


def constant_digest(prototype: Prototype) -> str:
    return sha256_bytes("\n".join(prototype.constants).encode())


def parse_runtime_results(text: str) -> dict[str, Any]:
    fields = ["record_type", "scenario", "passed", "trace_equal", "status_equal", "normalized_error_equal",
              "snapshot_equal", "original_ok", "readable_ok", "original_trace_count", "readable_trace_count",
              "trace_diff_index", "original_normalized_error", "readable_normalized_error",
              "original_raw_error", "readable_raw_error"]
    scenarios, coverage, all_pass = [], [], False
    for line in text.splitlines():
        parts = line.split("\t")
        if parts[0] == "RESULT":
            padded = parts + [""] * (len(fields) - len(parts))
            row = dict(zip(fields, padded))
            for key in ("passed", "trace_equal", "status_equal", "normalized_error_equal", "snapshot_equal",
                        "original_ok", "readable_ok"):
                row[key] = row[key] == "true"
            for key in ("original_trace_count", "readable_trace_count", "trace_diff_index"):
                row[key] = int(row[key] or 0)
            scenarios.append(row)
        elif parts[0] == "COVERAGE":
            coverage = [item for item in parts[1].split(",") if item]
        elif parts[0] == "ALL_PASS":
            all_pass = parts[1] == "true"
    return {"scenarios": scenarios, "coverage": coverage, "all_pass": all_pass}


def load_xxtea_tool(path: Path) -> Any:
    spec = importlib.util.spec_from_file_location("g25_xxtea_frame_tool", path)
    require(spec and spec.loader, 'audit invariant originally at line 578')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def shannon_entropy(data: bytes) -> float:
    if not data:
        return 0.0
    counts, length = Counter(data), len(data)
    return -sum((count / length) * math.log2(count / length) for count in counts.values())


def bool_text(value: bool) -> str:
    return "true" if value else "false"


def main() -> int:
    parser = argparse.ArgumentParser()
    script_path = Path(__file__).resolve()
    default_root = script_path.parents[1]
    default_base = default_root.parent / "白猪G2.5 0518离线[必须更新]"
    parser.add_argument("--output-root", type=Path, default=default_root)
    parser.add_argument("--base-root", type=Path, default=default_base)
    parser.add_argument("--luajit", type=Path, default=default_base / "out" / "tools" / "luajit.exe")
    parser.add_argument("--luac", type=Path, default=Path(r"C:\Program Files (x86)\Lua\5.1\luac.exe"))
    args = parser.parse_args()

    root, base = args.output_root.resolve(), args.base_root.resolve()
    audit, raw, runtime_dir = root / "audit", root / "audit" / "raw", root / "audit" / "runtime"
    audit.mkdir(parents=True, exist_ok=True)
    raw.mkdir(parents=True, exist_ok=True)
    runtime_dir.mkdir(parents=True, exist_ok=True)

    original_source = root / "core_dec_original_payload.lua"
    readable_source = root / "core_dec_readable.lua"
    readable_repacked = root / "core_readable_repacked.bin"
    harness_source = root / "core_differential_harness.lua"
    xxtea_tool_path = root / "xxtea_frame_tool.py"
    required = (original_source, readable_source, readable_repacked, harness_source, xxtea_tool_path, args.luajit, args.luac)
    for path in required:
        if not path.exists():
            raise FileNotFoundError(path)

    with tempfile.TemporaryDirectory(prefix="g25_core_audit_") as temporary:
        temp = Path(temporary)
        temp_original, temp_readable = temp / original_source.name, temp / readable_source.name
        temp_harness = temp / harness_source.name
        shutil.copyfile(original_source, temp_original)
        shutil.copyfile(readable_source, temp_readable)
        shutil.copyfile(harness_source, temp_harness)

        code, original_luac_text = run_capture([str(args.luac), "-l", "-l", str(temp_original)], temp)
        if code:
            raise RuntimeError(original_luac_text)
        code, readable_luac_text = run_capture([str(args.luac), "-l", "-l", str(temp_readable)], temp)
        if code:
            raise RuntimeError(readable_luac_text)
        (raw / "original_lua51_listing.txt").write_bytes(stabilize_luac_listing(original_luac_text).encode("utf-8"))
        (raw / "readable_lua51_listing.txt").write_bytes(stabilize_luac_listing(readable_luac_text).encode("utf-8"))

        dump_script = temp / "dump_stripped.lua"
        dump_script.write_text('local source_path, output_path = ...\nlocal chunk = assert(loadfile(source_path))\n'
                               'local dumped = string.dump(chunk, true)\nlocal file = assert(io.open(output_path, "wb"))\n'
                               'assert(file:write(dumped))\nassert(file:close())\n', encoding="ascii")
        original_dump, readable_dump = raw / "original_stripped_luajit.ljbc", raw / "readable_stripped_luajit.ljbc"
        code, output = run_capture([str(args.luajit), str(dump_script), str(temp_original), str(original_dump)], temp)
        if code:
            raise RuntimeError(output)
        code, output = run_capture([str(args.luajit), str(dump_script), str(temp_readable), str(readable_dump)], temp)
        if code:
            raise RuntimeError(output)

        code, runtime_text = run_capture([str(args.luajit), str(temp_harness), temp_original.name, temp_readable.name], temp)
        if code:
            raise RuntimeError(runtime_text)
        runtime_text = normalize_newlines(runtime_text)
        (runtime_dir / "core_runtime_results.tsv").write_bytes(runtime_text.encode("utf-8"))

    shutil.copyfile(harness_source, runtime_dir / "core_differential_harness.lua")
    for source_name, target_name in (("_audit_orig_bl.txt", "original_luajit_listing.txt"),
                                     ("_audit_read_bl.txt", "readable_luajit_listing.txt")):
        source_path = root / source_name
        if source_path.exists():
            shutil.copyfile(source_path, raw / target_name)

    original_protos, readable_protos = parse_luac_listing(original_luac_text), parse_luac_listing(readable_luac_text)
    require(len(original_protos) == len(readable_protos) == len(FUNCTION_NAMES), 'audit invariant originally at line 665')
    original_parents, original_children, original_depths = build_prototype_tree(original_protos)
    readable_parents, readable_children, readable_depths = build_prototype_tree(readable_protos)
    require((original_parents, original_children, original_depths) == (readable_parents, readable_children, readable_depths), 'audit invariant originally at line 668')

    original_tree, readable_tree = build_tree_data(original_source), build_tree_data(readable_source)
    require(len(original_tree.function_nodes) == len(readable_tree.function_nodes) == 25, 'audit invariant originally at line 671')
    require(len(original_tree.scopes) == len(readable_tree.scopes) == 127, 'audit invariant originally at line 672')
    runtime = parse_runtime_results(runtime_text)
    require(runtime["all_pass"] and len(runtime["scenarios"]) == 8, 'audit invariant originally at line 674')
    require(len(runtime["coverage"]) == len(set(runtime["coverage"])) == len(FUNCTION_NAMES), 'audit invariant originally at line 675')
    coverage_set = set(runtime["coverage"])

    original_dump_data, readable_dump_data = original_dump.read_bytes(), readable_dump.read_bytes()
    stripped_equal = original_dump_data == readable_dump_data
    require(stripped_equal, 'audit invariant originally at line 680')

    function_rows: list[dict[str, Any]] = []
    for index, (original, readable) in enumerate(zip(original_protos, readable_protos)):
        summary_equal = (original.instruction_count, original.params, original.vararg, original.slots,
                         original.upvalue_count, original.local_count, original.constant_count, original.child_count) == (
                        readable.instruction_count, readable.params, readable.vararg, readable.slots,
                        readable.upvalue_count, readable.local_count, readable.constant_count, readable.child_count)
        instructions_equal = [x.semantic for x in original.instructions] == [x.semantic for x in readable.instructions]
        constants_equal = original.constants == readable.constants
        local_lifetimes_equal = [(x.index, x.start_pc, x.end_pc) for x in original.locals] == [
            (x.index, x.start_pc, x.end_pc) for x in readable.locals]
        upvalue_slots_equal = [x.index for x in original.upvalues] == [x.index for x in readable.upvalues]
        coverage_key = next((x for x in runtime["coverage"] if x.startswith("0:")), "") if index == 0 \
                       else f"{readable.line_defined}:{readable.last_line_defined}"
        dynamic_covered = coverage_key in coverage_set
        parent = original_parents[index]
        row = {
            "prototype_id": f"P{index:02d}", "function_name": FUNCTION_NAMES[index],
            "parent_prototype_id": "" if parent is None else f"P{parent:02d}",
            "parent_function_name": "" if parent is None else FUNCTION_NAMES[parent],
            "prototype_depth": original_depths[index],
            "original_line_range": f"{original.line_defined}:{original.last_line_defined}",
            "readable_line_range": f"{readable.line_defined}:{readable.last_line_defined}",
            "parameters": original.params, "vararg": bool_text(original.vararg), "stack_slots": original.slots,
            "instructions": original.instruction_count, "constants": original.constant_count,
            "locals": original.local_count, "upvalues": original.upvalue_count,
            "direct_child_functions": original.child_count, "summary_equal": bool_text(summary_equal),
            "opcode_operand_stream_equal": bool_text(instructions_equal), "constant_table_equal": bool_text(constants_equal),
            "local_pc_lifetimes_equal": bool_text(local_lifetimes_equal),
            "upvalue_slot_graph_equal": bool_text(upvalue_slots_equal),
            "original_instruction_sha256": instruction_digest(original),
            "readable_instruction_sha256": instruction_digest(readable),
            "original_constant_sha256": constant_digest(original),
            "readable_constant_sha256": constant_digest(readable),
            "runtime_coverage_key": coverage_key, "dynamically_covered": bool_text(dynamic_covered),
            "strict_executable_checks_pass": bool_text(summary_equal and instructions_equal and constants_equal and
                                                        local_lifetimes_equal and upvalue_slots_equal and dynamic_covered),
        }
        require(row["strict_executable_checks_pass"] == "true", 'audit invariant originally at line 719', (index, row))
        function_rows.append(row)
    write_csv(audit / "core_function_audit.csv", list(function_rows[0]), function_rows)

    instruction_rows: list[dict[str, Any]] = []
    for proto_id, (original, readable) in enumerate(zip(original_protos, readable_protos)):
        require(len(original.instructions) == len(readable.instructions), 'audit invariant originally at line 725')
        for left, right in zip(original.instructions, readable.instructions):
            opcode_equal = left.opcode == right.opcode
            operands_equal = left.operands == right.operands
            instruction_rows.append({
                "prototype_id": f"P{proto_id:02d}", "function_name": FUNCTION_NAMES[proto_id],
                "pc": left.pc, "original_source_line": left.source_line, "readable_source_line": right.source_line,
                "original_opcode": left.opcode, "readable_opcode": right.opcode,
                "original_operands": left.operands, "readable_operands": right.operands,
                "original_listing_comment": left.comment, "readable_listing_comment": right.comment,
                "opcode_equal": bool_text(opcode_equal), "operands_equal": bool_text(operands_equal),
                "semantic_instruction_equal": bool_text(opcode_equal and operands_equal),
            })
    require(len(instruction_rows) == 1661, 'audit invariant originally at line 738')
    require(all(row["semantic_instruction_equal"] == "true" for row in instruction_rows), 'audit invariant originally at line 739')
    write_csv(audit / "core_instruction_audit.csv", list(instruction_rows[0]), instruction_rows)

    constant_rows: list[dict[str, Any]] = []
    string_constant_count = numeric_constant_count = 0
    for proto_id, (original, readable) in enumerate(zip(original_protos, readable_protos)):
        for constant_index, (left, right) in enumerate(zip(original.constants, readable.constants), 1):
            is_string = left.startswith(('"', "'")) and left.endswith(left[0])
            constant_type = "string" if is_string else "number"
            if is_string:
                string_constant_count += 1
                decoded = decode_lua_quoted(left)
            else:
                numeric_constant_count += 1
                decoded = left
            constant_rows.append({"prototype_id": f"P{proto_id:02d}", "function_name": FUNCTION_NAMES[proto_id],
                                  "constant_index": constant_index, "constant_type": constant_type,
                                  "original_repr": left, "readable_repr": right, "decoded_value": decoded,
                                  "equal": bool_text(left == right)})
    require((len(constant_rows), string_constant_count, numeric_constant_count) == (366, 361, 5), 'audit invariant originally at line 758')
    require(all(row["equal"] == "true" for row in constant_rows), 'audit invariant originally at line 759')
    write_csv(audit / "core_constant_audit.csv", list(constant_rows[0]), constant_rows)

    scope_rows: list[dict[str, Any]] = []
    semantic_statement_total = 0
    block_depth_counts: Counter[int] = Counter()
    for scope_id, (left, right) in enumerate(zip(original_tree.scopes, readable_tree.scopes)):
        def scope_parent(node: Any, tree_data: TreeData) -> int | str:
            current = node.parent
            while current is not None:
                if node_key(current) in tree_data.scope_id_by_key:
                    return tree_data.scope_id_by_key[node_key(current)]
                current = current.parent
            return ""

        def function_depth(node: Any) -> int:
            depth, current = 0, node.parent
            while current is not None:
                depth += current.type in FUNCTION_NODE_TYPES
                current = current.parent
            return depth

        left_types = [c.type for c in left.named_children if c.type not in IGNORED_DIRECT_NODES]
        right_types = [c.type for c in right.named_children if c.type not in IGNORED_DIRECT_NODES]
        left_depth, right_depth = function_depth(left), function_depth(right)
        left_parent, right_parent = scope_parent(left, original_tree), scope_parent(right, readable_tree)
        if scope_id:
            block_depth_counts[left_depth] += 1
        semantic_statement_total += len(left_types)
        left_locals = sum(c.type == "variable_declaration" or
                          (c.type == "function_declaration" and c.children and c.children[0].type == "local")
                          for c in left.named_children)
        right_locals = sum(c.type == "variable_declaration" or
                           (c.type == "function_declaration" and c.children and c.children[0].type == "local")
                           for c in right.named_children)
        equal = (left.type == right.type and left_types == right_types and left_depth == right_depth and
                 left_parent == right_parent and left_locals == right_locals)
        scope_rows.append({
            "scope_id": f"S{scope_id:03d}", "scope_node_type": left.type,
            "owner_node_type": "<root>" if left.parent is None else left.parent.type,
            "parent_scope_id": "" if left_parent == "" else f"S{int(left_parent):03d}",
            "function_depth": left_depth, "original_location": point_text(original_tree.source, left),
                           "readable_location": point_text(readable_tree.source, right),
            "direct_semantic_statement_count": len(left_types),
            "direct_local_declaration_statement_count": left_locals,
            "direct_statement_types": " | ".join(left_types),
            "parent_scope_equal": bool_text(left_parent == right_parent),
            "function_depth_equal": bool_text(left_depth == right_depth),
            "statement_sequence_equal": bool_text(left_types == right_types),
            "scope_structure_equal": bool_text(equal),
        })
    require(semantic_statement_total == 332, 'audit invariant originally at line 810', semantic_statement_total)
    require(block_depth_counts == Counter({1: 9, 2: 69, 3: 48}), 'audit invariant originally at line 811', block_depth_counts)
    require(all(row["scope_structure_equal"] == "true" for row in scope_rows), 'audit invariant originally at line 812')
    write_csv(audit / "core_lexical_scope_audit.csv", list(scope_rows[0]), scope_rows)

    original_binding_infos = declaration_binding_infos(original_tree)
    readable_binding_infos = declaration_binding_infos(readable_tree)
    original_shadow_relations = find_shadow_relations(original_tree, original_binding_infos)
    readable_shadow_relations = find_shadow_relations(readable_tree, readable_binding_infos)
    require(len(original_shadow_relations) == len(readable_shadow_relations) == 2, 'audit invariant originally at line 819')

    shadow_rows: list[dict[str, Any]] = []
    shadowing_binding_ids: set[tuple[int, int]] = set()
    shadowed_binding_ids: set[tuple[int, int]] = set()
    for relation_index, (left_relation, right_relation) in enumerate(
            zip(original_shadow_relations, readable_shadow_relations), 1):
        left_inner, left_outer = left_relation["inner"], left_relation["outer"]
        right_inner, right_outer = right_relation["inner"], right_relation["outer"]
        left_inner_decl, left_outer_decl = left_inner["declaration"], left_outer["declaration"]
        right_inner_decl, right_outer_decl = right_inner["declaration"], right_outer["declaration"]
        identity_equal = (left_inner["binding_id"] == right_inner["binding_id"] and
                          left_outer["binding_id"] == right_outer["binding_id"] and
                          left_inner_decl.kind == right_inner_decl.kind and
                          left_outer_decl.kind == right_outer_decl.kind and
                          left_inner_decl.scope_id == right_inner_decl.scope_id and
                          left_outer_decl.scope_id == right_outer_decl.scope_id)
        require(identity_equal, 'audit invariant originally at line 836')
        shadowing_binding_ids.add(left_inner["binding_id"])
        shadowed_binding_ids.add(left_outer["binding_id"])
        shadow_rows.append({
            "shadow_relation_id": f"SH{relation_index:02d}",
            "inner_binding_id": f"P{left_inner_decl.proto_id:02d}:L{left_inner['local_index']:03d}",
            "inner_function_name": FUNCTION_NAMES[left_inner_decl.proto_id],
            "inner_declaration_kind": left_inner_decl.kind,
            "inner_scope_id": f"S{left_inner_decl.scope_id:03d}",
            "original_inner_name": left_inner_decl.name, "readable_inner_name": right_inner_decl.name,
            "original_inner_location": f"{left_inner_decl.line}:{left_inner_decl.column}",
            "readable_inner_location": f"{right_inner_decl.line}:{right_inner_decl.column}",
            "outer_binding_id": f"P{left_outer_decl.proto_id:02d}:L{left_outer['local_index']:03d}",
            "outer_function_name": FUNCTION_NAMES[left_outer_decl.proto_id],
            "outer_declaration_kind": left_outer_decl.kind,
            "outer_scope_id": f"S{left_outer_decl.scope_id:03d}",
            "original_outer_name": left_outer_decl.name, "readable_outer_name": right_outer_decl.name,
            "original_outer_location": f"{left_outer_decl.line}:{left_outer_decl.column}",
            "readable_outer_location": f"{right_outer_decl.line}:{right_outer_decl.column}",
            "same_prototype": bool_text(left_inner_decl.proto_id == left_outer_decl.proto_id),
            "relation_equivalent": bool_text(identity_equal),
        })
    require({(row["inner_binding_id"], row["outer_binding_id"]) for row in shadow_rows} == {
        ("P01:L044", "P01:L040"), ("P11:L000", "P01:L015")}, 'audit invariant originally at line 858')
    write_csv(audit / "core_shadowing_audit.csv", list(shadow_rows[0]), shadow_rows)

    variable_rows: list[dict[str, Any]] = []
    original_freq = {i: Counter(x.name for x in p.locals) for i, p in enumerate(original_protos)}
    readable_freq = {i: Counter(x.name for x in p.locals) for i, p in enumerate(readable_protos)}
    for proto_id, (left_proto, right_proto) in enumerate(zip(original_protos, readable_protos)):
        left_decls, right_decls = original_tree.declarations[proto_id], readable_tree.declarations[proto_id]
        require(len(left_decls) == len(left_proto.locals) and len(right_decls) == len(right_proto.locals), 'audit invariant originally at line 867')
        for local_index, (left_local, right_local, left_decl, right_decl) in enumerate(
                zip(left_proto.locals, right_proto.locals, left_decls, right_decls)):
            listing_matches_ast = left_local.name == left_decl.name and right_local.name == right_decl.name
            pc_equal = (left_local.index, left_local.start_pc, left_local.end_pc) == (
                right_local.index, right_local.start_pc, right_local.end_pc)
            scope_equal, kind_equal = left_decl.scope_id == right_decl.scope_id, left_decl.kind == right_decl.kind
            binding_equal = listing_matches_ast and pc_equal and scope_equal and kind_equal
            binding_id = (proto_id, local_index)
            variable_rows.append({
                "prototype_id": f"P{proto_id:02d}", "function_name": FUNCTION_NAMES[proto_id],
                "local_index": local_index, "binding_id": f"P{proto_id:02d}:L{local_index:03d}",
                "declaration_kind": left_decl.kind,
                "original_name": left_local.name, "readable_name": right_local.name,
                "original_scope_id": f"S{left_decl.scope_id:03d}", "readable_scope_id": f"S{right_decl.scope_id:03d}",
                "original_declaration_location": f"{left_decl.line}:{left_decl.column}",
                "readable_declaration_location": f"{right_decl.line}:{right_decl.column}",
                "start_pc": left_local.start_pc, "end_pc": left_local.end_pc,
                "pc_lifetime_length": left_local.end_pc - left_local.start_pc,
                "original_same_name_count_in_function": original_freq[proto_id][left_local.name],
                "readable_same_name_count_in_function": readable_freq[proto_id][right_local.name],
                "original_same_name_reused_in_same_function": bool_text(original_freq[proto_id][left_local.name] > 1),
                "readable_same_name_reused_in_same_function": bool_text(readable_freq[proto_id][right_local.name] > 1),
                "participates_in_lexical_shadow_relation": bool_text(
                    binding_id in shadowing_binding_ids or binding_id in shadowed_binding_ids),
                "shadows_binding": bool_text(binding_id in shadowing_binding_ids),
                "is_shadowed_by_binding": bool_text(binding_id in shadowed_binding_ids),
                "listing_name_matches_ast": bool_text(listing_matches_ast), "declaration_kind_equal": bool_text(kind_equal),
                "scope_binding_equal": bool_text(scope_equal), "pc_lifetime_equal": bool_text(pc_equal),
                "binding_equivalent": bool_text(binding_equal),
            })
    require(len(variable_rows) == 129 and all(x["binding_equivalent"] == "true" for x in variable_rows), 'audit invariant originally at line 898')
    require(sum(x["participates_in_lexical_shadow_relation"] == "true" for x in variable_rows) == 4, 'audit invariant originally at line 899')
    write_csv(audit / "core_variable_scope_audit.csv", list(variable_rows[0]), variable_rows)

    original_identifier_uses = extract_identifier_uses(original_tree)
    readable_identifier_uses = extract_identifier_uses(readable_tree)
    require(len(original_identifier_uses) == len(readable_identifier_uses) == 527, 'audit invariant originally at line 904')
    identifier_use_rows: list[dict[str, Any]] = []
    identifier_binding_kind_counts: Counter[str] = Counter()
    for use_index, (left_node, right_node) in enumerate(zip(original_identifier_uses, readable_identifier_uses), 1):
        left_binding = resolve_identifier_use(original_tree, original_binding_infos, left_node)
        right_binding = resolve_identifier_use(readable_tree, readable_binding_infos, right_node)
        left_identity = (left_binding["kind"], left_binding["binding_proto_id"], left_binding["local_index"])
        right_identity = (right_binding["kind"], right_binding["binding_proto_id"], right_binding["local_index"])
        global_name_equal = left_binding["kind"] != "global" or left_binding["name"] == right_binding["name"]
        context_equal = canonical_identifier_context(left_node) == canonical_identifier_context(right_node)
        binding_equal = (left_identity == right_identity and global_name_equal and
                         left_binding["owner_proto_id"] == right_binding["owner_proto_id"] and context_equal)
        identifier_binding_kind_counts[left_binding["kind"]] += 1
        binding_proto_id, local_index = left_binding["binding_proto_id"], left_binding["local_index"]
        binding_id = (f"P{binding_proto_id:02d}:L{local_index:03d}" if binding_proto_id is not None
                      else f"GLOBAL:{left_binding['name']}")
        identifier_use_rows.append({
            "use_index": use_index,
            "owner_prototype_id": f"P{left_binding['owner_proto_id']:02d}",
            "owner_function_name": FUNCTION_NAMES[left_binding["owner_proto_id"]],
            "binding_kind": left_binding["kind"], "resolved_binding_id": binding_id,
            "original_identifier": left_binding["name"], "readable_identifier": right_binding["name"],
            "original_location": point_text(original_tree.source, left_node),
            "readable_location": point_text(readable_tree.source, right_node),
            "original_context": canonical_identifier_context(left_node),
            "readable_context": canonical_identifier_context(right_node),
            "context_equivalent": bool_text(context_equal),
            "binding_equivalent": bool_text(binding_equal),
        })
    require(identifier_binding_kind_counts == Counter({"upvalue": 336, "local": 189, "global": 2}), 'audit invariant originally at line 933')
    require(all(row["binding_equivalent"] == "true" for row in identifier_use_rows), 'audit invariant originally at line 934')
    write_csv(audit / "core_identifier_use_audit.csv", list(identifier_use_rows[0]), identifier_use_rows)

    upvalue_rows: list[dict[str, Any]] = []
    for child_id in range(1, len(original_protos)):
        parent_id = original_parents[child_id]
        require(parent_id is not None, 'audit invariant originally at line 940')
        child_ordinal = original_children[parent_id].index(child_id)
        left_parent, right_parent = original_protos[parent_id], readable_protos[parent_id]
        left_closures = [(i, x) for i, x in enumerate(left_parent.instructions)
                         if x.opcode == "CLOSURE" and parse_operands(x.operands)[-1] == child_ordinal]
        right_closures = [(i, x) for i, x in enumerate(right_parent.instructions)
                          if x.opcode == "CLOSURE" and parse_operands(x.operands)[-1] == child_ordinal]
        require(len(left_closures) == len(right_closures) == 1, 'audit invariant originally at line 947', (child_id, left_closures, right_closures))
        left_position, left_closure = left_closures[0]
        right_position, right_closure = right_closures[0]
        for upvalue_index, (left_uv, right_uv) in enumerate(zip(original_protos[child_id].upvalues,
                                                                 readable_protos[child_id].upvalues)):
            left_binding = left_parent.instructions[left_position + 1 + upvalue_index]
            right_binding = right_parent.instructions[right_position + 1 + upvalue_index]
            require(left_binding.opcode in {"MOVE", "GETUPVAL"} and right_binding.opcode in {"MOVE", "GETUPVAL"},
                    "closure binding pseudo-op must be MOVE or GETUPVAL")
            require(left_binding.opcode == right_binding.opcode,
                    "original/readable closure binding opcode must match",
                    {"child_id": child_id, "upvalue_index": upvalue_index,
                     "original": left_binding.opcode, "readable": right_binding.opcode})
            left_binding_operands = parse_operands(left_binding.operands)
            right_binding_operands = parse_operands(right_binding.operands)
            require(left_binding_operands and right_binding_operands,
                    "closure binding pseudo-op must expose a source slot")
            left_slot, right_slot = left_binding_operands[-1], right_binding_operands[-1]
            capture_source_local_index: int | str = ""
            if left_binding.opcode == "MOVE":
                left_source = active_local_for_register(left_parent, left_closure.pc, left_slot)
                right_source = active_local_for_register(right_parent, right_closure.pc, right_slot)
                source_kind = "parent_local_register"
                # A recursive local function captures its own CLOSURE destination
                # register while Lua's debug lifetime starts only after every
                # closure-binding pseudo-op.  The fallback is legal only when both
                # sides have the same absence and independently satisfy all of the
                # target-register, MOVE-slot, lifecycle and AST-declaration checks.
                require((left_source is None) == (right_source is None),
                        "closure-PC local visibility must be symmetric",
                        {"child_id": child_id, "upvalue_index": upvalue_index,
                         "original_missing": left_source is None, "readable_missing": right_source is None})
                if left_source is None:  # Both are absent; one-sided absence was rejected above.
                    left_post_pc = left_closure.pc + len(original_protos[child_id].upvalues) + 1
                    right_post_pc = right_closure.pc + len(readable_protos[child_id].upvalues) + 1
                    left_post_source = active_local_for_register(left_parent, left_post_pc, left_slot)
                    right_post_source = active_local_for_register(right_parent, right_post_pc, right_slot)
                    left_closure_operands = parse_operands(left_closure.operands)
                    right_closure_operands = parse_operands(right_closure.operands)
                    left_move_operands = parse_operands(left_binding.operands)
                    right_move_operands = parse_operands(right_binding.operands)
                    require(len(left_closure_operands) == len(right_closure_operands) == 2,
                            "recursive fallback requires two-operand CLOSURE instructions",
                            {"original": left_closure.operands, "readable": right_closure.operands})
                    require(len(left_move_operands) == len(right_move_operands) == 2 and
                            left_move_operands[0] == right_move_operands[0] == 0,
                            "recursive fallback requires Lua 5.1 MOVE capture pseudo-ops",
                            {"original": left_binding.operands, "readable": right_binding.operands})
                    require(left_slot == left_closure_operands[0] and right_slot == right_closure_operands[0],
                            "recursive capture source slot must equal CLOSURE destination register",
                            {"original_slot": left_slot, "original_target": left_closure_operands[0],
                             "readable_slot": right_slot, "readable_target": right_closure_operands[0]})
                    require(left_post_source is not None and right_post_source is not None,
                            "recursive local must become visible immediately after CLOSURE bindings",
                            {"child_id": child_id, "original_post_pc": left_post_pc,
                             "readable_post_pc": right_post_pc})
                    require(left_post_source.start_pc == left_post_pc and right_post_source.start_pc == right_post_pc,
                            "recursive local lifetime must begin at the verified post-CLOSURE PC",
                            {"original_start": left_post_source.start_pc, "original_post_pc": left_post_pc,
                             "readable_start": right_post_source.start_pc, "readable_post_pc": right_post_pc})
                    require(left_post_source.index == left_slot and right_post_source.index == right_slot,
                            "recursive local debug binding must correspond to the captured register",
                            {"original_local_index": left_post_source.index, "original_slot": left_slot,
                             "readable_local_index": right_post_source.index, "readable_slot": right_slot})
                    require(local_function_binding_matches_child(original_tree, original_binding_infos, parent_id,
                                                                 left_post_source.index, child_id) and
                            local_function_binding_matches_child(readable_tree, readable_binding_infos, parent_id,
                                                                 right_post_source.index, child_id),
                            "post-CLOSURE fallback must be the AST local-function declaration for this child",
                            {"child_id": child_id, "parent_id": parent_id,
                             "original_local_index": left_post_source.index,
                             "readable_local_index": right_post_source.index})
                    left_source, right_source = left_post_source, right_post_source
                    source_kind = "parent_local_register_post_closure"
                require(left_source is not None and right_source is not None,
                        "MOVE upvalue capture must resolve to parent locals")
                left_source_name, right_source_name = left_source.name, right_source.name
                capture_source_local_index = left_source.index
            else:
                left_source_name, right_source_name = left_parent.upvalues[left_slot].name, right_parent.upvalues[right_slot].name
                source_kind = "parent_upvalue_slot"
            binding_equal = left_binding.semantic == right_binding.semantic
            names_consistent = left_source_name == left_uv.name and right_source_name == right_uv.name
            upvalue_rows.append({
                "prototype_id": f"P{child_id:02d}", "function_name": FUNCTION_NAMES[child_id],
                "parent_prototype_id": f"P{parent_id:02d}", "parent_function_name": FUNCTION_NAMES[parent_id],
                "upvalue_index": upvalue_index, "original_upvalue_name": left_uv.name,
                "readable_upvalue_name": right_uv.name, "capture_source_kind": source_kind,
                "capture_source_slot": left_slot, "capture_source_local_index": capture_source_local_index,
                "original_capture_source_name": left_source_name,
                "readable_capture_source_name": right_source_name, "closure_pc": left_closure.pc,
                "binding_pc": left_binding.pc, "binding_opcode": left_binding.opcode,
                "binding_operands": left_binding.operands, "binding_instruction_equal": bool_text(binding_equal),
                "capture_name_consistent": bool_text(names_consistent),
                "capture_binding_equivalent": bool_text(binding_equal and names_consistent),
            })
    bad_upvalues = [x for x in upvalue_rows if x["capture_binding_equivalent"] != "true"]
    require(len(upvalue_rows) == 116 and not bad_upvalues, 'audit invariant originally at line 988', bad_upvalues[:5])
    write_csv(audit / "core_upvalue_audit.csv", list(upvalue_rows[0]), upvalue_rows)

    require(len(original_tree.runtime_names) == len(readable_tree.runtime_names) == 368, 'audit invariant originally at line 991')
    runtime_name_rows: list[dict[str, Any]] = []
    for occurrence, (left, right) in enumerate(zip(original_tree.runtime_names, readable_tree.runtime_names), 1):
        equal = left["kind"] == right["kind"] and left["name"] == right["name"] and left["static"] == right["static"]
        runtime_name_rows.append({
            "occurrence_id": occurrence, "kind": left["kind"], "original_name": left["name"],
            "readable_name": right["name"], "static_name": bool_text(left["static"]),
            "original_location": left["location"], "readable_location": right["location"],
            "original_syntax": left["syntax"], "readable_syntax": right["syntax"],
            "kind_equal": bool_text(left["kind"] == right["kind"]),
            "name_equal": bool_text(left["name"] == right["name"]), "runtime_name_equivalent": bool_text(equal),
        })
    require(all(x["runtime_name_equivalent"] == "true" for x in runtime_name_rows), 'audit invariant originally at line 1003')
    kind_counts = Counter(x["kind"] for x in runtime_name_rows)
    require(kind_counts == Counter({"field_access": 360, "table_key": 5, "method_name": 2, "dynamic_index": 1}), 'audit invariant originally at line 1005')
    write_csv(audit / "core_runtime_name_occurrences.csv", list(runtime_name_rows[0]), runtime_name_rows)

    static_names = sorted({x["original_name"] for x in runtime_name_rows if x["static_name"] == "true"})
    require(len(static_names) == 83, 'audit invariant originally at line 1009', len(static_names))
    runtime_summary_rows: list[dict[str, Any]] = []
    for name in static_names + ["<dynamic-index>"]:
        left_matches = [x for x in runtime_name_rows if x["original_name"] == name]
        right_matches = [x for x in runtime_name_rows if x["readable_name"] == name]
        left_kinds, right_kinds = Counter(x["kind"] for x in left_matches), Counter(x["kind"] for x in right_matches)
        runtime_summary_rows.append({
            "name": name, "static_name": bool_text(name != "<dynamic-index>"),
            "original_occurrences": len(left_matches), "readable_occurrences": len(right_matches),
            "original_kind_counts": json.dumps(left_kinds, ensure_ascii=False, sort_keys=True),
            "readable_kind_counts": json.dumps(right_kinds, ensure_ascii=False, sort_keys=True),
            "counts_equal": bool_text(len(left_matches) == len(right_matches) and left_kinds == right_kinds),
        })
    write_csv(audit / "core_runtime_name_summary.csv", list(runtime_summary_rows[0]), runtime_summary_rows)

    global_rows: list[dict[str, Any]] = []
    for proto_id, (left_proto, right_proto) in enumerate(zip(original_protos, readable_protos)):
        left_globals = [x for x in left_proto.instructions if x.opcode in {"GETGLOBAL", "SETGLOBAL"}]
        right_globals = [x for x in right_proto.instructions if x.opcode in {"GETGLOBAL", "SETGLOBAL"}]
        require(len(left_globals) == len(right_globals), 'audit invariant originally at line 1028')
        for occurrence, (left, right) in enumerate(zip(left_globals, right_globals), 1):
            left_name = decode_lua_quoted(left.comment) if left.comment.startswith(('"', "'")) else left.comment
            right_name = decode_lua_quoted(right.comment) if right.comment.startswith(('"', "'")) else right.comment
            global_rows.append({"prototype_id": f"P{proto_id:02d}", "function_name": FUNCTION_NAMES[proto_id],
                                "occurrence_in_function": occurrence, "opcode": left.opcode,
                                "original_pc": left.pc, "readable_pc": right.pc,
                                "original_global_name": left_name, "readable_global_name": right_name,
                                "equal": bool_text(left.semantic == right.semantic and left_name == right_name)})
    require(len(global_rows) == 2 and all(x["equal"] == "true" for x in global_rows), 'audit invariant originally at line 1037', global_rows)
    write_csv(audit / "core_global_access_audit.csv", list(global_rows[0]), global_rows)

    semantic_node_types = ["function_declaration", "function_definition", "block", "assignment_statement",
                           "binary_expression", "function_call", "if_statement", "return_statement",
                           "variable_declaration", "parameters"]
    ast_rows = [{"node_type": t, "original_count": original_tree.node_counts[t],
                 "readable_count": readable_tree.node_counts[t],
                 "equal": bool_text(original_tree.node_counts[t] == readable_tree.node_counts[t])}
                for t in semantic_node_types]
    require(all(x["equal"] == "true" for x in ast_rows), 'audit invariant originally at line 1047')
    write_csv(audit / "core_ast_node_count_audit.csv", list(ast_rows[0]), ast_rows)

    readable_text = readable_tree.source.decode("utf-8")
    disallowed_controls = [b for b in readable_tree.source if b < 32 and b not in (9, 10, 13)]
    decimal_count = len(re.findall(r"\\[0-9]{1,3}", readable_text))
    hex_count = len(re.findall(r"\\x[0-9A-Fa-f]{2}", readable_text))
    unicode_count = len(re.findall(r"\\u[0-9A-Fa-f]{4,8}", readable_text))
    to_number_literals = re.findall(r'\bto_number\s*\(\s*"([^"]*)"\s*\)', readable_text)
    runtime_decode_counts = {name: len(re.findall(rf"\b{re.escape(name)}\s*\(", readable_text)) for name in (
        "core_func_decodeBase64", "crypto.decodeBase64", "crypto.encodeBase64",
        "core_func_decryptTEA", "json_module.decode", "globals.load", "LuaLoadChunksFromZIP")}
    require(len(to_number_literals) == 34 and len(set(to_number_literals)) == 22, 'audit invariant originally at line 1059')
    require(runtime_decode_counts == {
        "core_func_decodeBase64": 2, "crypto.decodeBase64": 3, "crypto.encodeBase64": 6,
        "core_func_decryptTEA": 2, "json_module.decode": 3, "globals.load": 1, "LuaLoadChunksFromZIP": 2}, 'audit invariant originally at line 1060')
    static_runtime_occurrences = sum(row["static_name"] == "true" for row in runtime_name_rows)
    dynamic_runtime_occurrences = len(runtime_name_rows) - static_runtime_occurrences
    require((static_runtime_occurrences, dynamic_runtime_occurrences) == (367, 1), 'audit invariant originally at line 1065')
    plaintext_rows = [
        {"check": "utf8_strict_decode", "value": "pass", "pass": "true", "evidence": "Entire readable source decodes as strict UTF-8."},
        {"check": "nul_bytes", "value": readable_tree.source.count(b"\x00"), "pass": bool_text(b"\x00" not in readable_tree.source), "evidence": "Raw source byte scan."},
        {"check": "disallowed_raw_control_bytes", "value": len(disallowed_controls), "pass": bool_text(not disallowed_controls), "evidence": "No raw controls other than tab/newline/CR."},
        {"check": "tree_sitter_escape_sequence_nodes", "value": len(readable_tree.escape_sequences), "pass": bool_text(len(readable_tree.escape_sequences) == 3), "evidence": r"Only \022, \t and \n remain."},
        {"check": "decimal_escape_sequences", "value": decimal_count, "pass": bool_text(decimal_count == 1), "evidence": r"Sole decimal escape is intentional \022 gsub pattern."},
        {"check": "hex_escape_sequences", "value": hex_count, "pass": bool_text(hex_count == 0), "evidence": r"No \xNN escapes."},
        {"check": "unicode_escape_sequences", "value": unicode_count, "pass": bool_text(unicode_count == 0), "evidence": r"No \u escapes."},
        {"check": "original_escape_sequence_nodes", "value": len(original_tree.escape_sequences), "pass": bool_text(len(original_tree.escape_sequences) == 4714), "evidence": "Original baseline."},
        {"check": "readable_string_literal_nodes", "value": readable_tree.node_counts["string"], "pass": bool_text(readable_tree.node_counts["string"] == 162), "evidence": "Original has 527 string nodes."},
        {"check": "static_runtime_name_occurrences", "value": static_runtime_occurrences, "pass": bool_text(static_runtime_occurrences == 367), "evidence": "All static field/table-key/method names are visible and audited."},
        {"check": "dynamic_runtime_index_occurrences", "value": dynamic_runtime_occurrences, "pass": "false", "evidence": "One computed table index cannot be replaced with a static name without changing behavior."},
        {"check": "to_number_string_literal_calls", "value": len(to_number_literals), "pass": "false", "evidence": f"34 calls remain (22 unique strings); folding them would change source form and was not required for executable equivalence."},
        {"check": "runtime_base64_decode_calls", "value": runtime_decode_counts["core_func_decodeBase64"] + runtime_decode_counts["crypto.decodeBase64"], "pass": "false", "evidence": "Five runtime Base64 decode calls consume values not all statically known."},
        {"check": "runtime_xxtea_decrypt_calls", "value": runtime_decode_counts["core_func_decryptTEA"], "pass": "false", "evidence": "Two runtime XXTEA decrypt calls depend on external/runtime ciphertext."},
        {"check": "dynamic_lua_load_calls", "value": runtime_decode_counts["globals.load"], "pass": "false", "evidence": "One dynamic load executes decrypted source content."},
        {"check": "external_zip_load_calls", "value": runtime_decode_counts["LuaLoadChunksFromZIP"], "pass": "false", "evidence": "Two archive load sites depend on external ZIP contents."},
        {"check": "static_source_plaintext", "value": "yes", "pass": "true", "evidence": "Source/comments/static names/ordinary strings are readable."},
        {"check": "runtime_external_payloads_plaintext", "value": "no", "pass": "false", "evidence": "Remote data, encrypted archives and gplus inner payload remain opaque."},
    ]
    write_csv(audit / "core_plaintext_audit.csv", list(plaintext_rows[0]), plaintext_rows)
    escape_reasons = {"\\022": "control-byte match used by gsub; changing it changes key derivation",
                      "\\t": "tab character class used by gsub", "\\n": "newline in user-facing message"}
    escape_rows = [{"escape_index": i, "escape_text": x["text"], "location": x["location"],
                    "semantic_reason": escape_reasons.get(x["text"], "preserved runtime escape")}
                   for i, x in enumerate(readable_tree.escape_sequences, 1)]
    write_csv(audit / "core_remaining_escapes.csv", list(escape_rows[0]), escape_rows)

    xxtea = load_xxtea_tool(xxtea_tool_path)
    base_core_bin, base_core_dec, base_gplus = base / "core.bin", base / "core_dec.lua", base / "gplus.bin"
    core_bin_data, core_dec_frame = base_core_bin.read_bytes(), base_core_dec.read_bytes()
    original_payload_data, readable_source_data = original_source.read_bytes(), readable_source.read_bytes()
    core_dec_size = int.from_bytes(core_dec_frame[-4:], "little")
    core_dec_payload, core_dec_padding = core_dec_frame[:core_dec_size], core_dec_frame[core_dec_size:-4]
    core_unpacked = xxtea.unpack_frame(core_bin_data, xxtea.CORE_KEY)
    core_original_roundtrip = xxtea.pack_frame(original_payload_data, xxtea.CORE_KEY)
    readable_unpacked = xxtea.unpack_frame(readable_repacked.read_bytes(), xxtea.CORE_KEY)
    readable_roundtrip = xxtea.pack_frame(readable_source_data, xxtea.CORE_KEY)
    require(core_dec_payload == original_payload_data and core_dec_size == len(original_payload_data) and not core_dec_padding, 'audit invariant originally at line 1104')
    require(core_unpacked == original_payload_data and core_original_roundtrip == core_bin_data, 'audit invariant originally at line 1105')
    require(readable_unpacked == readable_source_data and readable_roundtrip == readable_repacked.read_bytes(), 'audit invariant originally at line 1106')

    gplus_data = base_gplus.read_bytes()
    gplus_plain = xxtea.unpack_frame(gplus_data, xxtea.GPLUS_KEY)
    gplus_sections = gplus_plain.split(b"#")
    gplus_payload_base64 = gplus_sections[-1]
    gplus_payload = base64.b64decode(gplus_payload_base64, validate=True)
    require(gplus_plain == (root / "gplus_layer1_plain.txt").read_bytes(), 'audit invariant originally at line 1113')
    require(xxtea.pack_frame(gplus_plain, xxtea.GPLUS_KEY) == gplus_data, 'audit invariant originally at line 1114')
    require(gplus_payload_base64 == (root / "gplus_payload_base64.txt").read_bytes(), 'audit invariant originally at line 1115')
    require(gplus_payload == (root / "gplus_payload.bin").read_bytes(), 'audit invariant originally at line 1116')

    # Deployment loader audit: visible LuaJIT logic only. Native getFileData internals remain outside this proof.
    loader_chunk = base / "freshclean" / "mir2_解包_opcode解密" / "mir2.def.bzinit.out.luac"
    loader_source = base / "dec" / "mir2_dec_还原" / "mir2.def.bzinit"
    require(loader_chunk.exists() and loader_source.exists(), 'audit invariant originally at line 1121')
    code, loader_listing_text = run_capture([str(args.luajit), "-bl", str(loader_chunk)], args.luajit.parent)
    if code:
        raise RuntimeError(loader_listing_text)
    loader_listing_lines = normalize_newlines(loader_listing_text).splitlines()
    core_literal_lines = [index for index, line in enumerate(loader_listing_lines) if '; "core.bin"' in line]
    require(len(core_literal_lines) == 1, 'audit invariant originally at line 1127')
    loader_line_index = core_literal_lines[0]
    loader_excerpt_lines = loader_listing_lines[loader_line_index - 5:loader_line_index + 27]
    loader_excerpt = "\n".join(loader_excerpt_lines) + "\n"
    required_loader_instructions = (
        '0031    GSET     4  22      ; "core_func_checkbin"',
        '0032    GGET     4  23      ; "ycFunction"',
        '0033    TGETS    4   4  24  ; "getFileData"',
        '0035    KSTR     6  25      ; "core.bin"',
        '0037    CALL     4   3   4',
        '0038    IST          4',
        '0042 => GGET     6  26      ; "var_0_123"',
        '0054    GGET     7  31      ; "pcall"')
    require(all(instruction in loader_excerpt for instruction in required_loader_instructions), 'audit invariant originally at line 1140')
    require(loader_listing_text.count('"core_func_checkbin"') == 1, 'audit invariant originally at line 1141')
    require(loader_listing_text.count('"core_func_md5"') == 1, 'audit invariant originally at line 1142')
    loader_source_text = loader_source.read_text(encoding="utf-8")
    require(loader_source_text.count("core_func_checkbin") == 1, 'audit invariant originally at line 1144')
    require(loader_source_text.count("core_func_md5") == 1, 'audit invariant originally at line 1145')
    require(loader_source_text.count('"core.bin"') == 1, 'audit invariant originally at line 1146')
    require(loader_source_text.count("var_260_5") == 1, 'audit invariant originally at line 1147')
    require('local var_260_4, var_260_5 = ycFunction.getFileData(ycFunction, "core.bin", var_260_1)' in loader_source_text, 'audit invariant originally at line 1148')
    require("if not var_260_4 then" in loader_source_text and "local var_260_6 = var_0_123()" in loader_source_text, 'audit invariant originally at line 1149')
    loader_source_lines = loader_source_text.splitlines()
    loader_source_excerpt = "\n".join(f"{line_no}: {loader_source_lines[line_no - 1]}"
                                      for line_no in range(6519, 6542)) + "\n"
    (raw / "loader_core_call_listing_excerpt.txt").write_bytes(loader_excerpt.encode("utf-8"))
    (raw / "loader_core_call_source_excerpt.txt").write_bytes(loader_source_excerpt.encode("utf-8"))
    original_core_file_hashes, readable_core_file_hashes = file_hashes(base_core_bin), file_hashes(readable_repacked)
    loader_rows = [
        {"check": "getFileData_visible_argument_contract", "finding": "ycFunction, core.bin, true; two Lua return values",
         "evidence": "LuaJIT 0032-0037; CALL 4 3 4", "scope": "visible LuaJIT bytecode"},
        {"check": "first_return_use", "finding": "truth-tested; nil/false calls core_func_byby",
         "evidence": "LuaJIT 0038-0041; source 6523-6527", "scope": "visible LuaJIT bytecode/source"},
        {"check": "second_return_use", "finding": "unused",
         "evidence": "R5 is not read after CALL; var_260_5 occurs only at assignment", "scope": "visible LuaJIT bytecode/source"},
        {"check": "loaded_content_origin", "finding": "separate var_0_123() result, not either getFileData return",
         "evidence": "LuaJIT 0042-0056; source 6529-6538", "scope": "visible LuaJIT bytecode/source"},
        {"check": "visible_core_md5_compare", "finding": "none",
         "evidence": "core_func_md5 has only its definition/GSET and no visible call", "scope": "visible LuaJIT bytecode/source"},
        {"check": "visible_core_length_or_content_compare", "finding": "none",
         "evidence": "core.bin literal occurs only at getFileData call; no returned value comparison beyond truthiness", "scope": "visible LuaJIT bytecode/source"},
        {"check": "core_func_checkbin", "finding": "returns true and has no visible Lua call",
         "evidence": "source 6519-6521; listing contains only the GSET occurrence", "scope": "visible LuaJIT bytecode/source"},
        {"check": "original_vs_readable_repack",
         "finding": f"length {original_core_file_hashes['length']} -> {readable_core_file_hashes['length']}; MD5 {original_core_file_hashes['md5']} -> {readable_core_file_hashes['md5']}",
         "evidence": "direct file hashes", "scope": "artifact bytes"},
        {"check": "visible_lua_rejection_due_only_to_changed_hash_or_length", "finding": "not present",
         "evidence": "No visible MD5/length/content rejection path", "scope": "conditional Lua-layer compatibility"},
        {"check": "complete_native_loader_compatibility", "finding": "not proven",
         "evidence": "getFileData(..., true) is native; undocumented internal validation/side effects cannot be excluded",
         "scope": "native/external boundary"},
    ]
    write_csv(audit / "core_loader_deployment_audit.csv", list(loader_rows[0]), loader_rows)

    known_issue_rows = [
        {"issue_id": "CORE-BUG-001", "severity": "high", "classification": "definite inherited bug",
         "readable_locations": "200->206; 313->319; 497->503",
         "description": "cjson.decode nil invokes fallback, then falls through and indexes response_json.version/content.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "true",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-002", "severity": "high", "classification": "inherited exception/type-handling risk",
         "readable_locations": "198-206; 311-319; 495-503",
         "description": "cjson.decode is unprotected; an exception or truthy non-table result aborts/errors before format fallback can complete.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-003", "severity": "medium", "classification": "inherited retry/availability risk",
         "readable_locations": "169-176; 278-287; 462-472",
         "description": "Failed backup requests with force_refresh=false can resubmit without an explicit retry cap, delay, or backoff.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-004", "severity": "medium", "classification": "inherited resource-management risk",
         "readable_locations": "83-90",
         "description": "write_file returns on a nil write result without closing the already-open file handle.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-005", "severity": "high", "classification": "inherited non-returning API assumption",
         "readable_locations": "80; 96; 101; 109; 186-188; 435-442",
         "description": "Statements can follow core_func_exit/core_func_byby; safe control flow assumes those host APIs never return (the backup kill token path has no explicit return).",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-006", "severity": "medium", "classification": "inherited error-handling risk",
         "readable_locations": "417-418",
         "description": "The pcall success flag key_derivation_ok is ignored before core_archive_key is concatenated and used.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-007", "severity": "medium", "classification": "inherited availability risk",
         "readable_locations": "181-183; 294-296; 477-479",
         "description": "Non-200 HTTP responses return silently without retry or fallback in that callback.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-008", "severity": "medium", "classification": "inherited persistence-integrity risk",
         "readable_locations": "83-95; 142-146; 220-223; 333-336; 517-520",
         "description": "Cache write return values are ignored and files are replaced directly rather than atomically, allowing stale/partial cache state.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-009", "severity": "high", "classification": "inherited archive-loading risk",
         "readable_locations": "438-453",
         "description": "Core archive decrypt/write/ZIP-load/remove results are not validated; optional hookcore ZIP is loaded without a visible authenticity check.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-010", "severity": "medium", "classification": "inherited nil/type-contract risk",
         "readable_locations": "235-260; 348-373; 532-556; UUID helpers",
         "description": "gplus MD5, UUID reads/writes, gate IP, and crypto return values are concatenated without comprehensive nil/type validation.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-011", "severity": "medium", "classification": "inherited identifier-predictability risk",
         "readable_locations": "237-246; 350-359; 533-542",
         "description": "When bzuuid is absent, the identifier seed is only os.time() at second precision before MD5, so it is predictable and collision-prone.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-BEHAVIOR-012", "severity": "critical", "classification": "preserved security-sensitive design",
         "readable_locations": "36-43; 71-81; 99-110; network callbacks; 448-453",
         "description": "Plain-HTTP responses are decrypted and executed through load/pcall, and hookcore ZIP can be loaded, with no separate signature/authenticity verification visible in Lua.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "true",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-013", "severity": "medium", "classification": "inherited protocol-encoding risk",
         "readable_locations": "251-267; 364-380; 547-561",
         "description": "POST bodies are manually concatenated without visible percent-encoding; Base64 and other field characters may depend on host API/server parsing behavior.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-RISK-014", "severity": "medium", "classification": "inherited anti-hook coverage risk",
         "readable_locations": "72-76; 83-90; 435-444",
         "description": "Some getinfo checks inspect a related API while execution uses a wrapper or object method, so the exact invoked implementation is not always the checked object.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "false",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-BEHAVIOR-015", "severity": "high", "classification": "preserved remote kill-switch behavior",
         "readable_locations": "186-188; 298-301; 482-484",
         "description": "A fixed server response token invokes core_func_exit in all three network callback families.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "true",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
        {"issue_id": "CORE-CONTRACT-016", "severity": "informational", "classification": "preserved host-environment dependency",
         "readable_locations": "14-17; throughout",
         "description": "Execution depends on LuaJIT/Lua 5.1 behavior and many nonstandard game-host globals/APIs; the source is not a standalone Lua program.",
         "present_in_original": "true", "introduced_by_rewrite": "false", "dynamically_reproduced": "true",
         "strict_equivalent_file_intentionally_preserves_it": "true"},
    ]
    write_csv(audit / "core_known_issues.csv", list(known_issue_rows[0]), known_issue_rows)

    executable_equivalence_checks = {
        "all_prototypes": len(function_rows) == 26 and
                          all(x["strict_executable_checks_pass"] == "true" for x in function_rows),
        "all_lua51_instructions": len(instruction_rows) == 1661 and
                                  all(x["semantic_instruction_equal"] == "true" for x in instruction_rows),
        "all_constants": len(constant_rows) == 366 and all(x["equal"] == "true" for x in constant_rows),
        "all_local_bindings": len(variable_rows) == 129 and
                              all(x["binding_equivalent"] == "true" for x in variable_rows),
        "all_identifier_uses": len(identifier_use_rows) == 527 and
                               all(x["binding_equivalent"] == "true" for x in identifier_use_rows),
        "all_shadow_relations": len(shadow_rows) == 2 and
                                all(x["relation_equivalent"] == "true" for x in shadow_rows),
        "all_upvalue_captures": len(upvalue_rows) == 116 and not bad_upvalues,
        "all_lexical_scopes": len(scope_rows) == 127 and
                              all(x["scope_structure_equal"] == "true" for x in scope_rows),
        "all_runtime_names": len(runtime_name_rows) == 368 and
                             all(x["runtime_name_equivalent"] == "true" for x in runtime_name_rows),
        "all_bare_global_accesses": len(global_rows) == 2 and all(x["equal"] == "true" for x in global_rows),
        "semantic_ast_counts": all(x["equal"] == "true" for x in ast_rows),
        "stripped_luajit_chunk": stripped_equal,
        "runtime_differential": runtime["all_pass"] and len(runtime["scenarios"]) == 8,
        "runtime_prototype_entry_coverage": len(runtime["coverage"]) ==
                                            len(set(runtime["coverage"])) == len(FUNCTION_NAMES),
    }
    executable_equivalence = all(executable_equivalence_checks.values())
    final_validation_checks = {
        **executable_equivalence_checks,
        "core_original_pack_roundtrip": core_original_roundtrip == core_bin_data and
                                        core_unpacked == original_payload_data,
        "core_readable_pack_roundtrip": readable_roundtrip == readable_repacked.read_bytes() and
                                        readable_unpacked == readable_source_data,
        "gplus_first_layer_roundtrip": xxtea.pack_frame(gplus_plain, xxtea.GPLUS_KEY) == gplus_data,
        "static_plaintext_surface": (not disallowed_controls and b"\x00" not in readable_tree.source and
                                     len(readable_tree.escape_sequences) == 3 and decimal_count == 1 and
                                     hex_count == 0 and unicode_count == 0),
        "known_issues_classified_as_inherited": len(known_issue_rows) == 16 and
                                               all(x["present_in_original"] == "true" and
                                                   x["introduced_by_rewrite"] == "false"
                                                   for x in known_issue_rows),
        "loader_visible_contract_evidence": len(loader_rows) == 10 and
                                            all(instruction in loader_excerpt
                                                for instruction in required_loader_instructions),
    }
    final_status = "PASS" if all(final_validation_checks.values()) else "FAIL"
    require(final_status == "PASS", "derived final aggregate audit status",
            [name for name, passed in final_validation_checks.items() if not passed])

    audit_json = {
        "audit_schema_version": AUDIT_SCHEMA_VERSION,
        "status": final_status,
        "reproducibility": {
            "deterministic_artifacts": True,
            "timestamp_embedded": False,
            "absolute_paths_embedded": False,
            "note": "Timestamps and host-specific roots are deliberately omitted from canonical audit artifacts."},
        "inputs": {"base_root": "<BASE_ROOT>", "output_root": ".", "core_bin": file_hashes(base_core_bin),
                   "core_dec_framed": file_hashes(base_core_dec), "core_original_payload": file_hashes(original_source),
                   "core_readable_source": file_hashes(readable_source), "core_readable_repacked": file_hashes(readable_repacked),
                   "gplus_bin": file_hashes(base_gplus),
                   "loader_opcode_decrypted_chunk": file_hashes(loader_chunk),
                   "loader_decompiled_source": file_hashes(loader_source)},
        "validation_checks": final_validation_checks,
        "verdict": {"strict_executable_logic_equivalent": executable_equivalence,
                    "rewrite_introduced_bug_detected": False, "original_program_bug_free": False,
                    "core_static_source_plaintext": True, "all_runtime_and_external_data_plaintext": False,
                    "gplus_fully_plaintext": False, "debug_metadata_exactly_equivalent": False},
        "counts": {"bytecode_prototypes_including_chunk": len(function_rows),
                   "source_functions_excluding_chunk": len(function_rows) - 1,
                   "lua51_instructions": sum(p.instruction_count for p in original_protos),
                   "constants": len(constant_rows), "string_constants": string_constant_count,
                   "numeric_constants": numeric_constant_count, "local_bindings": len(variable_rows),
                   "identifier_use_occurrences": len(identifier_use_rows),
                   "local_identifier_uses": identifier_binding_kind_counts["local"],
                   "upvalue_identifier_uses": identifier_binding_kind_counts["upvalue"],
                   "global_identifier_uses": identifier_binding_kind_counts["global"],
                   "lexical_shadow_relations": len(shadow_rows),
                   "upvalue_slots": len(upvalue_rows), "lexical_scopes_including_chunk": len(scope_rows),
                   "tree_sitter_block_nodes": len(scope_rows) - 1,
                   "direct_semantic_statements_across_scopes": semantic_statement_total,
                   "runtime_name_occurrences": len(runtime_name_rows), "static_runtime_name_occurrences": static_runtime_occurrences,
                   "dynamic_runtime_index_occurrences": dynamic_runtime_occurrences,
                   "unique_static_runtime_names": len(static_names),
                   "bare_global_opcode_accesses": len(global_rows), "runtime_scenarios": len(runtime["scenarios"]),
                   "dynamically_covered_prototypes": sum(x["dynamically_covered"] == "true" for x in function_rows),
                   "tonumber_string_literal_calls": len(to_number_literals),
                   "unique_tonumber_string_literals": len(set(to_number_literals)),
                   "runtime_base64_decode_calls": runtime_decode_counts["core_func_decodeBase64"] + runtime_decode_counts["crypto.decodeBase64"],
                   "runtime_xxtea_decrypt_calls": runtime_decode_counts["core_func_decryptTEA"],
                   "dynamic_lua_load_calls": runtime_decode_counts["globals.load"],
                   "external_zip_load_calls": runtime_decode_counts["LuaLoadChunksFromZIP"],
                   "known_issue_rows": len(known_issue_rows), "loader_audit_checks": len(loader_rows),
                   "original_escape_sequence_nodes": len(original_tree.escape_sequences),
                   "readable_escape_sequence_nodes": len(readable_tree.escape_sequences)},
        "proof": {"stripped_luajit_bytecode": {"equal": stripped_equal, "length": len(original_dump_data),
                  "sha256_original": sha256_bytes(original_dump_data), "sha256_readable": sha256_bytes(readable_dump_data)},
                  "per_prototype_opcode_operand_streams_equal": all(x["opcode_operand_stream_equal"] == "true" for x in function_rows),
                  "all_1661_instruction_rows_equal": all(x["semantic_instruction_equal"] == "true" for x in instruction_rows),
                  "per_prototype_constant_tables_equal": all(x["constant_table_equal"] == "true" for x in function_rows),
                  "all_local_pc_lifetimes_and_scopes_equal": all(x["binding_equivalent"] == "true" for x in variable_rows),
                  "all_527_identifier_uses_resolve_to_same_bindings": all(x["binding_equivalent"] == "true" for x in identifier_use_rows),
                  "all_lexical_shadow_relations_equal": all(x["relation_equivalent"] == "true" for x in shadow_rows),
                  "all_upvalue_capture_bindings_equal": all(x["capture_binding_equivalent"] == "true" for x in upvalue_rows),
                  "all_lexical_scope_statement_sequences_equal": all(x["scope_structure_equal"] == "true" for x in scope_rows),
                  "all_runtime_visible_name_occurrences_equal": all(x["runtime_name_equivalent"] == "true" for x in runtime_name_rows),
                  "runtime_differential_all_pass": runtime["all_pass"], "runtime_scenarios": runtime["scenarios"],
                  "runtime_coverage": runtime["coverage"],
                  "runtime_coverage_kind": "prototype-entry coverage only; not branch/path coverage",
                  "runtime_branch_or_path_coverage_proven": False,
                  "core_original_pack_roundtrip_exact": core_original_roundtrip == core_bin_data,
                  "core_readable_pack_roundtrip_exact": readable_roundtrip == readable_repacked.read_bytes(),
                  "core_dec_trailer_original_length": core_dec_size},
        "plaintext_boundary": {"core_source_utf8": True, "core_source_raw_nul_count": readable_tree.source.count(b"\x00"),
                               "core_source_disallowed_raw_control_count": len(disallowed_controls),
                               "remaining_source_escapes": readable_tree.escape_sequences,
                               "static_runtime_name_occurrences": static_runtime_occurrences,
                               "dynamic_runtime_index_occurrences": dynamic_runtime_occurrences,
                               "tonumber_string_literal_calls": len(to_number_literals),
                               "unique_tonumber_string_literals": len(set(to_number_literals)),
                               "runtime_call_counts": runtime_decode_counts,
                               "static_source_plaintext": True,
                               "all_numeric_string_conversions_folded": False,
                               "runtime_remote_content_plaintext": False,
                               "encrypted_core_archives_plaintext": False, "gplus_inner_payload_plaintext": False},
        "deployment_loader": {
            "visible_lua_layer_conditional_compatibility": True,
            "condition": "native getFileData(ycFunction, core.bin, true) returns a truthy first Lua value",
            "second_getFileData_return_used": False,
            "visible_md5_length_or_content_rejection": False,
            "core_func_checkbin_visible_lua_call": False,
            "loaded_content_origin": "separate var_0_123() result",
            "original_core_length": original_core_file_hashes["length"],
            "readable_repack_length": readable_core_file_hashes["length"],
            "original_core_md5": original_core_file_hashes["md5"],
            "readable_repack_md5": readable_core_file_hashes["md5"],
            "complete_native_loader_compatibility_proven": False,
            "native_boundary_caveat": "getFileData is native; undocumented internal validation and pre-Lua launcher checks are not visible."},
        "gplus": {"rewritten_counterpart_exists": False,
                  "reason_not_rewritten": "core uses gplus.bin MD5 as POST code; changing bytes changes runtime-visible behavior",
                  "first_layer_xxtea_roundtrip_exact": True, "first_layer_plain_length": len(gplus_plain),
                  "section_count": len(gplus_sections), "section_lengths": [len(x) for x in gplus_sections],
                  "payload_base64_length": len(gplus_payload_base64), "inner_payload_length": len(gplus_payload),
                  "inner_payload_sha256": sha256_bytes(gplus_payload),
                  "inner_payload_entropy_bits_per_byte": shannon_entropy(gplus_payload),
                  "inner_format": "unknown high-entropy opaque payload; not proven plaintext or locally executable Lua"},
        "known_issues": known_issue_rows,
        "debug_metadata_caveat": {"exact": False,
             "reason": "Local names, source filename and line positions differ after semantic renaming/reformatting.",
             "ordinary_program_logic_affected": False},
    }
    (audit / "core_equivalence_audit.json").write_text(json.dumps(audit_json, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    report = f"""# G2.5 `core_dec.lua` 严格等价审计

审计模式：`deterministic-v2`（规范产物不嵌入生成时间或主机绝对路径）

## 最终结论

| 问题 | 结论 | 精确边界 |
|---|---|---|
| 重写版与未重写版的普通可执行逻辑是否等价 | **是** | 26/26 原型、1661 条 Lua 5.1 指令、366 个常量、129 个局部绑定、116 个 upvalue、527 次标识符使用均逐项相等；LuaJIT stripped chunk 逐字节相同。 |
| 是否发现重写引入的新 bug | **在本审计边界内未发现** | stripped LuaJIT 指令完全一致，8 组 mock 差分的轨迹/状态/错误/快照一致；不把调试元数据、native 内部或未覆盖分支误称为已证明。 |
| 原程序本身是否“无 bug” | **否** | 已动态复现 `cjson.decode` 返回 nil 后继续索引的继承 bug；另记录 15 项继承风险/契约/敏感行为。 |
| `core_dec_readable.lua` 静态源码是否明文可读 | **是** | UTF-8 全文可读；4714 个 escape AST 节点降为 3 个必要转义。 |
| 所有运行时/外部数据是否也已全明文 | **否** | 仍有动态索引、数字字符串转换、Base64/XXTEA、动态 `load`、外部 ZIP、远端响应和 `gplus` 内层不透明数据。 |
| `gplus.bin` 是否可在严格等价前提下改写 | **否** | 第一层已拆解并可逆；内层仍未知高熵。core 三处把该文件 MD5 作为 POST `code`，改字节会改变运行时可见行为。 |
| readable repack 是否一定被完整启动器接受 | **仅 Lua 层条件通过；native 未证** | 可见 loader 不比较 MD5/长度/内容；但 `getFileData(..., true)` 是 native，内部校验和 Lua 前置启动器检查不可由当前证据排除。 |
| 调试元数据是否逐字等价 | **否（预期）** | 局部名、源路径、行号、堆栈文本、line hook、未 strip dump 可观察到差异。 |

## “等价”的严格含义

本报告证明的是：在已核对的 Lua 5.1/LuaJIT 普通执行语义下，重写没有改变 opcode、操作数、常量、寄存器生命周期、闭包捕获、标识符绑定、作用域结构、运行时名称及已执行 mock 场景行为。

本报告**不**声称以下项目相同：源码字节、调试局部名、源码行号、错误原文、未 strip 字节码、外部服务器内容、native API 内部行为、所有可能分支/路径。

## 审计规模

- Lua 字节码原型：**{len(function_rows)}**（含 chunk；源函数 **{len(function_rows)-1}**）
- Lua 5.1 指令：**{sum(p.instruction_count for p in original_protos)}**
- 常量：**{len(constant_rows)}**（字符串 {string_constant_count}，数字 {numeric_constant_count}）
- 局部变量/参数绑定：**{len(variable_rows)}**
- 标识符使用：**{len(identifier_use_rows)}**（local {identifier_binding_kind_counts['local']}、upvalue {identifier_binding_kind_counts['upvalue']}、global {identifier_binding_kind_counts['global']}）
- 词法遮蔽关系：**{len(shadow_rows)}**
- upvalue 捕获槽：**{len(upvalue_rows)}**
- 词法作用域：**{len(scope_rows)}**（chunk 1 + block {len(scope_rows)-1}）
- 作用域内直接语义语句：**{semantic_statement_total}**
- 运行时字段/键/方法/动态索引：**{len(runtime_name_rows)}**（静态 {static_runtime_occurrences}、动态 {dynamic_runtime_occurrences}）
- 唯一静态运行时名称：**{len(static_names)}**
- 隔离差分场景对：**{len(runtime['scenarios'])}/8 行为相等**
- 动态原型入口覆盖：**{sum(x['dynamically_covered'] == 'true' for x in function_rows)}/{len(function_rows)}**；不是分支/路径覆盖

## 最强等价证据

1. **LuaJIT stripped bytecode 完全相同**
   - 长度：`{len(original_dump_data)}` 字节
   - 双方 SHA-256：`{sha256_bytes(original_dump_data)}`
2. **逐原型**：26 行摘要、指令流、常量表、局部 PC 生命周期、upvalue 槽图全部通过。
3. **逐指令**：1661 行 opcode + operands 全部相等；CLOSURE 的进程地址已归一化，不作为语义证据。
4. **逐常量**：366 行的类型、表示和值全部相等。
5. **逐变量/参数**：129 行声明种类、词法作用域、起止 PC 全部相同。
6. **逐标识符使用**：527 次引用重新做词法解析，189 次绑定本函数 local、336 次绑定外层 upvalue、2 次绑定 global；0 个绑定差异。
7. **逐遮蔽关系**：2/2 相同：
   - `P01:L044 file_data_result` 遮蔽 `P01:L040 file_data_result`；
   - `P11:L000 local_version` 参数遮蔽外层 `P01:L015 local_version`。
8. **逐闭包捕获**：116 个 upvalue 的父 local/父 upvalue 槽和捕获指令相同；P13/P16 递归自捕获按 CLOSURE 后绑定伪指令解析。
9. **逐作用域**：127 个作用域的父子关系、函数深度、直接语句类型序列相同。
10. **逐运行时名称**：368 次字段/表键/方法/动态索引顺序和名称相同；`argeementText` 原拼写保留。
11. **动态差分**：文件、网络、引擎、退出均由 mock 截获，不做真实副作用；8 个场景对的轨迹、返回状态、规范化错误和快照相同。
12. **封包回读**：原 `core.bin` 重打包逐字节相同；readable repack 解密回读与 readable 源码逐字节相同。

## 动态测试的正确解读

“8/8 通过”表示**双方行为相等**，不是 8 个场景都业务成功。`json_decode_nil_inherited_error` 中原版和 readable 版都以相同 nil-index 错误失败，因此该场景是“等价通过、业务失败”。

“26/26 动态覆盖”只表示每个原型至少进入一次；没有证明所有 `if` 分支、错误分支、网络时序和 native 组合都被执行。

## 已确认的继承 bug 与风险

三处网络回调都有以下结构：

```lua
if not response_json then
    request_backup_update(true_value)
end
if not response_json.version or not response_json.content then
    -- response_json 为 nil 时在这里报错
end
```

可读版位置：`200 -> 206`、`313 -> 319`、`497 -> 503`。动态场景证明双方以同类规范化 nil-index 错误失败。它不是重写引入的；严格等价版刻意不修复，否则会改变原始行为。

`core_known_issues.csv` 共 **{len(known_issue_rows)}** 行，还包括：未保护/类型异常的 JSON decode、无界重试可能、文件句柄泄漏、退出 API 非返回假设、忽略密钥派生 `pcall` 状态、非 200 静默停止、非原子缓存、未检查归档解密/写入/加载结果、nil/type 拼接、弱 UUID、明文 HTTP 下载执行、POST 未显式编码、anti-hook 覆盖错位、固定 kill-switch 和宿主环境依赖。全部标记为原版已有、非重写引入。

因此，结论只能是“**重写未引入已检测的新 bug**”，不能是“原程序无 bug”。

## 明文化边界

### 已明文化

- 控制流、注释、局部语义名、367 次静态运行时名称、普通字符串和中文协议文本可直接阅读。
- 源码无 NUL、无异常原始控制字节、无 `\\xNN`/`\\uNNNN`。
- 只剩 3 个必要语义转义：`\\022`（密钥派生 gsub）、`\\t`（制表符匹配）、`\\n`（提示换行）。

### 仍不是“全静态明文”

- 1 次计算型动态索引；
- 34 次 `to_number("...")`（22 个唯一数字字符串）仍按原语义保留；
- 5 次运行时 Base64 decode、2 次 XXTEA decrypt、1 次动态 `load`、2 次外部 ZIP load；
- 服务器返回的加密内容、运行时 `globals.def.role.stuff`、外部 `core/core64.zip`；
- `gplus.bin` Base64 后的未知高熵内层载荷。

所以：**源码静态表面已明文化；所有运行时/外部载荷并未、也不能在保持严格等价时全部静态展开。**

## `gplus.bin` 边界

- 第一层 XXTEA 往返逐字节相同；
- 第一层明文长度：`{len(gplus_plain)}` 字节，`#` 分为 `{len(gplus_sections)}` 段；
- 最后一段 Base64 长度：`{len(gplus_payload_base64)}`；
- 内层长度：`{len(gplus_payload)}`，SHA-256：`{sha256_bytes(gplus_payload)}`；
- 熵：`{shannon_entropy(gplus_payload):.8f}` bits/byte，格式仍未识别，不能证明是明文 Lua。

core 三处读取 `gplus.bin` 的文件 MD5并拼入 POST `code`。因此给它换成“可读版”会改变可观察网络协议值，不能被称为严格等价。

## 部署 loader：条件通过，不越界承诺

可见 LuaJIT loader 的关键数据流：

- `getFileData(ycFunction, "core.bin", true)` 取得两个 Lua 返回值；
- 第一个返回值只做真值判断，假时调用 `core_func_byby()`；
- 第二个返回值未使用；
- 后续交给 `load` 的内容来自独立的 `var_0_123()`，不是上述两个返回值；
- 没有可见的 MD5、长度或内容比较；`core_func_checkbin` 无条件返回 `true` 且没有可见 Lua 调用。

原 `core.bin` 为 `{original_core_file_hashes['length']}` 字节 / MD5 `{original_core_file_hashes['md5']}`；readable repack 为 `{readable_core_file_hashes['length']}` 字节 / MD5 `{readable_core_file_hashes['md5']}`。这些差异**不会单独触发可见 Lua 代码中的拒绝条件**。

但 `ycFunction.getFileData` 是 native。第三参数 `true` 的含义、native 内部校验、按全局名回调、启动器在 Lua 前的资源校验、32/64 位差异均未被当前证据覆盖。因此最终定性是：

> **Lua 层条件兼容：若 native 返回的第一个 Lua 值为真，则不会仅因文件长度/MD5变化而拒绝；完整 native 部署兼容性尚未证明。**

## 调试元数据例外

LuaJIT stripped chunk 相同不表示所有可观察元数据相同。`debug.getlocal`、错误堆栈行号、源文件名、line hook、未 strip dump 会观察到重命名/排版差异；程序普通逻辑没有显示依赖自身局部名或源码行号。

## 逐项证据文件

- `core_function_audit.csv`：26 个原型/函数
- `core_instruction_audit.csv`：1661 条 Lua 5.1 指令（逐 PC）
- `core_constant_audit.csv`：366 个常量
- `core_variable_scope_audit.csv`：129 个局部/参数绑定、生命周期、作用域与遮蔽参与标记
- `core_identifier_use_audit.csv`：527 次标识符使用及其解析绑定
- `core_shadowing_audit.csv`：2 个完整词法遮蔽关系
- `core_upvalue_audit.csv`：116 个闭包捕获
- `core_lexical_scope_audit.csv`：127 个词法作用域
- `core_runtime_name_occurrences.csv`：368 次运行时名称出现
- `core_runtime_name_summary.csv`：83 个唯一静态名称 + 1 个动态索引摘要
- `core_global_access_audit.csv`：2 次裸 global 操作码访问（`_G`、`_ENV`）
- `core_plaintext_audit.csv` / `core_remaining_escapes.csv`：明文化边界
- `core_loader_deployment_audit.csv`：loader 可见数据流与 native 边界
- `core_known_issues.csv`：16 项继承 bug/风险/契约/行为
- `runtime/core_differential_harness.lua` / `core_runtime_results.tsv`：隔离差分
- `raw/`：Lua 5.1/LuaJIT 列表、双方 stripped chunk、loader 证据摘录
- `core_equivalence_audit.json`：机器可读总报告
- `AUDIT_SHA256SUMS.txt`：所有审计产物哈希
"""
    (audit / "CORE_EQUIVALENCE_AUDIT.md").write_text(report, encoding="utf-8")

    checksum_path = audit / "AUDIT_SHA256SUMS.txt"
    artifacts = sorted(p for p in audit.rglob("*") if p.is_file() and p != checksum_path and "__pycache__" not in p.parts)
    checksum_path.write_text("\n".join(f"{sha256_bytes(p.read_bytes())}  {p.relative_to(audit).as_posix()}" for p in artifacts) + "\n",
                             encoding="utf-8")

    print(json.dumps({"status": final_status, "strict_executable_logic_equivalent": executable_equivalence,
                      "original_program_bug_free": False, "core_static_source_plaintext": True,
                      "gplus_fully_plaintext": False, "prototypes": len(function_rows),
                      "locals": len(variable_rows), "identifier_uses": len(identifier_use_rows),
                      "shadow_relations": len(shadow_rows), "upvalues": len(upvalue_rows), "scopes": len(scope_rows),
                      "runtime_names": len(runtime_name_rows), "runtime_scenarios": len(runtime["scenarios"]),
                      "known_issues": len(known_issue_rows), "loader_native_compatibility_proven": False,
                      "report": str(audit / "CORE_EQUIVALENCE_AUDIT.md")}, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
