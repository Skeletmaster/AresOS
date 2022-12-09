local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "remote" or unitType == "command"
end
self.version = 0.9
self.loadPrio = 1000
local construct = construct
local system = system
local ap,ar,time,baseFly,Mode,inject,locationhandler,ms
local selMode = "Route"
local function routeSelection(mx,my,mstate,mouseInWindow)
    local svg = [[<rect x="2%" y="18%" rx="2" ry="2" width="47%" height="80%" style="fill:#4682B4;fill-opacity:0.35" />
        <rect x="51%" y="18%" rx="2" ry="2" width="47%" height="73%" style="fill:#4682B4;fill-opacity:0.35" />
        <rect x="51%" y="93%" rx="2" ry="2" width="47%" height="5%" style="fill:#4682B4;fill-opacity:0.35" />]]
return svg
end
local Offset1,Offset2,Dest = 0,0
local function targetSelection(mx,my,mstate,mouseInWindow)
    if mouseInWindow and (18 <= my and my <= 76 and  2 <= mx and mx <=  60) then
        if baseFly ~= nil then baseFly:setUpdateState(false) end
        Offset1 = Offset1 + system.getMouseWheel() * -1
        if Offset1 < 0 then Offset1 = 0 end
    elseif mouseInWindow and (78 <= my and my <= 98 and  2 <= mx and mx <=  60) then
        if baseFly ~= nil then baseFly:setUpdateState(false) end
        Offset2 = Offset2 + system.getMouseWheel() * -1
    else
        if baseFly ~= nil then baseFly:setUpdateState(true) end
    end
    if Offset1 < 0 then Offset1 = 0 end
    if Offset2 < 0 then Offset2 = 0 end
    local function addTarget(y,name,type,dis,o,tab)
        if o then
            o = 0.2
        else
            o = 0.0
        end
        local svg = [[
            <rect x="2.5%" y="]]..y-1.5 ..[[%" rx="2" ry="2" width="19%" height="2%" style="fill:#4682B4;fill-opacity:]]..o..[[" />
            <text x="2.5%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:4">]]..name:sub(0,13)..[[</text>
            <text x="12.5%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:4">]]..type:sub(0,6)..[[</text>
            <text x="17.5%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:4">]]..dis..[[</text>]]
        ms:addButton(2.5,y-1.5,19,2,function ()
            Dest = tab
        end)
        return svg
    end
    local svg = [[<rect x="2%" y="18%" rx="2" ry="2" width="25%" height="53%" style="fill:#4682B4;fill-opacity:0.35" />
        <rect x="2%" y="73%" rx="2" ry="2" width="25%" height="25%" style="fill:#4682B4;fill-opacity:0.35" />
        <rect x="29%" y="18%" rx="2" ry="2" width="69%" height="53%" style="fill:#4682B4;fill-opacity:0.35" />
        <rect x="29%" y="73%" rx="2" ry="2" width="69%" height="25%" style="fill:#4682B4;fill-opacity:0.35" />]]
    local html = ""
    local y = 27
    local static = locationhandler:getStatic()
    local wPos = vec3(construct.getWorldPosition())
    local o = true
    for i = 1, 25, 1 do
        local tab = static[i+Offset1]
        if tab == nil then Offset1 = Offset1 - 1 break end
        svg = svg .. addTarget(y,tab.name,tab.type,disToString(tab.pos-wPos),o,tab)
        y = y + 2
        o = not o
    end
    o = true
    y = 80
    local dyn = locationhandler:getDynamic()
    for i = 1, 10, 1 do
        local tab = dyn[i+Offset2]
        if tab == nil then Offset2 = Offset2 - 1 break end
        svg = svg .. addTarget(y,tab.name,"",disToString(tab.pos-wPos),o,tab)
        y = y + 2
        o = not o
    end
return svg,html
end
local function specialSelection(mx,my,mstate,mouseInWindow)
    local svg = [[<rect x="2%" y="18%" rx="2" ry="2" width="96%" height="80%" style="fill:#4682B4;fill-opacity:0.35" />]]
return svg
end
local selection = {Route = routeSelection,Target = targetSelection, Special = specialSelection}
function self:register(env)
	if not self:valid(auth) then return end
    ap = getPlugin("autopilot",true,auth)
    if ap == nil then return end
    ar = getPlugin("ar",true,auth)
    baseFly = getPlugin("baseflight",false,auth)
    locationhandler = getPlugin("locationhandler",false,auth)
    register:addAction("option4Start","ap",function ()
        time = system.getArkTime()
    end)
    register:addAction("option4Stop","ap",function ()
        if system.getArkTime()-time > 1 then
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

    local eStopList = {"brake","forward","backward","yawleft","yawright","strafeleft","straferight"}
    local eStop = ap.eStop
    for _, value in pairs(eStopList) do
        register:addAction(value .. "Start","eStop",eStop)
    end
    ms = getPlugin("menuscreener",true,auth)
    if ms ~= nil then
        ms:addMenu("Pilot",function (mx,my,mstate,mouseInWindow)
            local svg = [[<rect x="2%" y="9%" rx="2" ry="2" width="96%" height="7%" style="fill:#4682B4;fill-opacity:0.35" />]]
            svg = svg .. ms:addFancyButton(5,10,25,5,function ()
                selMode = "Route"
            end,"Route",mx,my)
            svg = svg .. ms:addFancyButton(38,10,25,5,function ()
                selMode = "Target"
            end,"Target",mx,my)
            svg = svg .. ms:addFancyButton(71,10,25,5,function ()
                selMode = "Special"
            end,"Special",mx,my)
            local a,b = selection[selMode](mx,my,mstate,mouseInWindow)
            svg = svg .. a
            return svg,b
        end)
    end
end

function self:setScreen()
    
end
--toDo Planets
function dist2Plant(myLine, myPlanet)
    local line_vec = myLine[2] - myLine[3]
    local pnt_vec =  myLine[2] - myPlanet[2]
    local line_len = line_vec:len()
    if line_len*1.5 < pnt_vec:len() then return math.huge, vec3() end
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
    for pId,planetData in pairs(listPlanets) do
        dist, line, planet = dist2Plant(lineData, planetData)
        --system.print(line .. " is " .. getDistanceDisplayString(dist,2) .. " away from " .. planet)
        if dist < 200000 then
            system.print(line .. " is " .. getDistanceDisplayString(dist,2) .. " away from " .. planet)
        end
        if dist < minDist then minDist = dist end
    end
end
local corouCalc
function checkSafeRoute(route,onwPos)
    local isSafe = true
    local prePos
    if onwPos then prePos = vec3(construct.getWorldPosition()) end
    local linedata
    for key, des in pairs(route.p) do
        if prepos == nil then goto skip end
        linedata = {"",prePos,des.c}
        for k, planetData in pairs(Planets) do
            dist,lotP = dist2Plant(linedata, planetData)
            local radius = planetData.radius
            if planetData.atmosphereRadius > radius then radius = planetData.atmosphereRadius end
            if dist < radius*1.2 then
                local newPos
                if dist == 0 then
                    newPos = vec3(1,0,1):cross(linedata[3]-linedata[2])
                    newPos = newPos:normalize()*radius*1.7 + Planets.pos
                else
                    newPos = (lotP-Planets.pos):normalize()*radius*1.7 + Planets.pos
                end
                route = inject(route,{b=k,i=true,c=newPos,n="AvoidPlanet"},key)
            end
        end
        ::skip::
        prePos = des.c
    end
    if not isSafe then coroutine.yield(corouCalc)  route = checkSafeRoute(route) end
    return route
end
function inject(tab,val,ind)
    ind = ind or #tab
    if ind > #tab then return tab end
    local newTab = tab
    newTab[ind+1] = val
    for i = ind+1, #tab, 1 do
        newTab[i+1] = tab[i]
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
        return round(str/1000) .. "km"
    else
        return round(str/200000) .. "su"
    end
end
--[[
    --[[
    route = {}
    route["n"] = "Offpipe " .. angle

    point = {}
    point["c"] = {}
    point["b"] = 31
    point["i"] = true
    point["c"]["x"] = 29015877.3707
    point["c"]["y"] = 10941906.8326
    point["c"]["z"] = 127258.2067
    point["n"] = "Thades Station"
    point["s"] = 10000

    point1 = {}
    point1["c"] = {}
    point1["b"] = 31
    point1["i"] = true
    point1["c"]["x"] = op1.x
    point1["c"]["y"] = op1.y
    point1["c"]["z"] = op1.z
    point1["n"] = "Thades Off Pipe"
    point1["s"] = 10000

    point2 = {}
    point2["c"] = {}
    point2["b"] = 122
    point2["i"] = true
    point2["c"]["x"] = op2.x
    point2["c"]["y"] = op2.y
    point2["c"]["z"] = op2.z
    point2["n"] = "Ion Off Pipe"
    point2["s"] = 29000

    point3 = {}
    point3["c"] = {}
    point3["b"] = 122
    point3["i"] = true
    point3["c"]["x"] = 2853527.3366
    point3["c"]["y"] = -99052528.6568
    point3["c"]["z"] = -760860.0561
    point3["n"] = "ION Station"
    point3["s"] = 10000

    route["p"] = {point, point1 ,point2, point3}
    data = json.encode({route})

    Databank.setStringValue("routes", tostring(data)) 
radius = radius
if atmohöhe ~= 0 then
    radius = atmohöhe
end
ausweichen = radius * 1.7

zusatz ausweich objekte 
Station/Parkplatz mit R = 2000



Logik Spiel:

StartPunkt: mein standort
Endpunkt: zufallsPos



checken ob planetares Objekt im Weg ist
route ohne fehler = war
wenn Abstand < 1.2 * radius
    route ohne fehler = falsch
    neuer punkt zwischen start und end hinzufügen
    mit vektor(planet --> lotfuß):normalize * ausweichen
    sodass dann 3 punkt drin sind
    wichtig punkt dazwischen fügen
    neue route = rout[bis a]
    route[a + 1] = zwischen Punkt
    for I =  a + 2 bis #rout + 1 
        route[I] = rout[I-1]
    
wenn nicht route ohne fehler dann fange oben wieder an

route fertig
kann geflogen werden

    










--[[
function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    if numDecimalPlaces ~= nil then
        return math.floor(num * mult + 0.5) / mult
    else
        return math.floor((num * mult + 0.5) / mult)
    end
end


function getDistanceDisplayString(distance, places) -- Turn a distance into a string to a number of places
      local su = distance > 100000
      if places == nil then places = 1 end
      if su then
            -- Convert to SU
          return round(distance / 1000 / 200, places).." SU"
      elseif distance < 1000 then
          return round(distance, places).." M"
      else
          -- Convert to KM
          return round(distance / 1000, places).." KM"
      end
end

function genPipes(myPlanets,myChoice)
	local myPipes = {}
	if myChoice then    
		for i = 2,#myPlanets,1 do
			table.insert(myPipes,{myPlanets[1][1] .. " - " .. myPlanets[i][1],myPlanets[1][2],vec3(myPlanets[i][2])-vec3(myPlanets[1][2])})
		end
	else
		for j = 1,#myPlanets-1,1 do
			for i = j+1,#myPlanets,1 do
				table.insert(myPipes,{myPlanets[j][1] .. " - " .. myPlanets[i][1],myPlanets[j][2],vec3(myPlanets[i][2])-vec3(myPlanets[j][2])})			
			end
		end
	end
	return myPipes
end


function dist2Plant(myLine, myPlanet)
    local line_vec = myLine[2] - myLine[3]
    local pnt_vec =  myLine[2] - myPlanet[2]
    local line_len = line_vec:len()
    local line_norm = line_vec:normalize()
    local pnt_vec_scale = pnt_vec / line_len
    local t = line_norm:dot(pnt_vec_scale)
    if t < 0.0 then t = 0.0 end
    if t > 1.0 then t = 1.0 end
    local nearest_on_line = line_vec * t
    local dist = (pnt_vec - nearest_on_line):len()
    --local nearest_pos = myLine[2] + nearest_on_line
    return dist, myLine[1], myPlanet[1]
end


function dist2Pipe(myLine, myPipe)
    local v1 = (myPipe[3] - myPipe[2]):normalize()
    local v2 = (myLine[3] - myLine[2]):normalize()
    local n = vec3(v1:cross(v2))
    local v3 = (myLine[2] - myPipe[2])
    local dist = (math.abs(v3:dot(n)))/n:len()
    if dist <= 1000*200000 then
        local solv = library.systemResolution3({v1:unpack()}, {(-1*n):unpack()}, 
            {(-1*v2):unpack()}, {v3:unpack()})
        local f1 = myLine[3] + solv[3] * v2
        t1 = (myLine[3] - f1):normalize()
        if v2 == t1 and (myLine[3] - f1):len() <= (myLine[3] - myLine[2]):len() then 
            return dist, myLine[1], myPipe[1]
        else
            local distStart,_,_ = dist2Plant(myPipe, {"Start", myLine[2]})
            local distEnd,_,_ = dist2Plant(myPipe, {"End", myLine[3]})
            return math.min(distStart, distEnd), myLine[1], myPipe[1]
        end
    else
        return math.huge, myLine[1], myPipe[1]
    end
end

function checkRoute(curpos, opcurpos, optarpos, tarpos)
    local routeLines={}
    table.insert(routeLines,{"cur. pos --> op cur. pos",vec3(curpos),vec3(opcurpos)})
    table.insert(routeLines,{"op cur. pos --> op tar. pos",vec3(opcurpos),vec3(optarpos)})
    table.insert(routeLines,{"op tar. pos --> tar. pos",vec3(optarpos),vec3(tarpos)})
    
    for lId,lineData in pairs(routeLines) do
        minDist = math.huge
        for pId,planetData in pairs(listPlanets) do
            dist, line, planet = dist2Plant(lineData, planetData)
            --system.print(line .. " is " .. getDistanceDisplayString(dist,2) .. " away from " .. planet)
            if dist < 200000 then
                system.print(line .. " is " .. getDistanceDisplayString(dist,2) .. " away from " .. planet)
            end
            if dist < minDist then minDist = dist end
        end
        if minDist >= 4*200000 then
          for pipeId,pipeData in pairs(genPipes(listPlanets,true)) do
            dist, line, pipe = dist2Pipe(lineData, pipeData)
            if dist <= 4*200000 then
                system.print(line .. " is " .. getDistanceDisplayString(dist,2) .. " away from " .. pipe)
            end
          end 
        end
    end
end









local num = ' *[+-]?%d+%.?%d*e?[+-]?%d*'
local posPattern = '(::pos{' .. num .. ',' .. num .. ',' ..  num .. ',' .. 
        num ..  ',' .. num .. '})'

lines = {}
for s in text:gmatch("[^\r\n]+") do
    newLocPos  = string.match(text,posPattern,1)
    if newLocPos == nil then
        system.print("No Pos")
    else
        nums = {}
        for num in string.gmatch(text, num) do
            nums[#nums+1] = num
        end
        local p1 = vec3(construct.getWorldPosition())
        local p2 = vec3(nums[3],nums[4],nums[5])
        local dist = gDistInSU*200000
        local pipe = vec3(p1-p2):normalize()
        local tangent  = pipe:cross(vec3(-pipe.x,pipe.y,pipe.z))
        local bitangent = pipe:cross(tangent)
        angle = math.random(-31415, 31415) / 10000
        system.print("Angle: ".. angle)
        goal = (tangent * math.sin(angle) + bitangent * math.cos(angle)):normalize()* dist
        op1 = vec3(p1.x+goal.x, p1.y+goal.y, p1.z+goal.z)
        op2 = vec3(p2.x+goal.x, p2.y+goal.y, p2.z+goal.z)
        system.print("Offpipe cur. pos: ::pos{0,0,".. op1.x .. "," .. op1.y .. "," .. op1.z.."}")
        system.print("Offpipe target pos: ::pos{0,0,".. op2.x .. "," .. op2.y .. "," .. op2.z .."}")
        checkRoute(p1, op1, op2, p2)
    end
end






listPlanets = {}
for id,data in pairs(Atlas[0]) do 
    if id < 100 then
        local Vector = vec3(data.center)
        table.insert(listPlanets,{data.name[1], vec3(data.center)})
    end
end

function tableHasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
gDistInSU = 8 --export: Distance from the pipe in SU]]
return self
