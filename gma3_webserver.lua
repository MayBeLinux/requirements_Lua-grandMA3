local socket    = require( "socket" )
local lfs       = require( "lfs" )

local E = function (text, ...) 
    text = string.format("WebServer: " .. text, ...)
    Echo(text)
end

local originalErrEcho = ErrEcho
local ErrEcho = function (text, ...) 
    text = string.format("WebServer: " .. text, ...)
    originalErrEcho(text)
end


local function readFileContent(filePath)
    local file = io.open(filePath, "r")
    if file then 
        local fileContent = file:read "*a"
        file:close()
        return fileContent
    end
    ErrEcho(string.format("File '%s' not found", filePath))
    return nil
end


---@param tag string
---@param content string|string[]
---@param parameters ?{[string]:string}
---@return string html
local function htmlTag(tag, content, parameters)
    parameters = parameters or {}
    local t = {}
    local function add(...)
        for i, v in ipairs({...})do  table.insert(t, v) end
    end

    add("<", tag)
    for k, v in pairs(parameters) do add(" ", k, "=", v) end
    add(">")

    if type(content) == "table" then
        for i, v in ipairs(content) do add("\n", v) end
        add("\n")
    else
        add(content)
    end

    add("</", tag, ">")
    return table.concat(t)
end


local function formatStringHtml(str)
    str = string.gsub(str, "\n", "<br />")
    return str
end


local httpTimePattern ="%a+, (%d+) (%a+) (%d+) (%d+):(%d+):(%d+) GMT"
local httpTimeMonths={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}
local function httpTimeToUnix(timeString)
    local date={}
    date.day, date.month, date.year, date.hour, date.min, date.sec = timeString:match(httpTimePattern)
    date['month']=httpTimeMonths[date['month']]
    date["isdst"] = false
    local offset=os.time()-os.time(os.date("!*t"))
    return os.time(date)+offset
end


-- ██╗  ██╗████████╗███╗   ███╗██╗               ██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗ 
-- ██║  ██║╚══██╔══╝████╗ ████║██║               ██╔══██╗██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗
-- ███████║   ██║   ██╔████╔██║██║         █████╗██████╔╝██║   ██║██║██║     ██║  ██║█████╗  ██████╔╝
-- ██╔══██║   ██║   ██║╚██╔╝██║██║         ╚════╝██╔══██╗██║   ██║██║██║     ██║  ██║██╔══╝  ██╔══██╗
-- ██║  ██║   ██║   ██║ ╚═╝ ██║███████╗          ██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║
-- ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝╚══════╝          ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝


--- this Bulder generates a simple Html Document in a predefined style.
--- for this different snippsets are predefined
---@class HtmlBuilder
local HtmlBuilder = {
    _header      = nil,  ---@type string[]
    _bodyContent = nil,  ---@type string[]
}

---@param title string the title of the html document
function HtmlBuilder:new(title)
    local newObj = setmetatable({}, {__index = HtmlBuilder}) ---@type HtmlBuilder
    newObj._header = {
        htmlTag("title", title)
    }
    newObj._bodyContent = {}

    return newObj
end


function HtmlBuilder:appendToHeader(html)
    table.insert(self._header, html)
end
function HtmlBuilder:appendToBody(html)
    table.insert(self._bodyContent, html)
end


function HtmlBuilder:getHtml()
    local htmlLines = {
        "<!DOCTYPE html>",
        "",
        htmlTag("html", {
            htmlTag("head",  self._header),
            htmlTag("body",  self._bodyContent)
        }),
    }
    return table.concat(htmlLines, "\n")
end

function HtmlBuilder:newLine()
    self:appendToBody("<br/>")
end

---@param text string
---@param parameters ?table
function HtmlBuilder:Text(text, parameters)
    local parameters = parameters or {}
    self:appendToBody(htmlTag("font", formatStringHtml(text) , parameters))
end


---@param text string
---@param parameters ?table
function HtmlBuilder:Heading(text, parameters)
    local parameters = parameters or {}
    self:appendToBody(htmlTag("h2", formatStringHtml(text) , parameters))
end

---@param text string
---@param target string
---@param parameters ?table
function HtmlBuilder:Link(text, target, parameters)
    local parameters = parameters or {}
    parameters.href = target
    self:appendToBody(htmlTag("a", formatStringHtml(text) , parameters))
end


---@param content string[][]
---@param parameters ?{hasHeadings?:boolean} 
function HtmlBuilder:Table(content, parameters)
    parameters = parameters or {}
    parameters.hasHeadings = parameters.hasHeadings or true

    local tableContent = {}
    for rowindex, row in ipairs(content) do
        local tableRow = {}
        for colIndex, content in ipairs(row) do
            local tagType = "td"
            if rowindex == 1 and parameters.hasHeadings then tagType = "th" end
            table.insert(tableRow, htmlTag(tagType, formatStringHtml(content)))
        end
        table.insert(tableContent, htmlTag("tr", tableRow))
    end
    self:appendToBody(htmlTag("table", tableContent, {style="width:100%"}))
end




-- ██╗  ██╗████████╗████████╗██████╗     ██████╗ ███████╗ ██████╗ ██╗   ██╗███████╗███████╗████████╗
-- ██║  ██║╚══██╔══╝╚══██╔══╝██╔══██╗    ██╔══██╗██╔════╝██╔═══██╗██║   ██║██╔════╝██╔════╝╚══██╔══╝
-- ███████║   ██║      ██║   ██████╔╝    ██████╔╝█████╗  ██║   ██║██║   ██║█████╗  ███████╗   ██║   
-- ██╔══██║   ██║      ██║   ██╔═══╝     ██╔══██╗██╔══╝  ██║▄▄ ██║██║   ██║██╔══╝  ╚════██║   ██║   
-- ██║  ██║   ██║      ██║   ██║         ██║  ██║███████╗╚██████╔╝╚██████╔╝███████╗███████║   ██║   
-- ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝         ╚═╝  ╚═╝╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚══════╝╚══════╝   ╚═╝   

---@class HttpRequest
local HttpRequest = {
    type             = nil, ---@type string
    path             = nil, ---@type string
    search           = nil, ---@type {[string]:string}
    httpVer          = nil, ---@type string
    host             = nil, ---@type string
    additionalFields = nil, ---@type {[string]:string}
    client           = nil,
}

---@param request HttpRequest
local function dumpHttpRequest(request)
    Echo("")
    E("### Dump http Request ###")
    E("type:    %s", request.type)
    E("path:    %s", request.path)
    E("httpVer: %s", request.httpVer)
    E("host:    %s", request.host)
    E("search:")
    for k, v in pairs(request.search) do
        E("  %s: %s",  k, v)
    end
    E("additionalFields:")
    for k, v in pairs(request.additionalFields) do
        E("  %s: %s",  k, v)
    end
    E("#########################")
end





-- ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ 
-- ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
-- ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
-- ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
-- ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
-- ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝

local function buildHttpHeader(code, message, additionalFields)
    additionalFields = additionalFields or {}
    local lines = {string.format("HTTP/1.1 %d %s", code, message)}
    local function add(field, value)
        table.insert(lines, string.format("%s: %s", field, value))
    end
	add( "Date", os.date( "!%a, %d %b %Y %H:%M:%S GMT" ) )
	add( "Connection", "close" )
    for field, value in pairs(additionalFields) do
        add(field, value)
    end
    return table.concat( lines, "\r\n" ) .. "\r\n\r\n"
end

local registeredRequestHandlers = {}
local registeredWebPages = {}
local registeredWebFolders = {}

---@param type string
---@param path string the URL path of the Page
---@param handlerFunction nil|fun(client, httpRequest:HttpRequest):any --TODO define return
local function registerHttpRequestHandler(type, path, handlerFunction)
    registeredRequestHandlers[type] = registeredRequestHandlers[type] or {}
    registeredRequestHandlers[type][path] = handlerFunction
end

---@param path string the URL path of the Page
---@param html string|fun(HttpRequest):string|nil either the Html as string or a function that generates the Html
local function registerWebPage(path, html)
    registeredWebPages[path] = html
end

---@param path string the URL path of the Page
---@param absolutePath string|nil the local path to the folder to be used
local function registerWebFolder(path, absolutePath)
    if absolutePath then
        local attr = lfs.attributes(absolutePath)
        if not attr then 
            error("directory not valid: " .. absolutePath)
        end
        if not attr.mode == "directory" then
            error("directory not valid: " .. absolutePath)
        end
    end
    table.insert(registeredWebFolders, {path = path, absolutePath = absolutePath})
end


local urlSpecialCharacters = {
    ["20"] = " ",    ["21"] = "!",    ["22"] = "\"",   ["23"] = "#",    ["24"] = "$",    ["25"] = "%",
    ["26"] = "&",    ["27"] = "'",    ["28"] = "(",    ["29"] = ")",    
    ["2A"] = "*",    ["2B"] = "+",    ["2C"] = ",",    ["2D"] = "-",    ["2E"] = ".",    ["2F"] = "/",
    ["3A"] = ":",    ["3B"] = ";",    ["3C"] = "<",    ["3D"] = "=",    ["3E"] = ">",    ["3F"] = "?",
    ["40"] = "@",
    ["5B"] = "[",    ["5C"] = "\\",   ["5D"] = "]",    ["5E"] = "^",    ["5F"] = "_",
    ["60"] = "`",
    ["7B"] = "{",    ["7C"] = "|",    ["7D"] = "}",    ["7E"] = "~",
}
local function urlEncode(text)
    for k,v in pairs(urlSpecialCharacters) do
        text = string.gsub(text, v, "%"..k)
    end
    return text
end

local function urlDecode(text)
    for k,v in pairs(urlSpecialCharacters) do
        text = string.gsub(text, "%%"..k, v)
        text = string.gsub(text, "%%"..string.lower(k), v)
    end
    return text
end

--- reads the Request of a client and returns the lines as a Table
--- @return HttpRequest|nil
local function readhttpHeader(client)
    local requestLines = {}
    while true do
        local line = client:receive()
        if line == nil then return end
        if line == "" then break end
        table.insert(requestLines, line)
    end

    local httpRequest = {} ---@type HttpRequest
    httpRequest.client = client
    httpRequest.search = {}
    httpRequest.additionalFields = {}

    for i, line in ipairs(requestLines) do
        if i == 1 then
            local firstLineParts = string.split(line--[[@as stringlib]], " ") 
            httpRequest.type    = firstLineParts[1]
            local path          = firstLineParts[2]
            httpRequest.httpVer = firstLineParts[3]

            local pathSplit = string.split(path--[[@as stringlib]], "?")
            httpRequest.path = urlDecode(pathSplit[1])
            if #pathSplit == 2 then
                local searchsplit = string.split(pathSplit[2]--[[@as stringlib]], "&") 
                for _, v in ipairs(searchsplit) do
                    local searchPair = string.split(v--[[@as stringlib]], "=") 
                    httpRequest.search[urlDecode(searchPair[1])] = urlDecode(searchPair[2])
                end
            end
        else
            local delinmiterPos = string.find(line, ":")
            local key   = string.sub(line, 1, delinmiterPos-1)
            local value = string.sub(line, delinmiterPos+2)
            if key == "Host" then
                httpRequest.host = value
            else
                httpRequest.additionalFields[key] = value
            end
        end
    end
    --dumpHttpRequest(httpRequest)
    return httpRequest
end

local mimeTypes = {--TODO support more content Types
    [".html"] = "text/html",
    [".js"]   = "text/javascript",
    [".json"] = "application/json",
    [".txt"]  = "text/plain",
}

---@param httpRequest HttpRequest
local function processHttpRequest(client, httpRequest)
    local typeHandlers = registeredRequestHandlers[httpRequest.type]
    if typeHandlers then
        local requestHandler = typeHandlers[httpRequest.path]
        if requestHandler then
            requestHandler(client, httpRequest)
            return
        end
    end

    local webPage = registeredWebPages[httpRequest.path]
    if webPage then
        local content
        if type(webPage) == "string" then
            content = webPage 
        else
            content = webPage(httpRequest)
        end

        local header = buildHttpHeader(200, "OK", {
            ["Content-Length"] = #content,
            ["Content-type"]   = "text/html"
        })

        if httpRequest.type == "HEAD" then
            client:send(header)
        elseif httpRequest.type == "GET" then
            client:send(header)
            client:send(content)
        else
            client:send(buildHttpHeader(501, "Not Implemented"))
        end
        return
    end

    local function send404()
        client:send(buildHttpHeader(404, "Not Found"))
        client:send("404 Not Found")
    end

    for _, webfolder in ipairs(registeredWebFolders) do
        if string.find(httpRequest.path .."/", webfolder.path .."/", 1, true) == 1 then
            local filepath = webfolder.absolutePath .. string.sub(httpRequest.path, string.len(webfolder.path)+1)
            
            local attr = lfs.attributes(filepath)
            if attr and attr.mode == "directory" then
                filepath = filepath .. "/index.html"
                attr = lfs.attributes(filepath)
            end
            if attr then
                if httpRequest.additionalFields["If-Modified-Since"] then
                    local ifModSince = httpTimeToUnix(httpRequest.additionalFields["If-Modified-Since"])
                    if attr.modification <= ifModSince then
                        client:send(buildHttpHeader(304, "Not Modified", {
                            ["Last-Modified"] = os.date( "!%a, %d %b %Y %H:%M:%S GMT" , attr.modification) 
                        }))
                        return
                    end
                end

                local filecontent = readFileContent(filepath)
                if not filecontent then
                    client:send(buildHttpHeader(500, "Internal Server Error"))
                    client:send("500 Internal Server Error: File could not be opened")
                    return
                end

                local contentType = ""
                for k,v in pairs(mimeTypes) do
                    if string.sub(filepath, #filepath-#k +1) == k then
                        contentType = v
                        break
                    end
                end
                local header = buildHttpHeader(200, "OK", {
                    ["Content-Length"] = #filecontent,
                    ["Content-type"]   = contentType,
                    ["Last-Modified"] = os.date( "!%a, %d %b %Y %H:%M:%S GMT" , attr.modification) 
                })
                if httpRequest.type == "HEAD" then
                    client:send(header)
                elseif httpRequest.type == "GET" then
                    client:send(header)
                    client:send(filecontent)
                else
                    client:send(buildHttpHeader(501, "Not Implemented"))
                end
                return
            end
        end
    end

    send404()
end



--- read, process and respond to the request of a client
local function handleClient(client)
    local httpRequest = readhttpHeader(client)
    if httpRequest then
        processHttpRequest(client, httpRequest)
    else
        client:send(buildHttpHeader(400, "Bad Request"))
        client:send("400 Bad Request")
    end
end


local serverRunning = false
local server
local function serverMain()
    server = assert(socket.bind("*", 80))
    server:settimeout(0);
    E("Lua Webserver started")
    while serverRunning do
        local client = server:accept()
        if client then

            local passed, result = xpcall(handleClient, debug.traceback, client);
            if not passed then 
                if result then
                    for _, errorLine in ipairs(string.split(result, "\n")) do ErrEcho("%s", errorLine) end
                end
                client:send(buildHttpHeader(500, "Internal Server Error"))
                client:send("500 Internal Server Error")
            end
			client:close()
        end
        coroutine.yield();
    end
end


local function startServer()
    assert(not serverRunning, "Webserver allready in use (or it wasn't closed properly the last time)")
    serverRunning = true
    Timer(serverMain, 0, 1)
end

local function stopServer()
    serverRunning = false
    server:close()
    E("Lua Webserver stopped")
end

return {
    startServer = startServer,
    stopServer  = stopServer,
    HtmlBuilder = HtmlBuilder,
    htmlTag = htmlTag,
    buildHttpHeader = buildHttpHeader,
    dumpHttpRequest = dumpHttpRequest,
    registerHttpRequestHandler = registerHttpRequestHandler,
    registerWebPage = registerWebPage,
    registerWebFolder = registerWebFolder,
    urlEncode = urlEncode,
    urlDecode = urlDecode,
}
