local self = {}
function self:valid(key)
    return unitType == "remote" or unitType == "command"
end
self.version = 0.9
self.loadPrio = 1000
local u = unit
local s = system
local FlightModes = {}
local FlightMode = ""
local updateOn = true
local rotatedCons,calcConstruct = construct
rotatedCons.tags = {ver = 'thrust analog vertical',str = 'thrust analog lateral', main = 'thrust analog longitudinal'}
function self:register(env)
	_ENV = env
	
	if not self:valid() then return end
	
	if Nav == nil then
		Nav = Navigator.new(system, core, unit)
	end
    if Nav.control.isRemoteControlled() == 1 then
        player.freeze(1)
    end

    local pitchInput = 0
    local rollInput = 0
    local yawInput = 0
    local brakeInput = 0
    if vec3(construct.getWorldVelocity()):len() < 10 then  brakeInput = 1 end
    register:addAction("systemOnUpdate", "NavUpdate",  function() if updateOn then Nav:update() end end)
    register:addAction("option2Start", "NavUpdate",  function() calcConstruct() end)

    
    register:addAction("forwardStart", "forwardStartFlight",  function() pitchInput =  -1 end)
    register:addAction("backwardStart", "backwardStartFlight",  function() pitchInput =  1 end)
    register:addAction("yawleftStart", "yawleftStartFlight",  function() yawInput =  1 end)
    register:addAction("yawrightStart", "yawrightStartFlight",  function() yawInput =  -1 end)
    register:addAction("strafeleftStart", "strafeleftStartFlight",  function() Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.lateral, -1.0) end)
    register:addAction("straferightStart", "straferightStartFlight",  function() Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.lateral, 1.0) end)
    register:addAction("leftStart", "leftStartFlight",  function() rollInput =  -1 end)
    register:addAction("rightStart", "rightStartFlight",  function() rollInput =  1 end)
    register:addAction("upStart", "upStartFlight",  function() Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.vertical, 1.0) end)
    register:addAction("downStart", "downStartFlight",  function() Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.vertical, -1.0) end)  
    register:addAction("gearStart", "gearStartFlight",  function() if brakeInput == 1 then brakeInput = 0 else brakeInput = 1 end end)
    register:addAction("brakeStart", "brakeStartFlight",  function() brakeInput = 1 end)
    register:addAction("stopenginesStart", "stopenginesStartFlight",  function() Nav.axisCommandManager:resetCommand(axisCommandId.longitudinal) end)
    register:addAction("speedupStart", "speedupStartFlight",  function() Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.longitudinal, 5.0) end)
    register:addAction("speeddownStart", "speeddownStartFlight",  function() Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.longitudinal, -5.0) end)

    register:addAction("speedupLoop", "speedupLoopFlight", function() Nav.axisCommandManager:updateCommandFromActionLoop(axisCommandId.longitudinal, 1.0) end)
    register:addAction("speeddownLoop", "speeddownLoopFlight", function() Nav.axisCommandManager:updateCommandFromActionLoop(axisCommandId.longitudinal, -1.0) end)
    
    register:addAction("forwardStop", "forwardStopFlight", function() pitchInput = 0 end)
    register:addAction("backwardStop", "backwardStopFlight", function() pitchInput = 0 end)
    register:addAction("yawleftStop", "yawleftStopFlight", function() yawInput = 0 end)
    register:addAction("yawrightStop", "yawrightStopFlight", function() yawInput = 0 end)
    register:addAction("strafeleftStop", "strafeleftStopFlight", function() Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.lateral, 1.0) end)
    register:addAction("straferightStop", "straferightStopFlight", function() Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.lateral, -1.0) end)
    register:addAction("leftStop", "leftStopFlight", function() rollInput = 0 end)
    register:addAction("rightStop", "rightStopFlight", function() rollInput = 0 end)
    register:addAction("upStop", "upStopFlight", function() Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.vertical, -1.0) end)
    register:addAction("downStop", "downStopFlight", function() Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.vertical, 1.0) end)
    register:addAction("brakeStop", "brakeStopFlight", function() brakeInput = 0 end)
    local function NormalFlight()
		local s = system
		local ct = self:getConstruct()
        local pitchSpeedFactor = 0.8
        local yawSpeedFactor =  1
        local rollSpeedFactor = 1.5
        local brakeSpeedFactor = 30
        local brakeFlatFactor = 5
        local torqueFactor = 3
        self.brake = brakeInput

        -- final inputs
        local finalPitchInput = pitchInput + s.getControlDeviceForwardInput()
        local finalRollInput = rollInput + s.getControlDeviceYawInput()
        local finalYawInput = yawInput - s.getControlDeviceLeftRightInput()
        local finalBrakeInput = brakeInput

        -- Axis
        local worldVertical = vec3(core.getWorldVertical()) -- along gravity
        local constructUp = vec3(ct.getWorldOrientationUp())
        local constructForward = vec3(ct.getWorldOrientationForward())
        local constructRight = vec3(ct.getWorldOrientationRight())
        local constructVelocity = vec3(ct.getWorldVelocity())
        local constructVelocityDir = vec3(ct.getWorldVelocity()):normalize()
        local currentRollDeg = getRoll(worldVertical, constructForward, constructRight)

        -- Rotation
        local constructAngularVelocity = vec3(ct.getWorldAngularVelocity())
        local targetAngularVelocity = finalPitchInput * pitchSpeedFactor * constructRight
                                        + finalRollInput * rollSpeedFactor * constructForward
                                        + finalYawInput * yawSpeedFactor * constructUp

        -- Engine commands
        local keepCollinearity = 1 -- for easier reading
        local dontKeepCollinearity = 0 -- for easier reading
        local tolerancePercentToSkipOtherPriorities = 1 -- if we are within this tolerance (in%), we don't go to the next priorities

        -- Rotation
        local angularAcceleration = torqueFactor * (targetAngularVelocity - constructAngularVelocity)
        local airAcceleration = vec3(ct.getWorldAirFrictionAngularAcceleration())
        angularAcceleration = angularAcceleration - airAcceleration -- Try to compensate air friction
        Nav:setEngineTorqueCommand('torque', angularAcceleration, keepCollinearity, 'airfoil', '', '', tolerancePercentToSkipOtherPriorities)

        -- Brakes
        local brakeAcceleration = -finalBrakeInput * (brakeSpeedFactor * constructVelocity + brakeFlatFactor * constructVelocityDir)
        Nav:setEngineForceCommand('brake', brakeAcceleration)

        -- AutoNavigation regroups all the axis command by 'TargetSpeed'
        local autoNavigationEngineTags = ''
        local autoNavigationAcceleration = vec3()
        local autoNavigationUseBrake = false

        -- Longitudinal Translation
        local longitudinalEngineTags = ct.tags.main
        local longitudinalCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.longitudinal)
        if (longitudinalCommandType == axisCommandType.byThrottle) then
            local maxKPAlongAxis = ct.getMaxThrustAlongAxis(longitudinalEngineTags, ct.getOrientationForward())
            local forceCorrespondingToThrottle
            local axisThrottle = unit.getAxisCommandValue(axisCommandId.longitudinal)
            if (axisThrottle > 0) then
                forceCorrespondingToThrottle = axisThrottle * math.abs(maxKPAlongAxis[3])
            else
                forceCorrespondingToThrottle = -axisThrottle * math.abs(maxKPAlongAxis[4])
            end
            accelerationCommand = forceCorrespondingToThrottle / self:getMass()
            longitudinalAcceleration = accelerationCommand * constructForward
            Nav:setEngineForceCommand(longitudinalEngineTags, longitudinalAcceleration, keepCollinearity)
        elseif  (longitudinalCommandType == axisCommandType.byTargetSpeed) then
            local longitudinalAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromTargetSpeed(axisCommandId.longitudinal)
            autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. longitudinalEngineTags
            autoNavigationAcceleration = autoNavigationAcceleration + longitudinalAcceleration
            if (Nav.axisCommandManager:getTargetSpeed(axisCommandId.longitudinal) == 0 or -- we want to stop
                Nav.axisCommandManager:getCurrentToTargetDeltaSpeed(axisCommandId.longitudinal) < - Nav.axisCommandManager:getTargetSpeedCurrentStep(axisCommandId.longitudinal) * 0.5) -- if the longitudinal velocity would need some braking
            then
                autoNavigationUseBrake = true
            end
        end

        -- Lateral Translation
        local lateralStrafeEngineTags = ct.tags.str
        local lateralCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.lateral)
        if (lateralCommandType == axisCommandType.byThrottle) then
            local lateralStrafeAcceleration =  Nav.axisCommandManager:composeAxisAccelerationFromThrottle(lateralStrafeEngineTags,axisCommandId.lateral)
            lateralStrafeAcceleration = lateralStrafeAcceleration:len() *  constructRight
            Nav:setEngineForceCommand(lateralStrafeEngineTags, lateralStrafeAcceleration, keepCollinearity)
        elseif  (lateralCommandType == axisCommandType.byTargetSpeed) then
            local lateralAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromTargetSpeed(axisCommandId.lateral)
            autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. lateralStrafeEngineTags
            autoNavigationAcceleration = autoNavigationAcceleration + lateralAcceleration
        end

        -- Vertical Translation
        local verticalStrafeEngineTags = ct.tags.ver
        local verticalCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.vertical)
        if (verticalCommandType == axisCommandType.byThrottle) then
            local verticalStrafeAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromThrottle(verticalStrafeEngineTags,axisCommandId.vertical)
            verticalStrafeAcceleration = verticalStrafeAcceleration:len() * constructUp
            Nav:setEngineForceCommand(verticalStrafeEngineTags, verticalStrafeAcceleration, keepCollinearity, 'airfoil', 'ground', '', tolerancePercentToSkipOtherPriorities)
        elseif  (verticalCommandType == axisCommandType.byTargetSpeed) then
            local verticalAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromTargetSpeed(axisCommandId.vertical)
            autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. verticalStrafeEngineTags
            autoNavigationAcceleration = autoNavigationAcceleration + verticalAcceleration
        end

        -- Auto Navigation (Cruise Control)
        if (autoNavigationAcceleration:len() > constants.epsilon) then
            if (brakeInput ~= 0 or autoNavigationUseBrake or math.abs(constructVelocityDir:dot(constructForward)) < 0.95)  -- if the velocity is not properly aligned with the forward
            then
                autoNavigationEngineTags = autoNavigationEngineTags .. ', brake'
            end
            Nav:setEngineForceCommand(autoNavigationEngineTags, autoNavigationAcceleration, dontKeepCollinearity, '', '', '', tolerancePercentToSkipOtherPriorities)
        end
    end
	self:addFlightMode("Base",NormalFlight)
	self:setFlightMode("Base")
    register:addAction("systemOnFlush","FlightScript",function()
		self:getCurrentFlightMode()()
	end)
end
local count = 0

function self:getConstruct()
    if count%50 == 0 then
        calcConstruct()
    end
    count = count + 1
    return rotatedCons
end
function calcConstruct()
    local newCons = {}
    for key, value in pairs(construct) do
        newCons[key] = value
    end
    local tags = {ver = 'thrust analog vertical',str = 'thrust analog lateral', main = 'thrust analog longitudinal'}
    local transTable = {ver = {"getOrientationUp","getWorldOrientationUp"},str = {"getOrientationRight","getWorldOrientationRight"},main = {"getOrientationForward","getWorldOrientationForward"}}
    local trust = {}
    for key,tag in pairs(tags) do
        trust[key] = construct.getMaxThrustAlongAxis(tag, construct[transTable[key][1]]())
    end
    local maxT,maxTk,f = 0,"main",1

    for index, tab in pairs(trust) do
        if tab[4] > maxT then
            maxT = tab[4]
            maxTk = index
            f = -1
        end
        if tab[3] > maxT then
            maxT = tab[3]
            maxTk = index
            f = 1
        end
    end
    if maxTk == "main" then
        newCons.tags = tags
        function newCons.getOrientationForward()
            local c = construct.getOrientationForward()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getOrientationRight()
            local c = construct.getOrientationRight()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getOrientationUp()
            local c = construct.getOrientationUp()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getWorldOrientationForward()
            local c = construct.getWorldOrientationForward()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getWorldOrientationRight()
            local c = construct.getWorldOrientationRight()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getWorldOrientationUp()
            local c = construct.getWorldOrientationUp()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
    elseif maxTk == "ver" then
        newCons.tags = {main = tags.ver, str = tags.str, ver = tags.main}
        function newCons.getOrientationForward()
            local c = construct.getOrientationUp()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getOrientationRight()
            local c = construct.getOrientationRight()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getOrientationUp()
            local c = construct.getOrientationForward()
            return {c[1] * f* -1,c[2] * f* -1,c[3] * f* -1}
        end
        function newCons.getWorldOrientationForward()
            local c = construct.getWorldOrientationUp()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getWorldOrientationRight()
            local c = construct.getWorldOrientationRight()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getWorldOrientationUp()
            local c = construct.getWorldOrientationForward()
            return {c[1] * f* -1,c[2] * f* -1,c[3] * f* -1}
        end
    elseif maxTk == "str" then
        newCons.tags = {main = tags.str, str = tags.main, ver = tags.ver}
        function newCons.getOrientationForward()
            local c = construct.getOrientationRight()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getOrientationRight()
            local c = construct.getOrientationForward()
            return {c[1] * f* -1,c[2] * f* -1,c[3] * f* -1}
        end
        function newCons.getOrientationUp()
            local c = construct.getOrientationUp()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getWorldOrientationForward()
            local c = construct.getWorldOrientationRight()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
        function newCons.getWorldOrientationRight()
            local c = construct.getWorldOrientationForward()
            return {c[1] * f* -1,c[2] * f* -1,c[3] * f* -1}
        end
        function newCons.getWorldOrientationUp()
            local c = construct.getWorldOrientationUp()
            return {c[1] * f,c[2] * f,c[3] * f}
        end
    end
    rotatedCons = newCons
end

function self:getMass()
    local c = construct
    local m = 0
    for _,v in pairs(c.getPlayersOnBoard()) do
        m = m + c.getBoardedPlayerMass(v)
    end
    if m > 20000 then m = m - 20000 end
    for _,v in pairs(c.getDockedConstructs()) do
        m = m + c.getDockedConstructMass(v)
    end
    return m + c.getMass()
end
function self:getBrakeTime()
    local c = 60000 / 3.6
    local ct = construct
    local spaceBrakeForce = ct.getMaxBrake()
    if spaceBrakeForce == nil then return 0,0 end
	local speed = vec3(ct.getWorldVelocity()):len()
	if speed < 1 then return 0,0 end
    local v = math.min(speed, ct.getMaxSpeed())
    local m = self:getMass()
    local brakeTime = m * c / spaceBrakeForce * math.asin(v / c)
    local brakeDistance = m * c ^ 2 / spaceBrakeForce * (1 - math.sqrt(1 - v ^ 2 / c ^ 2)) -- meter
    return brakeDistance, brakeTime
end
function self:addFlightMode(name,func)
    FlightModes[name] = func
end
function self:setFlightMode(name)
	FlightMode = name
end
function self:getFlightMode(name)
    return FlightModes[name]
end
function self:getCurrentFlightMode()
	return self:getFlightMode(FlightMode), FlightMode
end
function self:setUpdateState(s)
    updateOn = s
end
return self
