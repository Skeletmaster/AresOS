local self = {}
self.loadPrio = 100
self.version = 0.9
local auth = "AQN5B4-@7gSt1W?;"
local co = construct
local nTargetSpeed = 35000 /3.6
local pi = math.pi
self.status = "Off"
local Flight,FlighTo,Hold,initializePathList,AutoAlign
local infos = {}
local vec3 = vec3
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "remote" or unitType == "command"
end
local flightInfos = {}
local path
local pathList = {}
function self:register(env)
    _ENV = env
	Flight = getPlugin("baseflight",false,auth)
    if Flight == nil then return end
    if not self:valid(auth) then return end

    Flight:addFlightMode("AutoPilot",pathFollower)
    Flight:addFlightMode("IndirectControl",DirectInput)
    register:addAction("stopenginesStart","autopilot", function ()
        FinishedAccelerating = true
    end)
    initializePathList()
    register:addAction("unitOnStop","RouteSave", function ()
        if database.hasKey ~= nil then
            database.setStringValue("routes",json.encode(pathList))
        end
    end)


    local screener = getPlugin("screener",true)
    if screener ~= nil then
        screener:addScreen("screen2third",{
            offsetx=0.01,
            offsety=0.25,
            width=0.2,
            height=0.25,
            perspective="third",
            parent="mainScreenThird"
        })
        screener:registerDefaultScreen("screen2third","APInfos")
        screener:addView("APInfos",self)
    end
end

function AutoAlign(forward,up)
        co = Flight:getConstruct()
        local wForward = vec3(co.getWorldOrientationForward())
        local wRight = vec3(co.getWorldOrientationRight())
        local wUp = vec3(co.getWorldOrientationUp())
        local roll = 0
        local pitch = forward:angleBetween(wUp) - pi/2
        local yaw = forward:angleBetween(wRight) - pi/2
        local forwardAngle = forward:angleBetween(wForward)
        if forwardAngle > pi/2 then
            if pitch > 0 then
                pitch = pi - pitch
            else
                pitch = -pi - pitch
            end
            if yaw > 0 then
                yaw = pi - yaw
            else
                yaw = pi - yaw
            end
        end
        if up ~= nil then
            roll = up:angleBetween(wRight) - pi/2
            local rightAngle =  up:angleBetween(wUp)
            if rightAngle > pi/2 then
                if roll > 0 then 
                    roll = pi - roll
                else
                    roll = -pi - roll
                end
            end
        end
    return pitch,yaw,roll
end


local FinishedAccelerating = false
function FlighTo(target,safebreak,targetSpeed,tolerance,align)
    co = Flight:getConstruct()
    tolerance = tolerance or 100
    local FlightTime = 0
    local wForward = vec3(co.getWorldOrientationForward())
    local wRight = vec3(co.getWorldOrientationRight())
    local wUp = vec3(co.getWorldOrientationUp())
    local wPos = vec3(co.getWorldCenterOfMass())
    local FlightPath = wPos - target 
    local dis = FlightPath:len()
    local wVel = vec3(co.getWorldAbsoluteVelocity())
    local wVelDir = wVel:normalize()
    local wAcc = vec3(co.getWorldAcceleration())
    targetSpeed = targetSpeed or co.getMaxSpeed()
    if targetSpeed > co.getMaxSpeed() then targetSpeed = co.getMaxSpeed() end
    local accelVec = (targetSpeed * (FlightPath):normalize()) - wVel
    local pitch,roll,yaw = AutoAlign(accelVec,align)
    if FinishedAccelerating then
        FlightTime = FlightPath:len() / wVel:len()
    else
        FlightTime = FlightPath:len() / targetSpeed
    end
    if not FinishedAccelerating then
        if accelVec:angleBetween(FlightPath) > pi/2 then
            local brakeAcceleration = -1 * (30 * wVel + 5 * wVelDir)
            Nav:setEngineForceCommand('brake', brakeAcceleration)
            self.status = "LargeTurn"
        else
            if wVel:len() > targetSpeed then
                local brakeAcceleration = -1 * (30 * wVel + 5 * wVelDir)
                Nav:setEngineForceCommand('brake', brakeAcceleration)
                self.status = " ReducingSpeed"
            else
                Nav:setEngineThrust(co.tags.main,accelVec,1)
                self.status = "Accelerating"
            end
        end
    end
    if accelVec:len() < 10 then FinishedAccelerating = true end
    -- Rotation
    local constructAngularVelocity = vec3(ct.getWorldAngularVelocity())
    local targetAngularVelocity = pitch * wRight
                                    + roll * wForward
                                    + yaw * wUp
    -- Rotation
    local angularAcceleration = (targetAngularVelocity - constructAngularVelocity)
    Nav:setEngineTorqueCommand('torque', angularAcceleration, 1, 'airfoil', '', '', 1)

    if safebreak ~= nil then
        dis = dis + safebreak
        local breakdis, braketime = Flight:getBrakeTime()
        if FinishedAccelerating then
            FlightTime = (FlightPath:len()-breakdis) / wVel:len() + braketime
        else
            FlightTime = (FlightPath:len()-breakdis) / targetSpeed + braketime
        end
        if dis <= breakdis + 1.05 then 
            local brakeAcceleration = -1 * (30 * wVel + 5 * wVelDir)
            Nav:setEngineForceCommand('brake', brakeAcceleration)
            self.status = "Braking"
        end
        if dis < tolerance and wVel:len() < 1 then
            FinishedAccelerating = false
            return false,FlightTime
        end
    end
    return true,FlightTime
end

function Hold(forward,up)
    co = Flight:getConstruct()
    self.status = "Holding"
    local brakeAcceleration = -1 * (30 * wVel + 5 * wVelDir)
    Nav:setEngineForceCommand('brake', brakeAcceleration)

    local pitch,roll,yaw = AutoAlign(forward,up)
    local wForward = vec3(co.getWorldOrientationForward())
    local wRight = vec3(co.getWorldOrientationRight())
    local wUp = vec3(co.getWorldOrientationUp())
    local constructAngularVelocity = vec3(ct.getWorldAngularVelocity())
    local targetAngularVelocity = pitch * wRight
                                    + roll * wForward
                                    + yaw * wUp
    -- Rotation
    local angularAcceleration = (targetAngularVelocity - constructAngularVelocity)
    Nav:setEngineTorqueCommand('torque', angularAcceleration, 1, 'airfoil', '', '', 1)
end
function initializePathList()
    if database.hasKey ~= nil and database.hasKey("routes") == 1 then
        pathList = json.decode(database.getStringValue("routes"))
    end
end
function self:addPath(p,l)
    pathList[p] = l
end

function self:setPath(p)
    step = 1
    if type(p) == "string" then
        path = pathList[p]
    else 
        path = p
    end
end
function self:getPath(p)
    if p == nil then
        return path
    else
        return pathList[p]
    end
end

--FlightMode
--DirectInput
local TargetVec = vec3()
local TargetSpeed = 0
function self:setInputs(target,speed)
    TargetVec = target
    TargetSpeed = speed
end
local function direktInput()
    FinishedAccelerating = false
    FlighTo(TargetVec+vec3(co.getWorldPosition()), nil, TargetSpeed)
end

--Pathfollower
local step = 1
local function pathFollower()
    if step > #path.p then 
        if path.p[#path.p].align ~= nil then
            Hold(path.p[#path.p].c-path.p[#path.p-1].c, path.p[#path.p].align)
        else
            Hold()
        end
    end
    local instructions = path.p[step]
    instructions.bd = instructions.bd or 5000
    local flighing, time = FlighTo(instructions.c, instructions.bd, instructions.s, instructions.tolerance, instructions.align) -- ........
    local nextStop = time
    for i = step+1, #path.p, 1 do
        local v = path.p[i].targetSpeed or nTargetSpeed
        time = time + ((path.p[i].c - path.p[i-1].c):len()/ v)
    end
    if flighing then
    else
        FinishedAccelerating = false
        step = step + 1
    end
    flightInfos.nextStop = nextStop
    flightInfos.time = time
end
function self.eStop()
    Flight:setFlightMode("Base")
end

function self:setScreen()
    if self.status == "Off" then return "" end
    local svg = [[
        <svg viewBox="0 0 100 80" style="width:100%;height:100%">
            <rect x="0%" y="0%" rx="2" ry="2" width="50%" height="80%" style="fill:#4682B4;fill-opacity:0.1" />
            <text x="5%" y="7.5%" style="fill:#FFFFFF;font-size:3">Status:</text><text x="25%" y="7.5%" style="fill:#FFFFFF;font-size:3">]]..self.status..[[</text> 
            <text x="5%" y="9.5%" style="fill:#FFFFFF;font-size:3">FinishedAccel:</text><text x="25%" y="9.5%" style="fill:#FFFFFF;font-size:3">]]..FinishedAccelerating..[[</text>
        ]]
    local FlightModefunc,FlightMode = Flight:getCurrentFlightMode()
    if FlightMode == "AutoPilot" then
       svg = svg .. [[<text x="5%" y="11.5%" style="fill:#FFFFFF;font-size:3">nextStop:</text><text x="25%" y="11.5%" style="fill:#FFFFFF;font-size:3">]]..flightInfos.nextStop..[[s</text>]]
       svg = svg .. [[<text x="5%" y="11.5%" style="fill:#FFFFFF;font-size:3">RemTime:</text><text x="25%" y="11.5%" style="fill:#FFFFFF;font-size:3">]]..flightInfos.time..[[s</text>]]
    elseif FlightMode == "IndirectControl" then
        svg = svg .. [[<text x="5%" y="11.5%" style="fill:#FFFFFF;font-size:3">TargetVec:</text><text x="25%" y="11.5%" style="fill:#FFFFFF;font-size:3">]]..tostring(TargetVec)..[[s</text>]]
        svg = svg .. [[<text x="5%" y="11.5%" style="fill:#FFFFFF;font-size:3">TargetSpeed:</text><text x="25%" y="11.5%" style="fill:#FFFFFF;font-size:3">]]..TargetSpeed..[[s</text>]]
    end
    return svg
end
return self

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
]]