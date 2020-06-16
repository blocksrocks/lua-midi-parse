local parse = require("parser/parse")

local mididata = parse.parse("midis/hometown.mid")

print(mididata)