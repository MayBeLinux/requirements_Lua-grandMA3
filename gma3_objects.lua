-- *********************************************************************
-- a module that contains object helping functions for gma3
-- *********************************************************************
gma3_objects={}

-- ██████╗ ██████╗      ██╗███████╗ ██████╗████████╗███████╗
-- ██╔═══██╗██╔══██╗     ██║██╔════╝██╔════╝╚══██╔══╝██╔════╝
-- ██║   ██║██████╔╝     ██║█████╗  ██║        ██║   ███████╗
-- ██║   ██║██╔══██╗██   ██║██╔══╝  ██║        ██║   ╚════██║
-- ╚██████╔╝██████╔╝╚█████╔╝███████╗╚██████╗   ██║   ███████║
--  ╚═════╝ ╚═════╝  ╚════╝ ╚══════╝ ╚═════╝   ╚═╝   ╚══════╝
                                                          
-- *********************************************************************
-- Add object and get handle
-- *********************************************************************

function gma3_objects:create(pool, nm)
    if pool[nm] then self:delete(pool[nm]) end
    if (type(nm) == "string") then
        Cmd('store '..pool:ToAddr()..' "'..nm..'" /NC')
    else
        Cmd('store '..pool:ToAddr()..' '..nm..' /NC')
    end
    return pool[nm];
end

function gma3_objects:delete(object)
    Cmd('unlock '..object:ToAddr()..' /NC')
    Cmd('delete '..object:ToAddr()..' /NC')
end

function gma3_objects:moveTo(object,index)
    Cmd('Move %s at %d /NC',object:ToAddr(),index)
end

-- *********************************************************************
-- Special object helpers
-- *********************************************************************

function gma3_objects:addMacroLine(object,descriptor)
    local macroline = object:Append();
    for key, value in pairs(descriptor) do
        macroline[key] = value;
    end
end