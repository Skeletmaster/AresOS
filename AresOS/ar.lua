local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "remote" or unitType == "command"
end
self.version = 0.9
self.loadPrio = 1000
self.viewTags = {"hud"}

local u = unit
local s = system
local pipes,locationhandler
local PlanetInfos = true
function self:register(env)
	if not self:valid(auth) then return end
	
	pipes = getPlugin("pipes",true,"AQN5B4-@7gSt1W?;")
	locationhandler = getPlugin("locationhandler",true,"AQN5B4-@7gSt1W?;")
	
    local screener = getPlugin("screener",true)
    if screener ~= nil then
        screener:registerDefaultScreen("mainScreenThird","AR")
        --screener:registerDefaultScreen("mainScreenFirst","AR")

        screener:addView("AR",self)
    end

    register:addAction("option5Start","PlanetSwitch",function() PlanetInfos = not PlanetInfos end)
end

function self:setScreen()
    local closestID,closestDis,List = -1,0.1,{}
    local function VectoHUD(vec,id,l)
        if vec == nil then return end
        if vec.x ~= nil then vec = {vec.x,vec.y,vec.z} end
        local v = library.getPointOnScreen(vec)
        if v[1] == 0 and v[2] == 0 and v[3] == 0 then v = {-10,-10,-10} end
        if id ~= nil then
            local v2 = {v[1]-0.5,v[2]-0.5}
            local dis = math.sqrt(v2[1]^2 + v2[2]^2)
            if dis < closestDis then closestDis = dis closestID = id List = l end
        end
        return v
    end
    svg = [[
    <style>
        #ArMain .circle-1 {position: absolute; left: 960px; top: 540px;}
        #ArMain .Pointer {stroke:#FFFFFF;stroke-width:2;fill:none}
        #ArMain .Pointer1 {stroke:#00FF00;stroke-width:2;fill:none}
        #ArMain .Pointer2 {stroke:#00FFFF;stroke-width:2;fill:none}
        #ArMain svg {display:block; position:absolute; top:0; left:0}
        #ArMain text {font-family:Montserrat;fill:#FFFFFF;font-size:10px;}
    </style>
    <svg id="ArMain" height="100%" width="100%" viewBox="0 0 1920 1080">
    ]]
    local pos = construct.getWorldPosition()
    local wv = construct.getWorldAbsoluteVelocity()
    local posv = vec3(pos)
    local wf = construct.getWorldForward()
    local v
    local dist = 200000000
    --Planets 13
    local plan = locationhandler:getStatic()
    for k,val in pairs(plan) do
        if val.type == "Planet" or val.type == "AlienCore" or val.type == "Station" then
        else
            goto skip
        end
        v = VectoHUD(val.pos,k,plan)
        local dis = tostring(round((val.pos-posv):len() /200000,2))
        if val.type == "Planet" then
            svg = svg .. [[<svg width="30" height="30" viewBox="-150 -150 300 300" x="]].. v[1]*1920 -15 ..[[" y="]].. v[2]*1080 -15 ..[[">
            <g stroke="#ccc" fill="#999" stroke-width="24" opacity="0.6">
            <ellipse cx="0" cy="0" rx="110" ry="110"/>
            <path d="m 59,-90 c245,-10 -264,325 -170,110 c-40,130 310,-100 165,-110" stroke-width="12"/>
            </g></svg>]]
            if PlanetInfos then
                svg = svg .. "<text x=\"".. v[1]*1920 - (#val.name + #dis) * 3 .. "\" y=\"".. v[2]*1080 - 20 .. "\">".. val.name .. ": " .. dis  .. "su</text>"
            end
        elseif val.type == "AlienCore" then

        elseif val.type == "Station" then

        end
        ::skip::
    end

    --Custom Destinations 0 - 3
    if locationhandler.getDynamic ~= nil then
        local coords = locationhandler:getDynamic()
        for k,val in pairs(coords) do
            v = VectoHUD(val.pos,k,coords)
            svg = svg .. [[<svg width="40" height="40" viewBox="-150 -150 300 300" x="]].. v[1]*1920 -20 ..[[" y="]].. v[2]*1080 -20 ..[[">
            <g stroke="#0f0" stroke-width="24" fill="#0f0">
            <path d="m-50,-90 50,-60 50,60"/>
            <path d="m-50,90 50,60 50,-60"/>
            <g stroke-width="4">
            <path d="m0,-150 0,100"/>
            <path d="m0,50 0,100"/>
            <path d="m5,0 4,0"/>
            <path d="m-9,0 4,0"/>
            </g></g></svg>]]
            if PlanetInfos then
                local dis = tostring(round((val.pos-posv):len() /200000,2))
                svg = svg .. "<text x=\"".. v[1]*1920 - (#val.name[1] + #dis) * 3 .. "\" y=\"".. v[2]*1080 - 25 .. "\">".. val.name[1] .. ": " .. dis  .. "su</text>"
            end
        end
    end
    if pipes.nearestSafeZone ~= nil then  --SZ
        v = VectoHUD(pipes.nearestSafeZone)
        svg = svg .. "<circle class=\"Pointer1\" cx=\"".. v[1]*1920 .. "\" cy=\"".. v[2]*1080 .. "\" r=\"12\" />" --svg SZ
    end
    if pipes.pipePoint ~= nil then  --SZ
        v = VectoHUD(pipes.pipePoint)
        svg = svg .. "<circle class=\"Pointer1\" cx=\"".. v[1]*1920 .. "\" cy=\"".. v[2]*1080 .. "\" r=\"12\" />" --svg SZ
        if PlanetInfos then
            svg = svg .. "<text x=\"".. v[1]*1920 - #"cloPipe" * 3 .. "\" y=\"".. v[2]*1080 - 25 .. "\">".. "cloPipe"  .. "</text>"
        end
    end
    if vec3(wv):len() > 0.5 then
        v = VectoHUD({pos[1]+ wv[1]*dist, pos[2]+ wv[2]*dist, pos[3]+ wv[3]*dist})
        --svg = svg .. "<circle class=\"Pointer\" cx=\"".. v[1]*1920 .. "\" cy=\"".. v[2]*1080 .. "\" r=\"12\" />" --svgPrograde
        svg = svg .. [[<svg width="30" height="30" viewBox="-150 -150 300 300" x="]].. v[1]*1920 -15 ..[[" y="]].. v[2]*1080 -15 ..[[">
        <g stroke="#ff0" stroke-width="14" fill="none">
        <ellipse cx="0" cy="0" rx="80" ry="80"/>
        <path d="m0,-150 0,70"/>
        <path d="m-150,0 70,0"/>
        <path d="m150,0 -70,0"/>
        </g></svg>]]
        v = VectoHUD({pos[1]+ wv[1]*dist*-1, pos[2]+ wv[2]*dist*-1, pos[3]+ wv[3]*dist*-1})
        svg = svg ..  [[<svg width="30" height="30" viewBox="-150 -150 300 300" x="]].. v[1]*1920 -15 ..[[" y="]].. v[2]*1080 -15 ..[[">
        <g stroke="#ff0" stroke-width="14" fill="none">
        <ellipse cx="0" cy="0" rx="80" ry="80"/>
        <path d="m0,-150 0,70"/>
        <path d="m-69,40 -61,35"/>
        <path d="m69,40 61,35"/>
        <g stroke-width="4">
        <path d="M-57,-57 57,57"/>
        <path d="M-57,57 57,-57"/>
        </g></g></svg>]]
    end
    v = VectoHUD({pos[1]+ wf[1]*dist, pos[2]+ wf[2]*dist, pos[3]+ wf[3]*dist})
    --svg = svg .. "<circle class=\"Pointer\" cx=\"".. v[1]*1920 .. "\" cy=\"".. v[2]*1080 .. "\" r=\"12\" />"  --svgScope
    svg = svg .. [[<svg width="30" height="30" viewBox="-150 -150 300 300" x="]].. v[1]*1920 -15 ..[[" y="]].. v[2]*1080 -15 ..[[">
        <g stroke="#fff" stroke-width="12" fill="none">
        <ellipse cx="0" cy="0" rx="2" ry="2"/>
        <path d="m-150,0 100,0 50,50 50,-50 100,0"/>
        </g></svg>]]
    v = VectoHUD({pos[1]+ wf[1]*dist*-1, pos[2]+ wf[2]*dist*-1, pos[3]+ wf[3]*dist*-1})
    svg = svg .. "<circle class=\"Pointer\" cx=\"".. v[1]*1920 .. "\" cy=\"".. v[2]*1080 .. "\" r=\"12\" />" --svgGegenScope
    if database.hasKey ~= nil and database.hasKey("Leader") then
        local data = json.decode(database.getStringValue("Leader"))
        if data ~= nil then
            v = VectoHUD(data.p)
            svg = svg .. "<circle class=\"Pointer2\" cx=\"".. v[1]*1920 .. "\" cy=\"".. v[2]*1080 .. "\" r=\"12\" />" --svgGegenScope
        end
    end
    svg = svg .. "</svg>"
    self.closest = List[closestID]
    return svg
end
function self:getLookAdd()
    return self.closest
end
return self

--[[
.circle-1 { position: absolute; left: 960px; top: 540px }


<?xml version="1.0" encoding="utf-8"?>
<svg width="300" height="300">
<title>Scope</title>
<def>
<g id="top" stroke="blue" stroke-width="10" fill="none">
<path d="m110,5 q40,0 40,85 q0,-85 40,-85"/>
<!--ToDo: this path multiple times would be shorter than rotating-->
<ellipse cx="150" cy="150" rx="2"  ry="2" />
</g>
</def>
<use xlink:href="#top"/>
<use xlink:href="#top" transform="rotate(90)" transform-origin="150 150"/>
<use xlink:href="#top" transform="rotate(-90)" transform-origin="150 150"/>
<use xlink:href="#top" transform="scale(1,-1)" transform-origin="150 150"/>
</svg>

<?xml version="1.0" encoding="utf-8"?>
<svg width="300" height="300">
<title>Prograde</title>
<g stroke="orange" stroke-width="10" fill="none">
<ellipse cx="150" cy="150" rx="80" ry="80"/>
<path d="m150,10 0,59"/>
<path d="m0,170 69,-9"/>
<path d="m300,170 -69,-9"/>
</g>
</svg>

--]]
