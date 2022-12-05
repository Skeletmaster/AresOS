local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return true
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
                    print(name .. " " .. tostring(self:getPos(name).pos))
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
    local extra = {
        {
            name = {"Alpha","Alpha","Alpha"},
            type = { "AlienCore", "AlienCore", "AlienCore"},
            center = {33946000.0000,71381990.0000,28850000.0000},
        },
        {
            name = {"Beta","Beta","Beta"},
            type = { "AlienCore", "AlienCore", "AlienCore"},
            center = {-145634000.0000,-10578000.0000,-739465.0000},
        },
        {
            name = {"Delta","Delta","Delta"},
            type = { "AlienCore", "AlienCore", "AlienCore"},
            center = {13666000.0000,1622000.0000,-46840000.0000},
        },
        {
            name = {"Epsilon","Epsilon","Epsilon"},
            type = { "AlienCore", "AlienCore", "AlienCore"},
            center = {48566000.0000,19622000.0000,101000000.0000},
        },
        {
            name = {"Eta","Eta","Eta"},
            type = { "AlienCore", "AlienCore", "AlienCore"},
            center = {-73134000.0000,18722000.0000,-93700000.0000},
        },
        {
            name = {"Gamma","Gamma","Gamma"},
            type = { "AlienCore", "AlienCore", "AlienCore"},
            center = {-64334000.0000,55522000.0000,-14400000.0000},
        },
        {
            name = {"Iota","Iota","Iota"},
            type = { "AlienCore", "AlienCore", "AlienCore"},
            center = {966000.0000,-149278000.0000,-739465.0000},
        },
        {
            name = {"Kappa","Kappa","Kappa"},
            type = { "AlienCore", "AlienCore", "AlienCore"},
            center = {-45534000.0000,-46878000.0000,-739465.0000},
        },
        {
            name = {"Theta","Theta","Theta"},
            type = { "AlienCore", "AlienCore", "AlienCore"},
            center = {58166000.0000,-52378000.0000,-739465.0000},
        },
        {
            name = {"Zeta","Zeta","Zeta"},
            type = { "AlienCore", "AlienCore", "AlienCore"},
            center = {81766000.0000,16912000.0000,23860000.0000},
        },
    }
    static = {}
    for key, tab in pairs(atlas[0]) do
        if key >= 400 then break end
        table.insert(static,{id = key, name = tab.name[1],pos = vec3(tab.center),radius = tab.radius,atmoRadius = tab.atmosphereRadius,range = 500000,type = tab.type[1]})
        if type(static[#static].name) == "table" then print(key) end
    end
    static_x = static
    pipes = initPipes(static_x,false)
    safeZone = {}
    table.insert(safeZone,{name = "Central Zone",pos = vec3(13771471,7435803,-128971),range = 18000000})
    local skiplist = {1,10,11,12,2,21,22,26,27,3,30,31}
    for _,data in pairs(static_x) do
        if inTable(skiplist, data.id) then goto skip end
        table.insert(safeZone,data)
        ::skip::
    end
    for _, tab in pairs(extra) do
        table.insert(static,{id = key, name = tab.name[1],pos = vec3(tab.center),radius = tab.radius,atmoRadius = tab.atmosphereRadius,range = 500000,type = tab.type[1]})
    end
	local SpecialCoords = getPlugin("specialCoords", true,"",true)
    if SpecialCoords ~= nil then 
        for _, tab in pairs(SpecialCoords) do
            table.insert(static,{id = key, name = tab.name[1],pos = vec3(tab.center),radius = tab.radius,atmoRadius = tab.atmosphereRadius,range = 500000,type = tab.type[1]})
        end
    end

end

function initPipes(myPlanets,myChoice)
    local myPipes = {}
    if myChoice then
        for i = 2,#myPlanets,1 do
            table.insert(myPipes,{myPlanets[1].name .. " - " .. myPlanets[i].name,myPlanets[1].pos,myPlanets[i].pos-myPlanets[1].pos})
        end
    else
        for j = 1,#myPlanets-1,1 do
            for i = j+1,#myPlanets,1 do
                table.insert(myPipes,{myPlanets[j].name .. " - " .. myPlanets[i].name,myPlanets[j].pos,myPlanets[i].pos-myPlanets[j].pos})
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
    dynamic[#dynamic+1] = {name = name, pos = pos, type = "customPos"}
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
