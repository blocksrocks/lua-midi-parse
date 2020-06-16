local byte = require("parser/byte")

local strbyte = byte.strbyte

local function sequencenumber(reader)

end

local function textevent(reader)

end

local function copyrightnotice(reader)

end

local function textsequenceortrackname(reader, ...)
	print("trackname", table.concat({...}))
end

local function instrumentname(reader)

end

local function textlyric(reader)

end

local function textmarker(reader)

end

local function cuepoint(reader)

end

local function midichannelprefix(reader)
end

local function endoftrack(reader)
	print("end of track")
end

local function temposetting(reader, b0, b1, b2)
	local usperquarternote = strbyte(b0..b1..b2)
	print("temposetting", usperquarternote)
end

local function smpteoffset(reader)

end

local function timesignature(reader)

end

local function keysignature(reader)

end

local function sequencerspecificevent(reader)

end

local metaeventhash = {
	[0x00] = sequencenumber;
	[0x01] = textevent;
	[0x02] = copyrightnotice;
	[0x03] = textsequenceortrackname;
	[0x04] = instrumentname;
	[0x05] = textlyric;
	[0x06] = textmarker;
	[0x07] = cuepoint;
	[0x20] = midichannelprefix;
	[0x2F] = endoftrack;
	[0x51] = temposetting;
	[0x54] = smpteoffset;
	[0x58] = timesignature;
	[0x59] = keysignature;
	[0x7F] = sequencerspecificevent;
}

return metaeventhash