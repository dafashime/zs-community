local ffi = require("ffi")
local callback = ffi.new
local callback5 = ffi.gc
local callback2 = ffi.string
local callback3 = ffi.copy
local value = ffi.C
local callback6 = setmetatable
local callback4 = type
local zz = {
	_VERSION = "0.12"
}
local items2 = {
	__index = zz
}
local number = 9
local number3 = 16
local number4 = 17

ffi.cdef("typedef struct engine_st ENGINE;\n\ntypedef struct evp_cipher_st EVP_CIPHER;\ntypedef struct evp_cipher_ctx_st EVP_CIPHER_CTX;\n\ntypedef struct env_md_ctx_st EVP_MD_CTX;\ntypedef struct env_md_st EVP_MD;\n\nconst EVP_MD *EVP_md5(void);\nconst EVP_MD *EVP_sha(void);\nconst EVP_MD *EVP_sha1(void);\nconst EVP_MD *EVP_sha224(void);\nconst EVP_MD *EVP_sha256(void);\nconst EVP_MD *EVP_sha384(void);\nconst EVP_MD *EVP_sha512(void);\n\nconst EVP_CIPHER *EVP_aes_128_ecb(void);\nconst EVP_CIPHER *EVP_aes_128_cbc(void);\nconst EVP_CIPHER *EVP_aes_128_cfb1(void);\nconst EVP_CIPHER *EVP_aes_128_cfb8(void);\nconst EVP_CIPHER *EVP_aes_128_cfb128(void);\nconst EVP_CIPHER *EVP_aes_128_ofb(void);\nconst EVP_CIPHER *EVP_aes_128_ctr(void);\nconst EVP_CIPHER *EVP_aes_192_ecb(void);\nconst EVP_CIPHER *EVP_aes_192_cbc(void);\nconst EVP_CIPHER *EVP_aes_192_cfb1(void);\nconst EVP_CIPHER *EVP_aes_192_cfb8(void);\nconst EVP_CIPHER *EVP_aes_192_cfb128(void);\nconst EVP_CIPHER *EVP_aes_192_ofb(void);\nconst EVP_CIPHER *EVP_aes_192_ctr(void);\nconst EVP_CIPHER *EVP_aes_256_ecb(void);\nconst EVP_CIPHER *EVP_aes_256_cbc(void);\nconst EVP_CIPHER *EVP_aes_256_cfb1(void);\nconst EVP_CIPHER *EVP_aes_256_cfb8(void);\nconst EVP_CIPHER *EVP_aes_256_cfb128(void);\nconst EVP_CIPHER *EVP_aes_256_ofb(void);\nconst EVP_CIPHER *EVP_aes_128_gcm(void);\nconst EVP_CIPHER *EVP_aes_192_gcm(void);\nconst EVP_CIPHER *EVP_aes_256_gcm(void);\n\nEVP_CIPHER_CTX *EVP_CIPHER_CTX_new();\nvoid EVP_CIPHER_CTX_free(EVP_CIPHER_CTX *a);\nint EVP_CIPHER_CTX_block_size(const EVP_CIPHER_CTX *ctx);\n\nint EVP_EncryptInit_ex(EVP_CIPHER_CTX *ctx,const EVP_CIPHER *cipher,\n        ENGINE *impl, unsigned char *key, const unsigned char *iv);\n\nint EVP_EncryptUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl,\n        const unsigned char *in, int inl);\n\nint EVP_EncryptFinal_ex(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl);\n\nint EVP_DecryptInit_ex(EVP_CIPHER_CTX *ctx,const EVP_CIPHER *cipher,\n        ENGINE *impl, unsigned char *key, const unsigned char *iv);\n\nint EVP_DecryptUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl,\n        const unsigned char *in, int inl);\n\nint EVP_DecryptFinal_ex(EVP_CIPHER_CTX *ctx, unsigned char *outm, int *outl);\n\nint EVP_BytesToKey(const EVP_CIPHER *type,const EVP_MD *md,\n        const unsigned char *salt, const unsigned char *data, int datal,\n        int count, unsigned char *key,unsigned char *iv);\n\nint EVP_CIPHER_CTX_ctrl(EVP_CIPHER_CTX *ctx, int type, int arg, void *ptr);\n")

local value2
local hash = {
	md5 = value.EVP_md5(),
	sha1 = value.EVP_sha1(),
	sha224 = value.EVP_sha224(),
	sha256 = value.EVP_sha256(),
	sha384 = value.EVP_sha384(),
	sha512 = value.EVP_sha512()
}

zz.hash = hash

local number2 = 32
local value3

local function cipher(self, value4)
	local size = self or 128
	local cipher = value4 or "cbc"
	local text2 = "EVP_aes_" .. size .. "_" .. cipher

	if value[text2] then
		return {
			size = size,
			cipher = cipher,
			method = value[text2]()
		}
	else
		return nil
	end
end

zz.cipher = cipher

function zz.new(value4, items3, items4, value6, value7, value9, value11)
	local encrypt_ctx = value.EVP_CIPHER_CTX_new()

	if encrypt_ctx == nil then
		return nil, "no memory"
	end

	callback5(encrypt_ctx, value.EVP_CIPHER_CTX_free)

	local decrypt_ctx = value.EVP_CIPHER_CTX_new()

	if decrypt_ctx == nil then
		return nil, "no memory"
	end

	callback5(decrypt_ctx, value.EVP_CIPHER_CTX_free)

	local value5 = value6 or cipher()
	local items5 = value7 or hash.md5
	local value8 = value9 or 1
	local value10 = value5.size / 8
	local key = callback("unsigned char[?]", value10)
	local iv = callback("unsigned char[?]", value10)

	value11 = value11 or value10

	if callback4(items5) == "table" then
		if not items5.iv then
			return nil, "iv is needed"
		end

		value11 = #items5.iv

		if value10 < value11 then
			return nil, "bad iv length"
		end

		if items5.method then
			local items6 = items5.method(items3)

			if #items6 ~= value10 then
				return nil, "bad key length"
			end

			callback3(key, items6, value10)
		elseif #items3 ~= value10 then
			return nil, "bad key length"
		else
			callback3(key, items3, value10)
		end

		callback3(iv, items5.iv, value11)
	else
		if items4 and #items4 ~= 8 then
			return nil, "salt must be 8 characters or nil"
		end

		if value.EVP_BytesToKey(value5.method, items5, items4, items3, #items3, value8, key, iv) ~= value10 then
			return nil, "failed to generate key and iv"
		end
	end

	if value.EVP_EncryptInit_ex(encrypt_ctx, value5.method, nil, nil, nil) == 0 or value.EVP_DecryptInit_ex(decrypt_ctx, value5.method, nil, nil, nil) == 0 then
		return nil, "failed to init ctx"
	end

	local value12 = value5.cipher

	if (value12 == "gcm" or value12 == "ccm" or value12 == "ocb") and (value.EVP_CIPHER_CTX_ctrl(encrypt_ctx, number, value11, nil) == 0 or value.EVP_CIPHER_CTX_ctrl(decrypt_ctx, number, value11, nil) == 0) then
		return nil, "failed to set IV length"
	end

	return callback6({
		_encrypt_ctx = encrypt_ctx,
		_decrypt_ctx = decrypt_ctx,
		_cipher = value5.cipher,
		_key = key,
		_iv = iv
	}, items2)
end

function zz:encrypt(items3)
	local value4 = callback4(self)

	if value4 ~= "table" then
		error("bad argument #1 self: table expected, got " .. value4, 2)
	end

	local value5 = #items3
	local value6 = value5 + 2 * number2
	local value7 = callback("unsigned char[?]", value6)
	local value8 = callback("int[1]")
	local value9 = callback("int[1]")
	local value10 = self._encrypt_ctx

	if value.EVP_EncryptInit_ex(value10, nil, nil, self._key, self._iv) == 0 then
		return nil, "EVP_EncryptInit_ex failed"
	end

	if value.EVP_EncryptUpdate(value10, value7, value8, items3, value5) == 0 then
		return nil, "EVP_EncryptUpdate failed"
	end

	if self._cipher == "gcm" then
		local value11 = callback2(value7, value8[0])

		if value.EVP_EncryptFinal_ex(value10, value7, value8) == 0 then
			return nil, "EVP_DecryptFinal_ex failed"
		end

		value.EVP_CIPHER_CTX_ctrl(value10, number3, 16, value7)

		local value12 = callback2(value7, 16)

		return {
			value11,
			value12
		}
	end

	if value.EVP_EncryptFinal_ex(value10, value7 + value8[0], value9) == 0 then
		return nil, "EVP_EncryptFinal_ex failed"
	end

	return callback2(value7, value8[0] + value9[0])
end

local text = "cQZ"

function zz:decrypt(items3, value6)
	local value4 = callback4(self)

	if value4 ~= "table" then
		error("bad argument #1 self: table expected, got " .. value4, 2)
	end

	local value5 = #items3
	local value7 = value5 + 2 * number2
	local value8 = callback("unsigned char[?]", value7)
	local value9 = callback("int[1]")
	local value10 = callback("int[1]")
	local value11 = self._decrypt_ctx

	if value.EVP_DecryptInit_ex(value11, nil, nil, self._key, self._iv) == 0 then
		return nil, "EVP_DecryptInit_ex failed"
	end

	if value.EVP_DecryptUpdate(value11, value8, value9, items3, value5) == 0 then
		return nil, "EVP_DecryptUpdate failed"
	end

	if self._cipher == "gcm" then
		local value12 = callback2(value8, value9[0])

		if value6 ~= nil then
			local value13 = callback("unsigned char[?]", 16)

			ffi.copy(value13, value6, 16)
			value.EVP_CIPHER_CTX_ctrl(value11, number4, 16, value13)
		end

		if value.EVP_DecryptFinal_ex(value11, value8 + value9[0], value10) == 0 then
			return nil, "EVP_DecryptFinal_ex failed"
		end

		return value12
	end

	if value.EVP_DecryptFinal_ex(value11, value8 + value9[0], value10) == 0 then
		return nil, "EVP_DecryptFinal_ex failed"
	end

	return callback2(value8, value9[0] + value10[0])
end

function zz.bin2hex(text2)
	text2 = string.gsub(text2, "(.)", function(value4)
		return string.format("%02X ", string.byte(value4))
	end)

	return text2
end

local count = 0
local items = {
	["0"] = 0,
	C = 12,
	["9"] = 9,
	["2"] = 2,
	["7"] = 7,
	["3"] = 3,
	F = 15,
	["4"] = 4,
	E = 14,
	A = 10,
	["6"] = 6,
	D = 13,
	["5"] = 5,
	["1"] = 1,
	["8"] = 8,
	B = 11
}
local count2 = 1

function zz:hex2bin()
	return (string.gsub(self, "(.)(.)%s", function(value4, value5)
		return string.char(items[value4] * 16 + items[value5])
	end))
end

local number5 = 3

function zz:encryptToStr(value5)
	local value4 = self:new(text .. number5 .. "dxQA" .. count2 .. "H" .. count .. "S"):encrypt(value5)

	return self.bin2hex(value4)
end

return zz
