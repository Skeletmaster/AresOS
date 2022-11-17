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
local ap,ar,time,Flight,Mode
function self:register(env)
	if not self:valid(auth) then return end
    local ms = getPlugin("menuscreener",true,auth)
    if ms ~= nil then
        ms:addMenu("Pilot",function ()
            
        end)
    end
    ap = getPlugin("autopilot",true,auth)
    if ap == nil then return end
    ar = getPlugin("ar",true,auth)
    Flight = getPlugin("baseflight",false,auth)
    register:addAction("option4Start","ap",function ()
        time = system.getArkTime()
    end)
    register:addAction("option4Stop","ap",function ()
        if system.getArkTime()-time > 1 then
            print("Test")
            if Mode ~= nil then
                Flight:setFlightMode(Mode)
            end
        else
            local t = ar:getLookAdd()
            if t == nil then 
                print("No Target")
            else
                t = vec3(t.center)
            end
            --setTarget
        end
    end)

    local eStopList = {"brake","forward","backward","yawleft","yawright","strafeleft","straferight"}
    local eStop = ap.eStop
    for _, value in pairs(eStopList) do
        register:addAction(value .. "Start","eStop",eStop)
    end
end

function self:setScreen()
    
end

return self






















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