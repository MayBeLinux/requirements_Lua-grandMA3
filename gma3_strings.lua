-- *********************************************************************
-- a module that contains string helping functions for gma3
-- *********************************************************************
gma3_strings={}

-- *********************************************************************
-- Split string by seperator char into table
-- *********************************************************************

function gma3_strings:splitStringBySeperator(input, seperator)
    assert(string and seperator,[[args: string, seperator]])
    local t={}
    for str in string.gmatch(input, "([^"..seperator.."]+)") do
        table.insert(t, str)
    end
    return t
end