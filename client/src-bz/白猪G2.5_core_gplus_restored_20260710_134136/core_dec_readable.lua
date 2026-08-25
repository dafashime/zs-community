-- core.bin / core_dec.lua 可读性还原版
-- 仅做可读性改写：解码字符串、恢复缩进、重命名局部变量、规范字段访问。
-- 所有运行时可见的全局名、字段名、常量、控制流和调用顺序均保持不变。
-- 原文件中的 argeementText 拼写错误也刻意保留。

-- 原始混淆器的占位常量；即使未使用，也保留以维持原始字节码结构。
local unused_number_17 = 17
local unused_number_34 = 34
local unused_number_23 = 23
local false_value = 0 == 1
local true_value = not false_value
local nil_value = nil
local empty_string = ""
local globals = _G
local unused_environment = _ENV
local to_number = globals.tonumber
return (function(...)
    -- 可选的用户协议文本。
    if globals.def.showUserAgreement then
        globals.argeementText =
            [=[        一、不得利用本软件或本软件服务制作、上载、复制、发送如下内容：
        (1) 反对宪法所确定的基本原则的；
        (2) 危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一的；
        (3) 损害国家荣誉和利益的；
        (4) 煽动民族仇恨、民族歧视，破坏民族团结的；
        (5) 破坏国家宗教政策，宣扬邪教和封建迷信的；
        (6) 散布谣言，扰乱社会秩序，破坏社会稳定的；
        (7) 散布淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪的；
        (8) 侮辱或者诽谤他人，侵害他人合法权益的；
        (9) 含有法律、行政法规禁止的其他内容的信息。
        二、本游戏所有素材均来自互联网，如遇侵权请联系GM删除。
        三、若您对本游戏及本服务有任何意见，欢迎联系游戏界面中的客服联系方式。
    ]=]
    end
    -- 原始远程更新/控制地址。
    local primary_update_url = "http://go.zejiang.wang/gv6"
    local default_backup_url = "http://gate.zejiang.wang:88/gv6"
    local unused_port_list = { "81", "88", "89", "90", "91", "92", "93", "94" }
    local backup_update_urls = {
        "http://gate.zejiang.wang:88/gv6",
        "http://tm2.zejiang.wang/gv6",
        "http://tm3.zejiang.wang/gv6",
        "http://sng.zejiang.wang:99/gv6",
    }
    local current_update_url = default_backup_url
    local backup_url_count = to_number("4")
    local backup_url_index = to_number("1")
    -- 远端 Lua 内容的本地缓存位置。
    local cache_directory = globals.device.writablePath .. "cache/ao/"
    local unused_false_flag = false_value
    local get_info = globals.getinfo
    local unused_string_length = globals.string.len
    local cached_code_loaded = false_value
    local gate_ip = globals.def.gateIP
    local function key_fragment_rm()
        return "rM"
    end
    local local_version = "nofile"
    globals.def.role.open = true_value
    local function key_fragment_a()
        return "A"
    end
    local cache_file_base = cache_directory .. globals.core_func_md5(globals.def.role.stuff or "999")
    if not globals.io.exists(cache_directory) then
        globals.ycFunction.mkdir(globals.ycFunction, cache_directory)
    end
    local function identity(value)
        return value
    end
    -- 安全提示：原始逻辑会解密远端响应，随后通过 load + pcall 直接执行。
    local function decrypt_remote_content(content)
        if get_info(globals.cc.Crypto.decodeBase64).what == "C" then
            return globals.core_func_decryptTEA(
                globals.core_func_decodeBase64(content),
                globals.tostring(globals.os.date("%Y%m"))
                    .. globals.core_func_decodeBase64("K" .. key_fragment_a() .. "s" .. key_fragment_rm() .. "oLrt")
                    .. globals.def.role.stuff
            )
        else
            globals.core_func_exit()
        end
    end
    local function write_file(file_path, file_data)
        if get_info(globals.io.write).what == "C" then
            local file_handle = globals.io.open(file_path, "w+b")
            if file_handle then
                if file_handle.write(file_handle, file_data) == nil_value then
                    return false_value
                end
                globals.io.close(file_handle)
                return true_value
            else
                return false_value
            end
        else
            globals.core_func_exit()
        end
    end
    local function execute_lua(lua_source)
        if get_info(globals.pcall).what ~= "C" then
            globals.core_func_exit()
            return
        end
        if get_info(globals.load).what == "C" then
            return globals.pcall(function()
                globals.load(lua_source)()
            end)
        else
            globals.core_func_exit()
        end
    end
    local function load_cached_code()
        if globals.isloaded then
            return
        end
        if globals.io.exists(cache_file_base .. ".bin") then
            local cached_data = globals.io.readfile(cache_file_base .. ".bin")
            if cached_data then
                cached_data = decrypt_remote_content(cached_data)
                if cached_data then
                    local success, execution_error = execute_lua(cached_data)
                    if success then
                        cached_code_loaded = true_value
                        globals.print("m1")
                        return true_value
                    end
                end
            end
        end
        local_version = "nover"
        return false_value
    end
    local function load_cached_version()
        if globals.io.exists(cache_file_base .. ".bin") and globals.io.exists(cache_file_base .. ".version") then
            local cached_data = globals.io.readfile(cache_file_base .. ".version")
            if cached_data then
                local_version = cached_data
                return
            end
        end
    end
    local function save_cached_version(local_version)
        write_file(cache_file_base .. ".version", local_version)
    end
    local function save_cached_content(content)
        write_file(cache_file_base .. ".bin", content)
        globals.print("m2")
    end
    -- 使用备用地址请求更新。gplus.bin 的文件 MD5 被作为 POST 参数 code。
    local function request_backup_update(force_refresh)
        if force_refresh then
            if backup_url_index <= backup_url_count then
                current_update_url = backup_update_urls[backup_url_index]
                backup_url_index = backup_url_index + to_number("1")
            else
                if globals.def.debugkey then
                    globals.print("没有可以访问的服务器")
                end
                return
            end
        end
        local version_tag = local_version
        if force_refresh then
            version_tag = "dirty"
        end
        if globals.def.debugkey then
            globals.print(current_update_url)
        end
        local backup_request = globals.core_func_createNet(function(backup_event)
            if backup_event.name ~= "completed" then
                if backup_event.name == "failed" then
                    if globals.def.debugkey then
                        globals.print("backup not ok")
                    end
                    request_backup_update(force_refresh)
                end
                return
            end
            local request = backup_event.request
            local status_code = request.getResponseStatusCode(request)
            if status_code ~= to_number("200") then
                return
            end
            local content = request.getResponseData(request)
            if content then
                if content == "u7bTrcq508Ow19bttcfCvMb3" then
                    globals.core_func_exit()
                end
                if content == "OK" then
                    if globals.def.debugkey then
                        globals.print("same versions")
                    end
                    if not globals.isloaded and not load_cached_code() then
                        request_backup_update(true_value)
                    end
                    return
                end
                local json_module = globals.require("cjson")
                local response_json = json_module.decode(content)
                if not response_json then
                    if globals.def.debugkey then
                        globals.print("json decode error")
                    end
                    request_backup_update(true_value)
                end
                if not response_json.version or not response_json.content then
                    if globals.def.debugkey then
                        globals.print("json format error")
                    end
                    request_backup_update(true_value)
                    return
                end
                local lua_source = decrypt_remote_content(response_json.content)
                if not lua_source then
                    if globals.def.debugkey then
                        globals.print("content decode error")
                    end
                    request_backup_update(true_value)
                else
                    local success, execution_error = execute_lua(lua_source)
                    if success then
                        save_cached_content(response_json.content)
                        save_cached_version(response_json.version)
                    else
                        if globals.def.debugkey then
                            globals.print("run code error")
                        end
                        request_backup_update(true_value)
                    end
                end
            else
                request_backup_update(true_value)
            end
        end, identity(current_update_url), "POST")
        local file_data_result, gplus_file_md5 =
            globals.ycFunction.getFileData(globals.ycFunction, "gplus.bin", true_value)
        local function get_or_create_uuid(uuid_seed)
            local file_path = globals.device.writablePath .. "bzuuid"
            if not globals.io.exists(file_path) then
                uuid_seed = globals.crypto.md5(uuid_seed)
                globals.core_func_writefile(file_path, uuid_seed)
                return uuid_seed
            end
            return globals.io.readfile(file_path)
        end
        local client_uid = "smlt_" .. get_or_create_uuid(empty_string .. globals.os.time())
        local zone_name_base64 = "none"
        if globals.g_data.login.localLastSer and globals.g_data.login.localLastSer.zonename then
            zone_name_base64 = globals.crypto.encodeBase64(globals.g_data.login.localLastSer.zonename)
        end
        backup_request.setPOSTData(
            backup_request,
            "ip="
                .. globals.crypto.encodeBase64(gate_ip)
                .. "&uid="
                .. client_uid
                .. "&code="
                .. gplus_file_md5
                .. "&key="
                .. globals.crypto.decodeBase64(globals.def.role.stuff)
                .. "&version="
                .. version_tag
                .. "&zone="
                .. zone_name_base64
        )
        backup_request.setTimeout(backup_request, to_number("6"))
        backup_request.start(backup_request)
    end
    -- 使用主地址请求更新；失败时回退到备用地址。
    local function request_primary_update(force_refresh)
        local version_tag = local_version
        if force_refresh then
            version_tag = "dirty"
        end
        if globals.def.debugkey then
            globals.print(primary_update_url)
        end
        local request = globals.core_func_createNet(function(network_event)
            if network_event.name ~= "completed" then
                if globals.def.debugkey then
                    globals.print(network_event.name)
                end
                if network_event.name == "failed" then
                    if globals.def.debugkey then
                        globals.print("not ok")
                    end
                    request_backup_update(false_value)
                end
                return
            end
            local request = network_event.request
            local status_code = request.getResponseStatusCode(request)
            if status_code ~= to_number("200") then
                return
            end
            local content = request.getResponseData(request)
            if content then
                if content == "u7bTrcq508Ow19bttcfCvMb3" then
                    globals.core_func_exit()
                    return
                end
                if content == "OK" then
                    if globals.def.debugkey then
                        globals.print("same version")
                    end
                    if not globals.isloaded and not load_cached_code() then
                        request_primary_update(true_value)
                    end
                    return
                end
                local json_module = globals.require("cjson")
                local response_json = json_module.decode(content)
                if not response_json then
                    if globals.def.debugkey then
                        globals.print("json decode error")
                    end
                    request_backup_update(true_value)
                end
                if not response_json.version or not response_json.content then
                    if globals.def.debugkey then
                        globals.print("json format error")
                    end
                    request_backup_update(true_value)
                    return
                end
                local lua_source = decrypt_remote_content(response_json.content)
                if not lua_source then
                    if globals.def.debugkey then
                        globals.print("content decode error")
                    end
                    request_backup_update(true_value)
                else
                    local success, execution_error = execute_lua(lua_source)
                    if success then
                        save_cached_content(response_json.content)
                        save_cached_version(response_json.version)
                    else
                        if globals.def.debugkey then
                            globals.print("run code error")
                        end
                        request_backup_update(true_value)
                    end
                end
            else
                request_backup_update(true_value)
            end
        end, identity(primary_update_url), "POST")
        local file_data_result, gplus_file_md5 =
            globals.ycFunction.getFileData(globals.ycFunction, "gplus.bin", true_value)
        local function get_or_create_uuid(uuid_seed)
            local file_path = globals.device.writablePath .. "bzuuid"
            if not globals.io.exists(file_path) then
                uuid_seed = globals.crypto.md5(uuid_seed)
                globals.core_func_writefile(file_path, uuid_seed)
                return uuid_seed
            end
            return globals.io.readfile(file_path)
        end
        local client_uid = "smlt_" .. get_or_create_uuid(empty_string .. globals.os.time())
        local zone_name_base64 = "none"
        if globals.g_data.login.localLastSer and globals.g_data.login.localLastSer.zonename then
            zone_name_base64 = globals.crypto.encodeBase64(globals.g_data.login.localLastSer.zonename)
        end
        request.setPOSTData(
            request,
            "ip="
                .. globals.crypto.encodeBase64(gate_ip)
                .. "&uid="
                .. client_uid
                .. "&code="
                .. gplus_file_md5
                .. "&key="
                .. globals.crypto.decodeBase64(globals.def.role.stuff)
                .. "&version="
                .. version_tag
                .. "&zone="
                .. zone_name_base64
        )
        request.setTimeout(request, to_number("6"))
        request.start(request)
    end
    -- 通过刻意复杂的数学表达式构造 core/core64 ZIP 的解密密钥。
    local math_floor, math_exp, math_sqrt = globals.math.floor, globals.math.exp, globals.math.sqrt
    local string_char, string_reverse = globals.string.char, globals.string.reverse
    local function build_key_parameters()
        return {
            phase_shift = to_number("0.5"),
            exp_factor = to_number("2.302585093"),
            char_offset = to_number("36"),
        }
    end
    local function derive_core_archive_key()
        local key_parameters = build_key_parameters()
        local exponential_base = math_floor(math_exp(key_parameters.exp_factor))
        local phase_value = exponential_base
            * (globals.math.pi - to_number("3.1415926535") + key_parameters.phase_shift)
        local scaled_phase = math_floor(phase_value * to_number("0.5") * to_number("100"))
        local scale_factor = to_number("10") * to_number("10") * to_number("2")
        local scaled_product = scaled_phase * scale_factor
        local square_root = math_sqrt(scaled_product)
        return string_reverse(
                string_char(
                    math_floor(square_root / to_number("10")),
                    to_number("36") + key_parameters.char_offset,
                    to_number("72") - to_number("15"),
                    to_number("57") + to_number("25"),
                    to_number("82") ^ to_number("0.5"),
                    to_number("9") + to_number("33"),
                    to_number("42") + to_number("52"),
                    to_number("94") % to_number("65")
                )
            )
            :gsub("[\022]", "HK")
            :gsub("[\t]", "EX")
    end
    -- pcall 的第二返回值是最终密钥（失败时则为错误文本，原行为照旧保留）。
    local key_derivation_ok, core_archive_key = globals.pcall(derive_core_archive_key)
    local resource_directory = globals.device.writablePath .. "res/"
    local encrypted_core_archive_name = globals.string.format("core%s.zip", globals.USE_ARM64 and "64" or empty_string)
    local decrypted_core_archive_name = globals.string.format("dcore%s.zip", globals.USE_ARM64 and "64" or empty_string)
    if not globals.io.exists(resource_directory) then
        globals.ycFunction.mkdir(globals.ycFunction, resource_directory)
    end
    if not globals.io.exists(resource_directory .. encrypted_core_archive_name) then
        globals.an.newMsgbox("你的登陆器不是G版登陆器\n请下载bzmir.bin！ ", function(button_index)
            if to_number("1") == button_index then
                globals.core_func_byby("不是G版本")
            end
        end, { center = true_value, close = false_value })
        globals.scheduler.performWithDelayGlobal(function()
            globals.os.exit()
        end, to_number("6"))
        return
    end
    if get_info(globals.cc.Crypto.decryptXXTEA).what ~= "C" then
        globals.core_func_byby("非法hook")
    end
    local file_data_result = globals.io.readfile(resource_directory .. encrypted_core_archive_name)
    if not file_data_result then
        globals.core_func_byby("core缺失")
    end
    local decrypted_core_archive = globals.core_func_decryptTEA(file_data_result, core_archive_key .. "爲")
    globals.core_func_writefile(resource_directory .. decrypted_core_archive_name, decrypted_core_archive)
    globals.cc.LuaLoadChunksFromZIP(decrypted_core_archive_name)
    globals.os.remove(resource_directory .. decrypted_core_archive_name)
    if
        globals.io.exists(
            resource_directory .. globals.string.format("hookcore%s.zip", globals.USE_ARM64 and "64" or empty_string)
        )
    then
        globals.cc.LuaLoadChunksFromZIP(
            globals.string.format("hookcore%s.zip", globals.USE_ARM64 and "64" or empty_string)
        )
    end
    load_cached_version()
    load_cached_code()
    local version_tag = local_version
    -- 对外暴露 helperID 设置入口，然后发起启动时的主更新请求。
    globals.set_helper = function(helper_id)
        globals.def.role.helperID = helper_id
    end
    local request = globals.core_func_createNet(function(network_event)
        if network_event.name ~= "completed" then
            if globals.def.debugkey then
                globals.print(network_event.name)
            end
            if network_event.name == "failed" then
                if globals.def.debugkey then
                    globals.print("not ok")
                end
                request_backup_update(false_value)
            end
            return
        end
        local request = network_event.request
        local status_code = request.getResponseStatusCode(request)
        if status_code ~= to_number("200") then
            return
        end
        local content = request.getResponseData(request)
        if content then
            if content == "u7bTrcq508Ow19bttcfCvMb3" then
                globals.core_func_exit()
                return
            end
            if content == "OK" then
                if globals.def.debugkey then
                    globals.print("same version")
                end
                if not globals.isloaded and not load_cached_code() then
                    request_primary_update(true_value)
                end
                return
            end
            local json_module = globals.require("cjson")
            local response_json = json_module.decode(content)
            if not response_json then
                if globals.def.debugkey then
                    globals.print("json decode error")
                end
                request_backup_update(true_value)
            end
            if not response_json.version or not response_json.content then
                if globals.def.debugkey then
                    globals.print("json format error")
                end
                request_backup_update(true_value)
                return
            end
            local lua_source = decrypt_remote_content(response_json.content)
            if not lua_source then
                if globals.def.debugkey then
                    globals.print("content decode error")
                end
                request_backup_update(true_value)
            else
                local success, execution_error = execute_lua(lua_source)
                if success then
                    save_cached_content(response_json.content)
                    save_cached_version(response_json.version)
                else
                    if globals.def.debugkey then
                        globals.print("run code error")
                    end
                    request_backup_update(true_value)
                end
            end
        else
            request_backup_update(true_value)
        end
    end, identity(primary_update_url), "POST")
    local file_data_result, gplus_file_md5 = globals.ycFunction.getFileData(globals.ycFunction, "gplus.bin", true_value)
    local function get_or_create_uuid(uuid_seed)
        local file_path = globals.device.writablePath .. "bzuuid"
        if not globals.io.exists(file_path) then
            uuid_seed = globals.crypto.md5(uuid_seed)
            globals.core_func_writefile(file_path, uuid_seed)
            return uuid_seed
        end
        return globals.io.readfile(file_path)
    end
    local client_uid = "smlt_" .. get_or_create_uuid(empty_string .. globals.os.time())
    local zone_name_base64 = "none"
    if globals.g_data.login.localLastSer and globals.g_data.login.localLastSer.zonename then
        zone_name_base64 = globals.crypto.encodeBase64(globals.g_data.login.localLastSer.zonename)
    end
    request.setPOSTData(
        request,
        "ip="
            .. globals.crypto.encodeBase64(gate_ip)
            .. "&uid="
            .. client_uid
            .. "&code="
            .. gplus_file_md5
            .. "&key="
            .. globals.crypto.decodeBase64(globals.def.role.stuff)
            .. "&version="
            .. version_tag
            .. "&zone="
            .. zone_name_base64
    )
    request.setTimeout(request, to_number("6"))
    request.start(request)
end)()
