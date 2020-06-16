local bit = require("bit")

local sub    = string.sub
local tobyte = string.byte
local tohex  = bit.tohex
local log    = math.log
local floor  = math.floor

local function strbyte(str)
	local fin = ""
	for ind = 1, #str do
		fin = fin..tohex(tobyte(sub(str, ind, ind)), 2)
	end
	return tonumber("0x"..fin)
end

local function logb(b, x)
	return log(x)/log(b)
end

local function decbits(num, base)
	return 1 + floor(logb(base, num))
end

local function decbin(dec, len)
	local bin = ""
	len = len or decbits(dec, 2)
	for ind = 1, len do
		local cur = 2^(len - ind)
		if dec >= cur then
			dec = dec - cur
			bin = bin.."1"
		else
			bin = bin.."0"
		end
	end
	return bin
end

local function bindec(bin)
	local fin = 0
	local len = #bin
	for ind = 1, len do
		fin = fin + sub(bin, ind, ind)*2^(len - ind)
	end
	return fin
end

local function strvarquant(str, ind0)
	local fin = ""
	ind0 = ind0 or 1
	for ind = ind0, #str do
		local bin = decbin(tobyte(sub(str, ind, ind)), 8)
		fin = fin..sub(bin, 2, 8)
		if sub(bin, 1, 1) == "0" then
			return bindec(fin), ind0, ind
		end
	end
end

local function bytesplit(dec)
	local bin = decbin(dec)
	return
		bindec(sub(bin, 1, 4)),
		bindec(sub(bin, 5, 8))
end

return {
	strbyte     = strbyte;
	strvarquant = strvarquant;
	bytesplit   = bytesplit;
	decbin      = decbin;
}