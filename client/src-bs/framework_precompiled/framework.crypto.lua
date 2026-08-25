local crypto = {
	encryptAES256 = function (plaintext, key)
		plaintext = tostring(plaintext)
		key = tostring(key)

		return cc.Crypto:encryptAES256(plaintext, string.len(plaintext), key, string.len(key))
	end,
	decryptAES256 = function (ciphertext, key)
		ciphertext = tostring(ciphertext)
		key = tostring(key)

		return cc.Crypto:decryptAES256(ciphertext, string.len(ciphertext), key, string.len(key))
	end,
	encryptXXTEA = function (plaintext, key)
		plaintext = tostring(plaintext)
		key = tostring(key)

		return cc.Crypto:encryptXXTEA(plaintext, string.len(plaintext), key, string.len(key))
	end,
	decryptXXTEA = function (ciphertext, key)
		ciphertext = tostring(ciphertext)
		key = tostring(key)

		return cc.Crypto:decryptXXTEA(ciphertext, string.len(ciphertext), key, string.len(key))
	end,
	encodeBase64 = function (plaintext)
		plaintext = tostring(plaintext)

		return cc.Crypto:encodeBase64(plaintext, string.len(plaintext))
	end,
	decodeBase64 = function (ciphertext)
		ciphertext = tostring(ciphertext)

		return cc.Crypto:decodeBase64(ciphertext)
	end,
	md5 = function (input, isRawOutput)
		input = tostring(input)

		if type(isRawOutput) ~= "boolean" then
			isRawOutput = false
		end

		return cc.Crypto:MD5(input, isRawOutput)
	end,
	md5file = function (path)
		if not path then
			printError("crypto.md5file() - invalid filename")

			return nil
		end

		path = tostring(path)

		if DEBUG > 1 then
			printInfo("crypto.md5file() - filename: %s", path)
		end

		return cc.Crypto:MD5File(path)
	end
}

return crypto
