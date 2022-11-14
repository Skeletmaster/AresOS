local self = {}
self.loadPrio = 100
self.version = 0.9
local auth = "AQN5B4-@7gSt1W?;"
local co = construct
local targetSpeed = 35000 /3.6
local pi = math.pi()
self.status = "Off"
local Flight,FlightTo
local infos = {}
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "remote" or unitType == "command"
end
local path
local pathList
function self:register(env)
    _ENV = env
	Flight = getPlugin("baseflight",false,auth)
    if Flight == nil then return end
    if not self:valid(auth) then return end
    local ms = getPlugin("menuscreener",true,auth)
    if ms ~= nil then
        ms:addMenu("Pilot",function ()
            
        end)
    end
    Flight:addFlightMode("AutoPilot",pathFollower)
    Flight:addFlightMode("IndirectControl",DirectInput)
    register:addAction("stopenginesStart","autopilot", function ()
        FinishedAccelerating = true
    end)
end

local function setScreen()

end

local function AutoAlign(forward,up)
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
    tolerance = tolerance or 100
    local FlightTime = 0
    local wForward = vec3(co.getWorldOrientationForward())
    local wRight = vec3(co.getWorldOrientationRight())
    local wUp = vec3(co.getWorldOrientationUp())
    local wPos = vec3(co.getWorldPosition())
    local FlightPath = wPos - target 
    local dis = FlightPath:len()
    local wVel = vec3(co.getWorldAbsoluteVelocity())
    local wVelDir = wVel:normalize()
    local wAcc = vec3(co.getWorldAcceleration())
    targetSpeed = targetSpeed or co.getMaxSpeed()
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
                Nav:setEngineThrust("thrust analog longitudinal",accelVec,1)
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

local function Hold(forward,up)
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
local function initializePathList()

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
    FlightTo(TargetVec+vec3(co.getWorldPosition()), nil, TargetSpeed)
end

--Pathfollower
local step = 1
local function pathFollower()
    local instructions = path[step]
    local flighing, time = FlighTo(instructions.p, instructions.bd, instructions.mv, instructions.tolerance, instructions.align) -- ........
    local nextStop = time
    for i = step+1, #path, 1 do
        local v = path[i].targetSpeed or co.getMaxSpeed()
        time = time + ((path[i].p - path[i-1].p)/ v)
    end
    if flighing then
        
    else
        FinishedAccelerating = false
        step = step + 1
    end
end

return self