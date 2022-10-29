local self = {}
self.loadPrio = 100
self.version = 0.9
local auth = "AQN5B4-@7gSt1W?;"
local co = construct
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "remote" or unitType == "command"
end


function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
    local ms = getPlugin("menuscreener",true,auth)
    if ms ~= nil then
        ms:addMenu("Pilot",function ()
            
        end)
    end
end

local function setScreen()

end

local function AutoAlign(forward,up)
        local wForward = vec3(co.getWorldOrientationForward())
        local wRight = vec3(co.getWorldOrientationRight())
        local wUp = vec3(co.getWorldOrientationUp())
        local roll = 0
        local pi = math.pi()
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

return self