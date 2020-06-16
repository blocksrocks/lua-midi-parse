--[[

											   ----- voice messages
				   ---- channel messages -----|
				  |                            ----- mode messages
MIDI messages ----| 
				  |                            ---- common messages
				   ----- system messages -----|---- real-time messages
											   ---- exclusive messages

Voice Message           Status Byte      Data Byte1          Data Byte2
-------------           -----------   -----------------   -----------------
Note off                      8x      Key number          Note Off velocity
Note on                       9x      Key number          Note on velocity
Polyphonic Key Pressure       Ax      Key number          Amount of pressure
Control Change                Bx      Controller number   Controller value
Program Change                Cx      Program number      None
Channel Pressure              Dx      Pressure value      None            
Pitch Bend                    Ex      MSB                 LSB

1st Data Byte      Description                Meaning of 2nd Data Byte
-------------   ----------------------        ------------------------
	 79        Reset all  controllers            None; set to 0
	 7A        Local control                     0 = off; 127  = on
	 7B        All notes off                     None; set to 0
	 7C        Omni mode off                     None; set to 0
	 7D        Omni mode on                      None; set to 0
	 7E        Mono mode on (Poly mode off)      **
	 7F        Poly mode on (Mono mode off)      None; set to 0

System Real-Time Message         Status Byte 
------------------------         -----------
Timing Clock                         F8
Start Sequence                       FA
Continue Sequence                    FB
Stop Sequence                        FC
Active Sensing                       FE
System Reset                         FF

System Common Message   Status Byte      Number of Data Bytes
---------------------   -----------      --------------------
MIDI Timing Code            F1                   1
Song Position Pointer       F2                   2
Song Select                 F3                   1
Tune Request                F6                  None

--]]

--[[

SMF = <header_chunk> + <track_chunk> [+ <track_chunk> ...]

header_chunk = "MThd" + <header_length> + <format> + <n> + <division>

track_chunk = "MTrk" + <length> + <track_event> [+ <track_event> ...]

track_event = <v_time> + <midi_event> | <meta_event> | <sysex_event>

meta_event = 0xFF + <meta_type> + <v_length> + <event_data_bytes>

sysex_event = 0xF0 + <data_bytes> 0xF7 or sysex_event = 0xF7 + <data_bytes> 0xF7 

Variable length              Real value
0x7F                         127 (0x7F)
0x81 0x7F                    255 (0xFF)
0x82 0x80 0x00               32768 (0x8000)

--]]

--[[

0x4d546864: header chunk
0x4d54726b: track chunk

--]]

--[[

<meta_type> 1 byte
	meta event types:
			Type 	Event

			0x00 	Sequence number 			
			0x01 	Text event 					
			0x02 	Copyright notice 			
			0x03 	Sequence or track name 		
			0x04 	Instrument name 			
			0x05 	Lyric text 					
			0x06 	Marker text 				
			0x07 	Cue point
			0x20 	MIDI channel prefix assignment
			0x2F 	End of track
			0x51 	Tempo setting
			0x54 	SMPTE offset
			0x58 	Time signature
			0x59 	Key signature
			0x7F 	Sequencer specific event

--]]

--local tempo = 60000000/usperquarternote

local bit           = require("bit")
local byte          = require("parser/byte")
local midieventhash = require("parser/midi")
local metaeventhash = require("parser/meta")
local newreader     = require("parser/reader")

local decbin    = byte.decbin
local bytesplit = byte.bytesplit
local tohex     = bit.tohex
local open      = io.open
local sub       = string.sub
local log       = math.log
local floor     = math.floor

local function readall(path)
	local file = open(path, "rb")
	local text = file:read("*a")
	file:close()
	return text
end

local function parse(path)
	local source = readall(path)
	local reader = newreader(source)
	if reader.forwardbyte(4) == 0x4d546864 then
		local header_length = reader.forwardbyte(4)
		local format        = reader.forwardbyte(2)
		local n             = reader.forwardbyte(2)
		local division      = reader.forwardbyte(2)
		---[[
		print("HEADER_CHUNK")
		print("header_length:", header_length)
		print("format:", format)
		print("n:", n)
		print("division:", division)
		print()
		--]]
		for _ = 1, n do
			if reader.forwardbyte(4) == 0x4d54726b then
				local length = reader.forwardbyte(4)
				local curind = reader.getindex()
				while reader.getindex() < curind + length do
					local v_time, v_timelen = reader.readvarlen()
					local type = reader.forwardbyte(1)
					print("v_time:", "0x"..tohex(v_time))
					print("type:", "0x"..tohex(type))
					--[[
					print("type:", "0x"..tohex(type))
					print("v_time:", v_time)
					--]]
					if type == 0xFF then
						--meta event
						local meta_type        = reader.forwardbyte(1)
						local v_length         = reader.readvarlen()
						local event_data_bytes = reader.forwardchar(v_length)
						--[[
						print("META")
						print("meta_type:", "0x"..tohex(meta_type))
						print("v_length:", v_length)
						print("event_data_bytes:", event_data_bytes)
						--]]
						local args = {}
						for ind = 1, v_length do
							args[ind] = sub(event_data_bytes, ind, ind)
						end
						local func = metaeventhash[meta_type]
						if func then
							func(reader, unpack(args))
						else
							--print("META FAIL")
						end
					elseif type == 0xF0 then
						---[[
						print("SYSEX Begin")
						for i = 0, 49 do
							--print("0x"..tohex(reader.subbyte(i - 1)))
						end
						local length    = reader.readvarlen()
						local info      = reader.forwardchar(length)
						--print(reader.subbyte(reader.getindex()))
						--print(reader.subbyte(reader.getindex() + 1))
						---[[
						--local deltatime = reader.readvarlen()
						while reader.subbyte(reader.getindex()) == 0xF7 do
							print("SYSEX Stream")
							local length    = reader.readvarlen()
							local info      = reader.forwardchar(length)
							local deltatime = reader.readvarlen()
						end
						--reader.forward(reader.getindex() - v_timelen + 1)
						--]]
						print("SYSEX End")
					else
						local lh, uh = bytesplit(type)
						local func = midieventhash[lh]
						if func then
							func(reader, uh)
						else
							for i = 0, 49 do
								print("0x"..tohex(reader.subbyte(reader.getindex() - i)))
							end
							print(reader.getindex(), #source)
							print("MIDI FAIL:", decbin(lh, 4), decbin(uh, 4))
							return
						end
					end
				end
				print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
			end
		end
	end
	return true
end

return {
	parse = parse;
}