system.rawPrint = system.print
function system.print(msg,err)
    if err then
        err = tostring(err):gsub('"%-%- |STDERROR%-EVENTHANDLER[^"]*"', 'chunk'):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    else
        err = "???"
    end
    system.rawPrint(msg .. " ".. err)
end
function print(str)
    system.rawPrint(tostring(str))
end
local u = unit
if devMode == true and not player.hasDRMAutorization() then print("devMode set but no DRM auth") error("devMode set but no DRM auth") u.exit() end
if not u.hasDRM() then if devMode ~= true then print("DRM Required") error("DRM Required") u.exit() else print("DRM requirement skipped by devMode") end end
u.hideWidget()
print("Hyperion Gunner Script V0.98.3")
print("by Hyperion Scripting")
print("for further information you can contact me on discord: Skeletmaster#9864")

system.showScreen(1) ---Start Screen
system.setScreen([[<svg xmlns="http://www.w3.org/2000/svg" width="40%" style="left:30%;top:10%;display:block; position:absolute;" viewBox="0 0 973.35 837.57">
    <defs>
    <style>
    .cls-1 { fill: #798a99; }
    .cls-2 { fill: #bd1730; }
    </style>
    </defs>
    <path class="cls-1" d="M583,93.5H437.52C353.65,361.21,211.41,603.08,25.7,804.26L98.3,930a1892.42,1892.42,0,0,1,828.89-.22l70.63-122.29C810.63,605.68,667.33,362.63,583,93.5ZM508.29,740.05A945,945,0,0,0,206.5,789.18C357.22,655.35,464.94,474.16,506.32,269c41.16,204.15,148,384.54,297.51,518.13A945.66,945.66,0,0,0,508.29,740.05Z" transform="translate(-25.08 -93)"/>
    <circle class="cls-2" cx="481.42" cy="523.5" r="118"/>
    </svg>
    <svg height="100%" width="100%" viewBox="0 0 1920 1080" style="left:0;top:0;display:block; position:absolute;">
    <text x="40%" y="88%" style="fill:#FFFFFF;font-size:50px">Hyperion Scripting</text>
    </svg>]])

local realRequire = require
require = function(name) return print("require '" .. name.. "': deprecated, use getPlugin()") end 
local plugins = {}
local pluginCache = {}
function plugins:fixName(name)
    local pp = packagePrefix
    if string.find(name, pp) then
        name = string.gsub(name, pp, "")
    end
	return name
end

function plugins:unloadPlugin(name,noPrefix,key)
	assert(type(name) == "string", "getPlugin: parameter name has to be string, was " .. type(name))
	name = plugins:fixName(name)
    local pp = packagePrefix
    if type(pluginCache[name]) == "table" and pluginCache[name].valid ~= nil then
        if pluginCache[name]:valid(key) ~= true then
            return nil
        end
    end
	if noPrefix then pp = "" end
	if package.loaded ~= nil and package.loaded[pp..name] ~= nil then
		package.loaded[pp..name] = nil
	end
	if pluginCache[name] ~= nil then
		if type(pluginCache[name]) == "table" and type(pluginCache[name].unregister) == "function" then
			pluginCache[name].unregister()
		end
		pluginCache[name] = nil
	end
end
-- optional key, will checked on function "valid" before returning plugin if it exist, otherwise defaults to return plugin
function plugins:getPlugin(name,noError,key,noPrefix)
    assert(type(name) == "string", "getPlugin: parameter name has to be string, was " .. type(name))
    if noError == nil then noError = false end
	name = plugins:fixName(name)
	
    if not plugins:hasPlugin(name,noError,noPrefix) then return nil end

    if type(pluginCache[name]) == "table" and pluginCache[name].valid ~= nil then
        if pluginCache[name]:valid(key) ~= true then
            if not noError then print("getPlugin '"..name.."':".." Not valid or compatible") end
            return nil
        end
    end

    return pluginCache[name]
end
function plugins:hasPlugin(name,noError,noPrefix)
    assert(type(name) == "string", "hasPlugin: parameter name has to be string, was " .. type(name))
    if noError == nil then noError = false end
    name = plugins:fixName(name)
    local pp = packagePrefix
	if noPrefix then pp = "" end
	
    if pluginCache[name] == nil then
		pluginCache[name] = false

        local ok, res = pcall(realRequire, pp..name)
        if not ok then
            if noError == nil or not noError then
                system.print("hasPlugin '"..name.."': require failed",res)
            end
        else
            pluginCache[name] = res
        end


        if type(pluginCache[name]) == "table" then
            if pluginCache[name].register ~= nil then
                if _ENV["debugscreen"] == nil then _ENV["debugscreen"] = debugscreen end
                if _ENV["register"] == nil then _ENV["register"] = register end
                if _ENV["system"] == nil then _ENV["system"] = system end
                if _ENV["unit"] == nil then _ENV["unit"] = unit end
				if _ENV["player"] == nil then _ENV["player"] = player end
                if _ENV["construct"] == nil then _ENV["construct"] = construct end
                if _ENV["library"] == nil then _ENV["library"] = library end
                local ok2, res2 = pcall(pluginCache[name].register,pluginCache[name],_ENV)
                if not ok2 and not noError then
                    system.print("hasPlugin '"..name.."': register failed",res2)
                end
            end
        else
            if pluginCache[name] ~= nil and pluginCache[name] ~= false then
				if type(pluginCache[name]) == "string" then 
					print("hasPlugin '"..name.."':"..pluginCache[name])
				else
					print("hasPlugin '"..name.."': not table value")
				end
                
            end
        end
    end
    return type(pluginCache[name]) == "table"
end
function unloadPlugin(name,noPrefix) return plugins:unloadPlugin(name,noPrefix) end
function hasPlugin(name,noError,noPrefix) return plugins:hasPlugin(name,noError,noPrefix) end
function getPlugin(name,noError,key,noPrefix) return plugins:getPlugin(name,noError,key,noPrefix) end
local errorStack = {}

-- NEEDS to be the FIRST initialized module! Register is the only implicit dependency
unitType = ""  --export: Set behaviour type of element
renderEveryXFrames = 3 --export: Reduces the framerate of the interface.<br>Higher values will save more performance
executeTotal = 0
executeSet = 0
executeTime = 0
executeLastFrames = 0
screenToggle = true
mode = -1
forceMode = -1

bootTime = system.getArkTime()

useLightStyle = false --export: Light style reduces the interface to digital numbers and indicators

local mode1Color = 120 --export: Base color of interface<br>Range: 0-360<br>Try 120, 184 or 334. Can be any other number in range.
local mode2Color = 184 --export: Space color of interface<br>Range: 0-360<br>Try 120, 184 or 334. Can be any other number in range.

modeColors = {}
modeColors[0] = mode1Color
modeColors[1] = mode2Color

fuelTankHandlingSpace = 5 --export:
fuelTankHandlingRocket = 0 --export:
fuelTankHandlingAtmos = 0 --export:
ContainerOptimization = 5 --export:
FuelTankOptimization = 5 --export:

function collect_keys(t, sort)
    local _k = {}
    for k in pairs(t) do
        _k[#_k+1] = k
    end
    table.sort(_k, sort)
    return _k
end
function sortedPairs(t, sort)
    local keys = collect_keys(t, sort)
    local i = 0
    return function()
        i = i+1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
-- END orderedPairs functions

function timeit(title, f)
    collectgarbage()
    local startTime = system.getTime()
    local result = f()
    local endTime = system.getTime()
    print( title .. ": " .. (endTime - startTime) )
    return result
end
function getRelativePitch(velocity)
    return math.deg(math.atan(velocity[2], velocity[3])) - 90
end
function getRelativeYaw(velocity)
    return math.deg(math.atan(velocity[2], velocity[1])) - 90
end
function mysplit(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end
function inTable(tab, val)
    if type(tab) ~= "table" then return false end
    for k,v in pairs(tab) do
        if v == val then return true,k end
    end
    return false
end
function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    if numDecimalPlaces ~= nil then
        return math.floor(num * mult + 0.5) / mult
    else
        return math.floor((num * mult + 0.5) / mult)
    end
end
local conf = getPlugin("configuration")
if conf.owner ~= nil and conf.owner ~= "" then
    if not inTable(player.getOrgIds(),conf.owner) then system.print("Corp signatur required") error("Corp signatur required") u.exit() end
end
if conf.creater ~= nil and conf.creater ~= "" then
    if not construct.getCreator()[1] == conf.creater then system.print("Corp creater required") error("Corp creater required") u.exit() end
end

register = getPlugin("register")
slots = getPlugin("slots")
-- Simulate system start
register:callAction("systemStart")

--easier time with timers
local Timer = {}
function addTimer(ID, time, callback)
    u.setTimer(ID, time)
    Timer[ID] = callback
end

function onTimer(timerId)
    if Timer[timerId] ~= nil then
        local a,b = pcall(Timer[timerId])
        if not a then print("Timer:" .. b .. "  " .. timerId) end
    end
end

function stopTimer()
    for k,_ in pairs(Timer) do
        u.setTimer(k,0)
    end
end
local DelayCounter = 0
function delay(func, time)
    local ID = "DelayCounter".. DelayCounter
    addTimer(ID, time, function() pcall(func) u.stopTimer(ID) end)
    DelayCounter = DelayCounter + 1
end
register:addAction("unitOnTimer", "Timer", onTimer)

-- Load all registrations from all packages. Will be late init
if devMode == true then
	getPlugin("dev", true)
	getPlugin("devTools", true)
end
getPlugin("optionals", true)

for name,_ in sortedPairs(package.preload) do
	getPlugin(name,true)
end

delay(function() register:callAction("unitOnStart") system.setScreen("") end, 0.5)
