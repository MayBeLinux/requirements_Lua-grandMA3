-- *********************************************************************
-- a module that contains general helping functions for gma3
-- *********************************************************************
gma3_helpers={}

local lfs = require 'lfs' -- lua file system

-- ██████╗ ██████╗ ██╗███╗   ██╗████████╗
-- ██╔══██╗██╔══██╗██║████╗  ██║╚══██╔══╝
-- ██████╔╝██████╔╝██║██╔██╗ ██║   ██║   
-- ██╔═══╝ ██╔══██╗██║██║╚██╗██║   ██║   
-- ██║     ██║  ██║██║██║ ╚████║   ██║   
-- ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   


-- *********************************************************************
-- Prints content of given variable (works with every type, incl. gma3-objects)
-- *********************************************************************

function gma3_helpers:dump(o,recursion)
    if not recursion and type(o) == 'userdata' then
        return self:dumpObj(o);
    elseif type(o) == 'table' then
        local s = '{\n';
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '    ['..k..'] = ' .. self:dump(v,true) .. '\n'
        end
        s = s .. '\n}';
        if not recursion then
            self:printfWithNewline(s)
        end
        return s
    else
        if not recursion then Printf(tostring(o)) end
        return tostring(o)
    end
end

-- *********************************************************************
-- Prints content of gma3-object
-- *********************************************************************

function gma3_helpers:dumpObj(o)
    local s = ''

    if not o["IsValid"] then -- api function is not even able to be called, this is invalid
        Printf("Not Valid: "..tostring(o));
        return "Not Valid: "..tostring(o);
    end

    -- path to object
    local path = o.name;
    local nextParent = o;
    while nextParent:Parent() do
        nextParent = nextParent:Parent();
        path = nextParent.name .. "/" .. path;
    end
    s = s .. self:headline('Path','_',50) .. '\n';
    s = s .. path .. "\n";

    -- child types
    local children = o.name;
    local nextChild = o;
    while (nextChild:Children()[1]) do
        nextChild = nextChild:Children()[1];
        children = children .. "->" .. nextChild:GetClass();
    end
    s = s .. self:headline('Children','_',50) .. '\n';
    s = s .. "Child types: ".. children .. "\n";

    -- list of childs
    local content = '';
    local i = 1;
    while o[i] do
        s = s .. '\tChild '..i..': Name="'..o[i].name..'", Index='..o[i].index..'\n';
        i = i + 1;
    end
    
    s = s .. self:headline('Properties','_',50) .. '\n';
    for i = 0, (o:PropertyCount() - 1) do
        local type  = 'UNKNOWN_TYPE';
        local name  = 'UNKNOWN_NAME';
        local value = 'UNKNOWN_VALUE';
        local enum  = ''

        if o:PropertyType(i) then	type = tostring(o:PropertyType(i))	end
        if o:PropertyName(i) then   name = tostring(o:PropertyName(i))  end
        if o:Get(o:PropertyName(i)) then value = tostring(o:Get(o:PropertyName(i))) end
        if o:PropertyInfo(i).EnumCollection then enum = string.format("EnumCollection = %s", o:PropertyInfo(i).EnumCollection) end

        s = s .. '['..type..' '..name..'] = ['..value..'] '..enum..'\n';
    end

    self:printfWithNewline(s)
    return s;
end

-- *********************************************************************
-- Creates fixed width headline
-- *********************************************************************

function gma3_helpers:headline(headlineString, myFill, size)
    local fill1, fill2, fillingChar;
    local numberOfChars;
    if headlineString then numberOfChars = #headlineString;
    else                   numberOfChars = 0; end
    if myFill then
        fill1, fill2, fillingChar = myFill,myFill,myFill;
    else
        fill1, fill2, fillingChar = '_','_','_';
    end
    local totalWidth = 80;
    if size then totalWidth = size end;
    local count_fill1 = totalWidth/2 - numberOfChars/2
    local count_fill2 = totalWidth - count_fill1 - numberOfChars
    for i = 2, count_fill1 do   fill1 = fill1 .. fillingChar; end
    for i = 2, count_fill2 do   fill2 = fill2 .. fillingChar; end

    if headlineString then
        -- make sure the width is reached
        local createdWidth = string.len(fill1) + string.len(headlineString) + string.len(fill2);
        if createdWidth < totalWidth        then fill2 = fill2 .. fillingChar; end
        if createdWidth < totalWidth        then fill2 = string.sub(fill2, 1, string.len(fill2)); end

        return fill1 .. headlineString .. fill2;
    else
        return fill1 .. fill2;
    end
end

-- *********************************************************************
-- Convert \n and \t for Printf()
-- *********************************************************************

function gma3_helpers:printfWithNewline(str)
    -- convert tabs
    str = str:gsub("%\t", "    ")
    -- convert newlines
    local line;
    for line in tostring(str):gmatch("[^\n]+") do
        Printf(line)
    end
end

-- *********************************************************************
-- Create tree-like output of gma3-object
-- *********************************************************************

function gma3_helpers:tree(o, maxDepth)
    local function printDirectory(dir, prefix, depth)
        local i = 1;
        if maxDepth then 
            if (depth > maxDepth) then return; end
        end
        while dir[i] do
            local content = dir[i]
            Printf(prefix..'|---'..content.index..': '..content.name)

            printDirectory(content,prefix..'|   ', depth+1) -- use recursion
            i = i + 1;
        end
    end
    printDirectory(o,'',1)
end

-- *********************************************************************
-- Print Table
-- *********************************************************************

function gma3_helpers:printTableEntries(t,forcedColumns,noPrint)
    --[[ convert a table like this:
    {
        [1] = {name="testHTP", result=3, min=0, max=100},
        [2] = {name="testLTP", result=5, min=15, max=100}
    }
    
    to this:
        |-----------|-----------|-----------|-----------|-----------|
        |           | name      | result    | min       | max       |
        |-----------|-----------|-----------|-----------|-----------|
        | 1         | testHTP   | 3         | 0         | 100       |
        |-----------|-----------|-----------|-----------|-----------|
        | 2         | testLTP   | 5         | 15        | 100       |
        |-----------|-----------|-----------|-----------|-----------|
    ]]
    -- forcedColumns: list of column keys (sorted)
    -- noPrint: boolean, if Printf to cmdline should be blocked

    local function prepare(t)
        local rows = {}

        -- HEADLINE:
        local keyToCol = {} -- value (e.g. the key 'name', translated to the column idx)
        local headlineRow, cellOffset = 1,1
        rows[headlineRow] = { [cellOffset] = ""; } -- first cell is empty
        if forcedColumns then
            for i = 1, #forcedColumns do
                local colName = forcedColumns[i]
                local colIdx = i+cellOffset
                keyToCol[colName] = colIdx;
                rows[headlineRow][colIdx] = colName
            end
        else
            for k,_ in pairs(t[headlineRow]) do
                keyToCol[k] = #rows[headlineRow] + cellOffset
                rows[headlineRow][keyToCol[k]] = k
            end
        end

        -- CONTENT ROWS:
        for i=1, #t do
            local content = t[i]
            local printRow = {}
            printRow[1] = i; -- first col is index of table
            for key, value in pairs(content) do
                local colIdx = keyToCol[key]
                if colIdx then
                    local cellContent = tostring(value)
                    printRow[colIdx] = cellContent;
                end
            end
            -- now fill not given entries:
            for i = 1, #rows[headlineRow] do
                if printRow[i] == nil then
                    printRow[i] = "[nil]";
                end
            end

            rows[#rows+1] = printRow
        end

        return rows
    end

    local t = prepare(t)
    return self:printTable2D(t,noPrint)
end

function gma3_helpers:printTable2D(t,noPrint)
    --[[ convert table like this:
    {
        [1] = { [1] = "something", [2] = "else"},
        [2] = { [1] = "test", [2] = "abc"}
    }
    to this:
    |-----------|-----------|
    | something | else      |
    |-----------|-----------|
    | test      | abc       |
    |-----------|-----------|
    ]]

    local function fillStr(char,size)
        local res = "";
        for i=1, size do res = res .. char; end
    end
    -- 1st check width:
    local colWidthTable = {}
    for row = 1, #t do
        for col = 1, #t[row] do
            local requiredWidth = string.len(tostring(t[row][col]))
            if not colWidthTable[col] then
                colWidthTable[col] = 10;
            elseif (requiredWidth > colWidthTable[col]) then
                colWidthTable[col] = requiredWidth;
            end
        end
    end

    local function formatRow(row)
        local str = "|";
        for col=1, #row do
            local format = " %-"..colWidthTable[col].."s|"
            str = str .. string.format(format,tostring(row[col]))
        end
        return str
    end
    local function formatSeperatorRow()
        local str = "|";
        for col=1, #colWidthTable do
            for i=1, colWidthTable[col]+1 do
                str = str .. '-'
            end
            str = str .. '|'
        end
        return str
    end
    -- 2nd: print table
    local res = ""
    for row = 1, #t do
        res = res .. formatSeperatorRow() .. '\n'
        res = res .. formatRow(t[row]) .. '\n'
    end
    res = res .. formatSeperatorRow() .. '\n\n'
    if not noPrint then
        self:printfWithNewline(res)
    end
    return res
end

-- ██████╗  █████╗ ███████╗██╗  ██╗
-- ██╔══██╗██╔══██╗██╔════╝██║  ██║
-- ██████╔╝███████║███████╗███████║
-- ██╔══██╗██╔══██║╚════██║██╔══██║
-- ██████╔╝██║  ██║███████║██║  ██║
-- ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝


-- *********************************************************************
-- helper function for os.execute
-- *********************************************************************

function gma3_helpers:osExecute(cmd)
    Printf("Executing "..cmd);
    coroutine.yield(0.05); -- we want to print this before something gets stuck
    local tmpfile = os.tmpname();
    os.execute(cmd.." > "..tmpfile)
    for line in io.lines(tmpfile) do
        Printf(line);
    end
    os.remove(tmpfile);
end

function gma3_helpers:osExecuteWithResult(cmd)
    local tmpfile = os.tmpname();
    os.execute(cmd.." > "..tmpfile)
    local res = "";

    -- Read after
    for line in io.lines(tmpfile) do
        res = res .. " " .. line;
    end

    res = string.gsub(res, "%s+", "")

    os.remove(tmpfile);
    return res;
end

-- *********************************************************************
-- helper function for io.popen
-- *********************************************************************

function gma3_helpers:ioPopen(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result;
end


-- ███████╗██╗██╗     ███████╗    ██╗ ██████╗ 
-- ██╔════╝██║██║     ██╔════╝    ██║██╔═══██╗
-- █████╗  ██║██║     █████╗      ██║██║   ██║
-- ██╔══╝  ██║██║     ██╔══╝      ██║██║   ██║
-- ██║     ██║███████╗███████╗    ██║╚██████╔╝
-- ╚═╝     ╚═╝╚══════╝╚══════╝    ╚═╝ ╚═════╝ 

function gma3_helpers:getObjectExportPath(object)
    local pathType = GetPathType(object);
    local filePath = GetPath(pathType);
    local camelCaseToFileName = true;
    local fileName = object:GetExportFileName(camelCaseToFileName)..'.xml';
    local fullPath = filePath..'/'..fileName;
    return fullPath;
end

function gma3_helpers:getDirectoryContent(path)
    local resTable = {}
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local currentPath = path .. GetPathSeparator() .. file
            local attr = lfs.attributes(currentPath)
            assert(type(attr) == "table")
            if attr.mode == "directory" then
                resTable[#resTable+1] = {type="directory", fullPath=currentPath, name=file}
            else
                resTable[#resTable+1] = {type="file", fullPath=currentPath, name=file}
            end
        end
    end
    return resTable;
end

function gma3_helpers:copyFile(src,dst)
    local CopyCmd = HostOS()=="Windows" and "copy" or "cp"
    local cmd = CopyCmd .. ' "' .. src .. '" "' .. dst .. '"'
    gma3_helpers:osExecute(cmd)
end

function gma3_helpers:deleteFolderContent(desc)
    assert(desc.path ~= nil,"arg table needs path string")
    assert(desc.confirm ~= nil,"arg table needs confirm bool")
    assert(desc.recursive ~= nil,"arg table needs recursive bool")

    local foundFiles = {}
    local function addRecursive(path, resTable)
        local directory = gma3_helpers:getDirectoryContent(path)
        for _, file in ipairs(directory) do
            if file.type == "directory" then
                addRecursive(file.fullPath, resTable)
            else
                local filter = false;
                if desc.filterFunction then
                    filter = desc.filterFunction(file.name)
                end
                if not filter then
                    resTable[#resTable + 1] = file.fullPath;
                end
            end
        end
    end
    addRecursive(desc.path,foundFiles)

    -- all collected, now perform the deletion:
    local summary = "";
    for _,filePath in ipairs(foundFiles) do
        summary = summary .. filePath .. '\n'
    end
    if desc.confirm ~= true or Confirm("Delete all "..#foundFiles.." files?",summary) then
        for _,filePath in ipairs(foundFiles) do
            os.remove(filePath);
        end
    end
end

--  ██████╗ ████████╗██╗  ██╗███████╗██████╗ 
-- ██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗
-- ██║   ██║   ██║   ███████║█████╗  ██████╔╝
-- ██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗
-- ╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║
--  ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

function gma3_helpers:repeatUntilTrue(desc)
    local func      = desc.func;
    local tolerance = desc.tolerance or 10; -- seconds
    local interval  = desc.interval or 0.05; -- seconds

    local timeStart,timeDiff = Time();
    repeat
        if func() then return true; end
        timeDiff = Time() - timeStart;
        coroutine.yield(interval)
    until (timeDiff >= tolerance);
    return false;
end


local getSubTableInfo = function(t)
    local ret = "";
    for k, v in pairs(t) do
        if (type(v) == "table") then
            ret = string.format("%s\nSubTable: '%s'",ret,tostring(k))
        end
    end
    return ret;
end

function gma3_helpers:editLuaTable(t)
        local states = {} -- {array of {name:string, state:boolean[,group:integer]}
        local inputs = {} -- {array of {name:string, value:string, blackFilter:string, whiteFilter:string, vkPlugin:string, maxTextLength:integer}}
        local commands = {}

        commands[0] = {value = 0, name = "Cancel"}
        commands[1] = {value = 1, name = "Ok"}

        local stringPrefix = "String: ";
        local numberPrefix = "Number: ";

        local children = {}
    
        for k, v in pairs(t) do
            if type(v) == "boolean" then
                states[#states + 1] = {name = k, state = v}
            elseif type(v) == "number" then
                inputs[#inputs + 1] = {name = numberPrefix .. k, value = v}
            elseif type(v) == "string" then
                inputs[#inputs + 1] = {name = stringPrefix .. k, value = v}
            elseif (type(v) == "table") then
                children[#children+1] = k
                commands[2] = {value = 2, name = "Edit Children"}
            end
        end

        local resultTable =
            MessageBox(
            {
                title = "Adjust lua table",
                message = getSubTableInfo(t),
                commands = commands,
                states = states,
                inputs = inputs,
                selectors = selectors
            }
        )
    
        if resultTable.success and resultTable.result ~= 0 then
            if resultTable.result == 2 then
                -- EDIT CHILDREN
                local selIdx, selStr = PopupInput({title="Select child to edit", caller=GetFocusDisplay(), items=children});
                if t[selStr] then
                    gma3_helpers:editLuaTable(t[selStr])
                else
                    gma3_helpers:editLuaTable(t[tonumber(selStr)])
                end
            end

            if resultTable.states then
                for k, v in pairs(resultTable.states) do
                    t[k] = v
                end
            end
    
            if resultTable.inputs then
                for k, v in pairs(resultTable.inputs) do
                    if string.find(k,stringPrefix) then
                        local key = string.sub(k,string.len(stringPrefix) + 1,string.len(k))
                        t[key] = tostring(v)
                    elseif string.find(k,numberPrefix) then
                        local key = string.sub(k,string.len(numberPrefix) + 1,string.len(k))
                        t[key] = tonumber(v)
                    end
                end
            end
            return true;
        end
        return false;
    end