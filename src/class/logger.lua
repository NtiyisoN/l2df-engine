--- Logger class
-- @classmod l2df.class.logger
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Logger works only with l2df v1.0 and higher')

local Class = core.import 'class'

local pairs = _G.pairs
local unpack = _G.unpack
local assert = _G.assert
local print = io.write
local fopen = io.open
local asctime = os.date
local getinfo = debug.getinfo
local strformat = string.format

local colors = not os.getenv('L2DF_NOCOLOR')
local loggers = { }
local levels = { }
local methods = {
    { 'debug',  '\027[35m', true },
    { 'info',   '\027[36m', false },
    { 'success','\027[32m', false },
    { 'warn',   '\027[33m', false },
    { 'error',  '\027[91m', true },
    { 'crit',   '\027[31m', true },
}

io.stdout:setvbuf('no') -- don't touch it

-- 'white' = '\033[97m'
-- 'grey' = '\033[90m'
-- 'red' = '\033[91m'
-- 'blue' = '\033[94m'
-- 'green' = '\033[92m'
-- 'yellow' = '\033[93m'
-- 'marroon' = '\033[31m'
-- 'underline' = '\033[4m'
-- 'italic' = '\033[3m'
-- 'bold' = '\033[1m'
-- '\033[90m%(asctime)s\033[0m'

local Logger = Class:extend({ name = '', level = 'debug' })

    function Logger.get(name)
        return assert(loggers[name], 'Logger not found')
    end

    function Logger.disableColors()
        colors = false
    end

    function Logger:init(name, kwargs)
        assert(not (name and loggers[name]), 'Logger already exists')
        kwargs = kwargs or { }
        self.name = strformat('[%s] ', name)
        self.level = kwargs.level or 'debug'
        self.file = kwargs.file
    end

    for i = 1, #methods do
        local method, color, useDebug = unpack(methods[i])
        local name = method:upper()
        levels[method] = i
        Logger[method] = function (self, format, ...)
            if i < levels[self.level] then return end
            local time = asctime('%d.%m.%y %X')
            local msg = strformat(format, ...)
            if useDebug then
                local info = getinfo(2, 'Sl')
                msg = strformat('%s:%s: %s', info.short_src, info.currentline, msg)
            end

            if colors then
                print(strformat('%s %s%8s\027[0m %s%s\n', time, color, name, self.name, msg))
                if self.file then
                    local log = fopen(self.file, 'a')
                    log:write( strformat('%s %8s %s%s\n', time, name, self.name, msg) )
                    log:close()
                end
            else
                msg = strformat('%s %8s %s%s\n', time, name, self.name, msg)
                print(msg)
                if self.file then
                    local log = fopen(self.file, 'a')
                    log:write(msg)
                    log:close()
                end
            end
        end
    end

return Logger