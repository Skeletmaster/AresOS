local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "remote" or unitType == "command"
end

self.version = 0.91
self.loadPrio = 1000
local construct = construct
local system = system
local ap, ar, time, baseFly, Mode, inject, locationhandler, ms
local selMode = "Route"
local function routeSelection(mx, my, mstate, mouseInWindow)
    local svg = [[<rect x="2%" y="18%" rx="2" ry="2" width="47%" height="80%" style="fill:#4682B4;fill-opacity:0.35" />
        <rect x="51%" y="18%" rx="2" ry="2" width="47%" height="73%" style="fill:#4682B4;fill-opacity:0.35" />
        <rect x="51%" y="93%" rx="2" ry="2" width="47%" height="5%" style="fill:#4682B4;fill-opacity:0.35" />]]
    return svg
end

local Offset1, Offset2, Dest = 0, 0
local function targetSelection(mx, my, mstate, mouseInWindow)
    if mouseInWindow and (18 <= my and my <= 76 and 2 <= mx and mx <= 60) then
        if baseFly ~= nil then baseFly:setUpdateState(false) end
        Offset1 = Offset1 + system.getMouseWheel() * -1
        if Offset1 < 0 then Offset1 = 0 end
    elseif mouseInWindow and (78 <= my and my <= 98 and 2 <= mx and mx <= 60) then
        if baseFly ~= nil then baseFly:setUpdateState(false) end
        Offset2 = Offset2 + system.getMouseWheel() * -1
    else
        if baseFly ~= nil then baseFly:setUpdateState(true) end
    end
    if Offset1 < 0 then Offset1 = 0 end
    if Offset2 < 0 then Offset2 = 0 end
    local function addTarget(y, name, type, dis, tab)
        local html = [[<tr><td>]]..name:sub(0, 13)..[[</td><td>]]..type:sub(0, 6)..[[</td><td>]]..dis..[[</td></tr>]]

        ms:addButton(2.5, y - 1.5, 19, 2, function()
            Dest = tab
        end)
        return html
    end

    local svg = [[<rect x="2%" y="18%" rx="2" ry="2" width="25%" height="53%" style="fill:#4682B4;fill-opacity:0.35" />
        <rect x="2%" y="73%" rx="2" ry="2" width="25%" height="25%" style="fill:#4682B4;fill-opacity:0.35" />
        <rect x="29%" y="18%" rx="2" ry="2" width="69%" height="53%" style="fill:#4682B4;fill-opacity:0.35" />
        <rect x="29%" y="73%" rx="2" ry="2" width="69%" height="25%" style="fill:#4682B4;fill-opacity:0.35" />]]
    local html = ""
    local y = 20.5
    local static = locationhandler:getStatic()
    local wPos = vec3(construct.getWorldPosition())
    local html = [[
        <style>
            .table tr,
            .table th {
                border-bottom: 1px solid #000;
                height: 2%
            }
        </style>
        <table class="table"
            style="position: absolute;top:18.5%;left:2.5%;width: 24%;text-align: center;border-color: black;border-collapse: collapse;">
            <tr>
                <th>
                    Name
                </th>
                <th>
                    Type
                </th>
                <th>
                    Dis
                </th>
            </tr>
        ]]
    for i = 1, 25, 1 do
        local tab = static[i + Offset1]
        if tab == nil then Offset1 = Offset1 - 1 break end
        html = html .. addTarget(y, tab.name, tab.type, disToString(tab.pos - wPos), tab)
        y = y + 2
    end
    y = 75.5
    html = html .. [[
        </table>
        <table class="table"
            style="position: absolute;top:73.5%;left:2.5%;width: 24%;text-align: left;border-color: black;border-collapse: collapse;">
            <tr>
                <th>
                    Name
                </th>
                <th>
                    Type
                </th>
                <th>
                    Dis
                </th>
            </tr>
        ]]
    local dyn = locationhandler:getDynamic()
    for i = 1, 10, 1 do
        local tab = dyn[i + Offset2]
        if tab == nil then Offset2 = Offset2 - 1 break end
        html = html .. addTarget(y, tab.name, "", disToString(tab.pos - wPos), tab)
        y = y + 2
    end

    svg = svg .. ms:addFancyButton(30,74,10,4,function ()
        if Dest == nil then return end
        
    end,"OffPipeRoute",mx,my)
    svg = svg .. ms:addFancyButton(30,79,10,4,function ()
        if Dest == nil then return end

    end,"CalcRoute",mx,my)

    return svg, html .. "</table>"
end

local function specialSelection(mx, my, mstate, mouseInWindow)
    local svg = [[<rect x="2%" y="18%" rx="2" ry="2" width="96%" height="80%" style="fill:#4682B4;fill-opacity:0.35" />]]
    return svg
end

local selection = { Route = routeSelection, Target = targetSelection, Special = specialSelection }
function self:register(env)
    if not self:valid(auth) then return end
    ap = getPlugin("autopilot", true, auth)
    if ap == nil then return end
    ar = getPlugin("ar", true, auth)
    baseFly = getPlugin("baseflight", false, auth)
    locationhandler = getPlugin("locationhandler", false, auth)
    register:addAction("option4Start", "ap", function()
        time = system.getArkTime()
    end)
    register:addAction("option4Stop", "ap", function()
        if system.getArkTime() - time > 1 then
            print("Test")
            if Mode ~= nil then
                baseFly:setFlightMode(Mode)
            end
        else
            local t = ar:getLookAdd()
            if t == nil then
                print("No Target")
            else
                t = vec3(t.pos)
            end
            --setTarget
        end
    end)

    local eStopList = { "brake", "forward", "backward", "yawleft", "yawright", "strafeleft", "straferight" }
    local eStop = ap.eStop
    for _, value in pairs(eStopList) do
        register:addAction(value .. "Start", "eStop", eStop)
    end
    ms = getPlugin("menuscreener", true, auth)
    if ms ~= nil then
        ms:addMenu("Pilot", function(mx, my, mstate, mouseInWindow)
            local svg = [[<rect x="2%" y="9%" rx="2" ry="2" width="96%" height="7%" style="fill:#4682B4;fill-opacity:0.35" />]]
            svg = svg .. ms:addFancyButton(5, 10, 25, 5, function()
                selMode = "Route"
            end, "Route", mx, my)
            svg = svg .. ms:addFancyButton(38, 10, 25, 5, function()
                selMode = "Target"
            end, "Target", mx, my)
            svg = svg .. ms:addFancyButton(71, 10, 25, 5, function()
                selMode = "Special"
            end, "Special", mx, my)
            local a, b = selection[selMode](mx, my, mstate, mouseInWindow)
            svg = svg .. a
            return svg, b
        end)
    end
end

function self:setScreen()

end

--toDo Planets
function dist2Plant(myLine, myPlanet)
    local line_vec = myLine[2] - myLine[3]
    local pnt_vec = myLine[2] - myPlanet[2]
    local line_len = line_vec:len()
    if line_len * 1.5 < pnt_vec:len() then return math.huge, vec3() end
    local line_norm = line_vec:normalize()
    local pnt_vec_scale = pnt_vec / line_len
    local t = line_norm:dot(pnt_vec_scale)
    if t < 0.0 then t = 0.0 end
    if t > 1.0 then t = 1.0 end
    local nearest_on_line = line_vec * t
    local dist = (pnt_vec - nearest_on_line):len()
    --local nearest_pos = myLine[2] + nearest_on_line
    return dist, nearest_on_line
end

function checkRoute(curpos, opcurpos, optarpos, tarpos)
    minDist = math.huge
    for pId, planetData in pairs(listPlanets) do
        dist, line, planet = dist2Plant(lineData, planetData)
        --system.print(line .. " is " .. getDistanceDisplayString(dist,2) .. " away from " .. planet)
        if dist < 200000 then
            system.print(line .. " is " .. getDistanceDisplayString(dist, 2) .. " away from " .. planet)
        end
        if dist < minDist then minDist = dist end
    end
end

local corouCalc
function checkSafeRoute(route, onwPos)
    local isSafe = true
    local prePos
    if onwPos then prePos = vec3(construct.getWorldPosition()) end
    local linedata
    for key, des in pairs(route.p) do
        if prepos == nil then goto skip end
        linedata = { "", prePos, des.c }
        for k, planetData in pairs(Planets) do
            dist, lotP = dist2Plant(linedata, planetData)
            local radius = planetData.radius
            if planetData.atmosphereRadius > radius then radius = planetData.atmosphereRadius end
            if dist < radius * 1.2 then
                local newPos
                if dist == 0 then
                    newPos = vec3(1, 0, 1):cross(linedata[3] - linedata[2])
                    newPos = newPos:normalize() * radius * 1.7 + Planets.pos
                else
                    newPos = (lotP - Planets.pos):normalize() * radius * 1.7 + Planets.pos
                end
                route = inject(route, { b = k, i = true, c = newPos, n = "AvoidPlanet" }, key)
            end
        end
        ::skip::
        prePos = des.c
    end
    if not isSafe then coroutine.yield(corouCalc) route = checkSafeRoute(route) end
    return route
end

function inject(tab, val, ind)
    ind = ind or #tab
    if ind > #tab then return tab end
    local newTab = tab
    newTab[ind + 1] = val
    for i = ind + 1, #tab, 1 do
        newTab[i + 1] = tab[i]
    end
    return newTab
end

function disToString(str)
    if type(str) == "number" then

    else
        str = str:len()
    end
    if str < 5000 then
        return round(str) .. "m"
    elseif str < 100000 then
        return round(str / 1000) .. "km"
    else
        return round(str / 200000) .. "su"
    end
end

return self