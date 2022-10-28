local self = {}
self.loadPrio = 100
self.version = 0.9
local auth = "AQN5B4-@7gSt1W?;"
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


return self