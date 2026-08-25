-- Differential runtime harness for core_dec_original_payload.lua vs core_dec_readable.lua.
-- All engine, filesystem, network and process APIs are mocked. No real network or launcher code is executed.

local original_path = assert(arg[1], "missing original source path")
local readable_path = assert(arg[2], "missing readable source path")

local function clean_field(value)
    value = tostring(value or "")
    value = value:gsub("\\", "\\\\"):gsub("\t", "\\t"):gsub("\r", "\\r"):gsub("\n", "\\n")
    return value
end

local function scalar(value)
    local kind = type(value)
    if kind == "nil" then
        return "nil"
    elseif kind == "boolean" or kind == "number" then
        return tostring(value)
    elseif kind == "string" then
        return string.format("%q", value)
    end
    return "<" .. kind .. ">"
end

local function copy_array(values)
    local result = {}
    for index = 1, #values do
        local item = values[index]
        local copy = {}
        for key, value in pairs(item) do
            copy[key] = value
        end
        result[index] = copy
    end
    return result
end

local scenarios = {
    {
        name = "missing_core_archive",
        core_exists = false,
        agreement = true,
        responses = {},
    },
    {
        name = "startup_remote_success",
        core_exists = true,
        agreement = true,
        responses = {
            { event = "completed", status = 200, body = "JSON_REMOTE" },
        },
    },
    {
        name = "main_ok_then_primary_remote",
        core_exists = true,
        responses = {
            { event = "completed", status = 200, body = "OK" },
            { event = "completed", status = 200, body = "JSON_REMOTE" },
        },
    },
    {
        name = "main_failed_then_backup_remote",
        core_exists = true,
        responses = {
            { event = "failed", status = 0, body = "" },
            { event = "completed", status = 200, body = "JSON_REMOTE" },
        },
    },
    {
        name = "cached_code_then_ok",
        core_exists = true,
        cache_exists = true,
        responses = {
            { event = "completed", status = 200, body = "OK" },
        },
    },
    {
        name = "json_decode_nil_inherited_error",
        core_exists = true,
        initially_loaded = true,
        responses = {
            { event = "completed", status = 200, body = "JSON_NIL" },
            { event = "completed", status = 200, body = "OK" },
        },
    },
    {
        name = "kill_switch",
        core_exists = true,
        initially_loaded = true,
        responses = {
            { event = "completed", status = 200, body = "u7bTrcq508Ow19bttcfCvMb3" },
        },
    },
    {
        name = "arm64_with_hook_archive",
        core_exists = true,
        hook_exists = true,
        arm64 = true,
        initially_loaded = true,
        responses = {
            { event = "completed", status = 200, body = "OK" },
        },
    },
}

local function make_environment(config, coverage, target_basename)
    local trace = {}
    local response_queue = copy_array(config.responses or {})
    local response_index = 0
    local writes = {}

    local function emit(name, ...)
        local fields = { name }
        for index = 1, select("#", ...) do
            fields[#fields + 1] = scalar(select(index, ...))
        end
        trace[#trace + 1] = table.concat(fields, "|")
    end

    local env = {}
    env._G = env
    env._ENV = env
    env.assert = assert
    env.error = error
    env.ipairs = ipairs
    env.next = next
    env.pairs = pairs
    env.pcall = pcall
    env.select = select
    env.tonumber = tonumber
    env.tostring = tostring
    env.type = type
    env.unpack = unpack
    env.math = math
    env.string = string
    env.table = table
    env.print = function(...)
        emit("print", ...)
    end
    env.getinfo = function(target)
        emit("getinfo", type(target))
        return { what = "C" }
    end

    env.def = {
        showUserAgreement = config.agreement or false,
        debugkey = true,
        gateIP = "127.0.0.1",
        role = {
            stuff = "U1RVRkY=",
            helperID = "before",
        },
    }
    env.device = { writablePath = "W/" }
    env.USE_ARM64 = config.arm64 or false
    env.isloaded = config.initially_loaded or false
    env.g_data = {
        login = {
            localLastSer = { zonename = "测试区" },
        },
    }

    env.os = {
        date = function(format)
            emit("os.date", format)
            return "202607"
        end,
        time = function()
            emit("os.time")
            return 1783662875
        end,
        remove = function(path)
            emit("os.remove", path)
            return true
        end,
        exit = function()
            emit("os.exit")
        end,
    }

    local function path_ends(path, suffix)
        return type(path) == "string" and path:sub(-#suffix) == suffix
    end

    env.io = {
        exists = function(path)
            local result
            if path == "W/cache/ao/" or path == "W/res/" then
                result = true
            elseif path_ends(path, "hookcore.zip") or path_ends(path, "hookcore64.zip") then
                result = config.hook_exists or false
            elseif path_ends(path, "core.zip") or path_ends(path, "core64.zip") then
                result = config.core_exists ~= false
            elseif path_ends(path, ".bin") or path_ends(path, ".version") then
                result = config.cache_exists or false
            elseif path_ends(path, "bzuuid") then
                result = config.uuid_exists or false
            else
                result = false
            end
            emit("io.exists", path, result)
            return result
        end,
        readfile = function(path)
            local value
            if path_ends(path, "core.zip") or path_ends(path, "core64.zip") then
                value = "ENCRYPTED_ARCHIVE"
            elseif path_ends(path, ".version") then
                value = "cached-version"
            elseif path_ends(path, ".bin") then
                value = "ENC_CACHE"
            elseif path_ends(path, "bzuuid") then
                value = "EXISTING_UUID"
            end
            emit("io.readfile", path, value)
            return value
        end,
        open = function(path, mode)
            emit("io.open", path, mode)
            local handle = {}
            handle.write = function(self, data)
                emit("file.write", path, data)
                writes[path] = data
                return true
            end
            return handle
        end,
        close = function(handle)
            emit("io.close", type(handle))
            return true
        end,
        write = function()
            return true
        end,
    }

    env.ycFunction = {}
    env.ycFunction.mkdir = function(self, path)
        emit("yc.mkdir", path)
        return true
    end
    env.ycFunction.getFileData = function(self, path, binary)
        emit("yc.getFileData", path, binary)
        return "GPLUS_DATA", "4519f09f94ae7ab7c4c9a4bea676ad02"
    end

    env.crypto = {
        md5 = function(value)
            emit("crypto.md5", value)
            return "MD5<" .. tostring(value) .. ">"
        end,
        encodeBase64 = function(value)
            emit("crypto.encodeBase64", value)
            return "B64<" .. tostring(value) .. ">"
        end,
        decodeBase64 = function(value)
            emit("crypto.decodeBase64", value)
            return "DB64<" .. tostring(value) .. ">"
        end,
    }

    env.core_func_md5 = function(value)
        emit("core_func_md5", value)
        return "COREMD5"
    end
    env.core_func_decodeBase64 = function(value)
        emit("core_func_decodeBase64", value)
        return "DECODED<" .. tostring(value) .. ">"
    end
    env.core_func_decryptTEA = function(data, key)
        emit("core_func_decryptTEA", data, key)
        if data == "DECODED<ENC_REMOTE>" then
            return "REMOTE_SOURCE"
        elseif data == "DECODED<ENC_CACHE>" then
            return "CACHE_SOURCE"
        end
        return "DECRYPTED_ARCHIVE"
    end
    env.core_func_writefile = function(path, data)
        emit("core_func_writefile", path, data)
        writes[path] = data
        return true
    end
    env.core_func_exit = function()
        emit("core_func_exit")
    end
    env.core_func_byby = function(message)
        emit("core_func_byby", message)
    end

    env.load = function(source)
        emit("load", source)
        return function()
            emit("loaded_chunk", source)
            env.isloaded = true
            return "loaded"
        end
    end

    env.require = function(name)
        emit("require", name)
        assert(name == "cjson")
        return {
            decode = function(content)
                emit("cjson.decode", content)
                if content == "JSON_REMOTE" then
                    return { version = "remote-v2", content = "ENC_REMOTE" }
                elseif content == "JSON_NIL" then
                    return nil
                end
                return { version = "other", content = content }
            end,
        }
    end

    env.cc = {
        Crypto = {
            decodeBase64 = function(value)
                return value
            end,
            decryptXXTEA = function(value)
                return value
            end,
        },
        LuaLoadChunksFromZIP = function(path)
            emit("cc.LuaLoadChunksFromZIP", path)
            return true
        end,
    }

    env.an = {
        newMsgbox = function(message, callback, options)
            emit("an.newMsgbox", message, options and options.center, options and options.close)
            callback(1)
        end,
    }
    env.scheduler = {
        performWithDelayGlobal = function(callback, delay)
            emit("scheduler.performWithDelayGlobal", delay)
            callback()
        end,
    }

    env.core_func_createNet = function(callback, url, method)
        emit("net.create", url, method)
        local request = {}
        request.getResponseStatusCode = function(self)
            emit("net.getResponseStatusCode")
            return self._response.status
        end
        request.getResponseData = function(self)
            emit("net.getResponseData")
            return self._response.body
        end
        request.setPOSTData = function(self, data)
            emit("net.setPOSTData", data)
            self._post = data
        end
        request.setTimeout = function(self, timeout)
            emit("net.setTimeout", timeout)
            self._timeout = timeout
        end
        request.start = function(self)
            response_index = response_index + 1
            local response = response_queue[response_index]
                or { event = "completed", status = 200, body = "OK" }
            self._response = response
            emit("net.start", response_index, response.event, response.status, response.body)
            callback({ name = response.event, request = self })
        end
        return request
    end

    local function snapshot()
        local agreement_length = env.argeementText and #env.argeementText or -1
        local write_count = 0
        for _ in pairs(writes) do
            write_count = write_count + 1
        end
        return table.concat({
            scalar(env.def.role.open),
            scalar(env.def.role.helperID),
            scalar(agreement_length),
            scalar(env.isloaded),
            scalar(write_count),
            scalar(response_index),
        }, "|")
    end

    return env, trace, snapshot
end

local function normalize_error(message)
    if message == nil then
        return ""
    end
    message = tostring(message)
    message = message:gsub("^.-:%d+:%s*", "")
    message = message:gsub("local%s+'[^']+'", "local '<renamed>'")
    message = message:gsub("upvalue%s+'[^']+'", "upvalue '<renamed>'")
    message = message:gsub("global%s+'[^']+'", "global '<renamed>'")
    return message
end

local function run_one(path, config, coverage)
    local basename = path:match("[^/\\]+$") or path
    local env, trace, snapshot = make_environment(config, coverage, basename)
    local chunk, load_error = loadfile(path)
    if not chunk then
        return false, load_error, normalize_error(load_error), trace, snapshot()
    end
    setfenv(chunk, env)

    local hook
    if coverage then
        hook = function(event)
            if event ~= "call" then
                return
            end
            local info = debug.getinfo(2, "S")
            if info and info.source and info.source:sub(-#basename) == basename then
                coverage[tostring(info.linedefined) .. ":" .. tostring(info.lastlinedefined)] = true
            end
        end
        debug.sethook(hook, "c")
    end

    local ok, result_or_error = pcall(chunk)
    if ok and env.set_helper then
        local helper_ok, helper_error = pcall(env.set_helper, "helper-after")
        if not helper_ok then
            ok = false
            result_or_error = helper_error
        end
    end
    if hook then
        debug.sethook()
    end
    return ok, ok and "" or tostring(result_or_error), normalize_error(ok and "" or result_or_error), trace, snapshot()
end

local function arrays_equal(left, right)
    if #left ~= #right then
        return false, math.min(#left, #right) + 1
    end
    for index = 1, #left do
        if left[index] ~= right[index] then
            return false, index
        end
    end
    return true, 0
end

local readable_coverage = {}
local all_pass = true
for _, scenario in ipairs(scenarios) do
    local original_ok, original_error, original_normalized, original_trace, original_snapshot =
        run_one(original_path, scenario, nil)
    local readable_ok, readable_error, readable_normalized, readable_trace, readable_snapshot =
        run_one(readable_path, scenario, readable_coverage)
    local trace_equal, trace_diff_index = arrays_equal(original_trace, readable_trace)
    local status_equal = original_ok == readable_ok
    local normalized_error_equal = original_normalized == readable_normalized
    local snapshot_equal = original_snapshot == readable_snapshot
    local passed = trace_equal and status_equal and normalized_error_equal and snapshot_equal
    all_pass = all_pass and passed
    io.write(table.concat({
        "RESULT",
        clean_field(scenario.name),
        tostring(passed),
        tostring(trace_equal),
        tostring(status_equal),
        tostring(normalized_error_equal),
        tostring(snapshot_equal),
        tostring(original_ok),
        tostring(readable_ok),
        tostring(#original_trace),
        tostring(#readable_trace),
        tostring(trace_diff_index),
        clean_field(original_normalized),
        clean_field(readable_normalized),
        clean_field(original_error),
        clean_field(readable_error),
    }, "\t"), "\n")
    if not trace_equal then
        io.write("TRACE_ORIGINAL\t", clean_field(original_trace[trace_diff_index] or "<end>"), "\n")
        io.write("TRACE_READABLE\t", clean_field(readable_trace[trace_diff_index] or "<end>"), "\n")
    end
end

local coverage_keys = {}
for key in pairs(readable_coverage) do
    coverage_keys[#coverage_keys + 1] = key
end
table.sort(coverage_keys, function(left, right)
    local left_start = tonumber(left:match("^(%d+):")) or -1
    local right_start = tonumber(right:match("^(%d+):")) or -1
    return left_start < right_start
end)
local expected_scenario_count = 8
local expected_prototype_count = 26
all_pass = all_pass and #scenarios == expected_scenario_count and #coverage_keys == expected_prototype_count
io.write("COVERAGE\t", table.concat(coverage_keys, ","), "\n")
io.write("ALL_PASS\t", tostring(all_pass), "\n")
if not all_pass then
    os.exit(1)
end


