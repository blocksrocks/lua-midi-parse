local byte = require("parser/byte")

local strvarquant = byte.strvarquant

local function noteoff(reader, note)
	local keynote  = strvarquant(reader.forwardchar(1))
	local velocity = strvarquant(reader.forwardchar(1))
	--print("noteoff:", note, keynote, velocity)
end

local function noteon(reader, note)
	local keynote  = strvarquant(reader.forwardchar(1))
	local velocity = strvarquant(reader.forwardchar(1))
	--print("noteon:", note, keynote, velocity)
end

local function polyphonicpressure(reader, note)
	local key             = strvarquant(reader.forwardchar(1))
	local controllervalue = strvarquant(reader.forwardchar(1))
	--print("polyphonicpressure:", note, key, controllervalue)
end

local function controlchange(reader, note)
	local controllernumber = strvarquant(reader.forwardchar(1))
	local controllervalue  = strvarquant(reader.forwardchar(1))
	--print("controlchange:", note, controllernumber, controllervalue)
end

local function programchange(reader, note)
	local programnumber = strvarquant(reader.forwardchar(1))
	--print("programchange:", note, programnumber)
end

local function channelpressure(reader, note)
	local pressurevalue = strvarquant(reader.forwardchar(1))
	--print("channelpressure:", note, pressurevalue)
end

local function pitchbendchange(reader, note)
	local lsb = strvarquant(reader.forwardchar(1))
	local msb = strvarquant(reader.forwardchar(1))
	--print("pitchbendchange:", note, lsb, msb)
end

local midieventhash = {
	[0x08] = noteoff;
	[0x09] = noteon;
	[0x0A] = polyphonicpressure;
	[0x0B] = controlchange;
	[0x0C] = programchange;
	[0x0D] = channelpressure;
	[0x0E] = pitchbendchange;
}

return midieventhash