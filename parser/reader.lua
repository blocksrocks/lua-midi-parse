local byte = require("parser/byte")

local strvarquant = byte.strvarquant
local strbyte     = byte.strbyte
local sub         = string.sub

local function newreader(string, indexin)
	local self = {}

	local index = indexin or 1

	function self.forward(steps)
		index = index + steps
	end

	function self.forwardbyte(steps)
		local index0 = index
		index = index + steps
		return strbyte(sub(string, index0, index - 1))
	end

	function self.forwardchar(steps)
		local index0 = index
		index = index + steps
		return sub(string, index0, index - 1)
	end

	function self.subbyte(index0, index1)
		index1 = index1 or index0
		return strbyte(sub(string, index0, index1))
	end

	function self.subchar(index0, index1)
		index1 = index1 or index0
		return sub(string, index0, index1)
	end

	function self.getindex()
		return index
	end

	function self.getstring()
		return string
	end

	function self.readvarlen()
		local val, vind0, vind1 = strvarquant(self.getstring(), self.getindex())
		self.forward(1 + vind1 - vind0)
		return val, 1 + vind1 - vind0
	end

	return self
end

return newreader