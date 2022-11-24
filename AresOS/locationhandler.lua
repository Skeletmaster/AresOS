local self = {}
local auth = ""
function self:valid(key)
    if key ~= auth then return false end
    return transponder ~= nil
end
self.version = 0.9
self.loadPrio = 1000
local LookUp,extraPos,static,dynamic,safeZone,pipes,buildStatic,static_x,initPipes,cmd = {},{},{},{},{},{}
function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
    buildStatic()
    cmd = getPlugin("commandhandler",true)
    if cmd ~= nil then
        cmd:AddCommand("add",function (input)
            local num = ' *[+-]?%d+%.?%d*e?[+-]?%d*'
            local posPattern = '(::pos{' .. num .. ',' .. num .. ',' ..  num .. ',' .. num ..  ',' .. num .. '})'

            local name,pos
            if input[3] == nil then name = "CPos" .. #extraPos pos = input[2] else name = input[2] pos = input[3] end
            for s in pos:gmatch("[^\r\n]+") do
                newLocPos  = string.match(pos,posPattern,1)
                if newLocPos == nil then
                    system.print("No Pos")
                else
                    nums = {}
                    for num in string.gmatch(pos, num) do
                        nums[#nums+1] = num
                    end
                    name = tostring(name)
                    name = string.upper(string.sub(name,0,1)) .. string.sub(name,2,#name)

                    self:addPos(name,vec3(nums[3],nums[4],nums[5]))
                    print(name .. " " .. tostring(self:getPos(name).center))
                end
            end
        end,"adds Custom Postition")
        cmd:AddCommand("rem",function (input)
            local name = input[2]
            name = string.upper(string.sub(name,0,1)) .. string.sub(name,2,#name)
            self:delPos(name)
        end,"removes Custom Postition")
        cmd:AddCommand("remall",function (input)
            self:delAllPos()
        end,"removes All Custom Postitions")
    end
end

function buildStatic()
    local atlas = getPlugin("atlas",false,"",true)
    local extra = {}
    static = {}
    for key, tab in pairs(atlas[0]) do
        if key > 400 then break end
        table.insert(static,{id = key, name = tab.name[1],pos = vec3(tab.center),radius = tab.radius,atmoRadius = tab.atmosphereRadius,range = 500000})
    end
    static_x = static
    for _, tab in pairs(extra) do
        table.insert(static,tab)
    end
    safeZone = {}
    table.insert(safeZone,{"Central Zone", vec3(13771471,7435803,-128971),18000000})
    local skiplist = {1,10,11,12,2,21,22,26,27,3,30,31}
    for id,data in pairs(static_x) do
        if inTable(skiplist, data.id) then goto skip end
        if id >= 400 then goto skip end 
        table.insert(safeZone,data)
        ::skip::
    end
    pipes = initPipes(static_x,false)
end
function initPipes(myPlanets,myChoice)
    local myPipes = {}
    if myChoice then    
        for i = 2,#myPlanets,1 do
            table.insert(myPipes,{myPlanets[1].name .. " - " .. myPlanets[i].name,myPlanets[1].center,myPlanets[i].center-myPlanets[1].center})
        end
    else
        for j = 1,#myPlanets-1,1 do
            for i = j+1,#myPlanets,1 do
                table.insert(myPipes,{myPlanets[j].name .. " - " .. myPlanets[i].name,myPlanets[j].center,myPlanets[i].center-myPlanets[j].center})
            end
        end
    end
    return myPipes
end
function self:getStatic()
    return static
end
function self:getDynamic()
    return dynamic
end
function self:getPipes()
    return pipes
end
function self:getSafeZones()
    return safeZone
end
function self:addPos(name,pos)
    if pos.x == nil then
        pos = vec3(pos)
    end
    dynamic[#dynamic+1] = {name = {name}, center = pos, type = {"customPos"}}
    LookUp[name] = #dynamic
end
function self:getAllPos()
    return dynamic
end
function self:getPos(name)
    return dynamic[LookUp[name]]
end
function self:delPos(name)
    table.remove(dynamic,LookUp[name])
end
function self:delAllPos()
    dynamic = {}
end
return self
