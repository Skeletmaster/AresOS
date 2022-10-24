local self = {}
self.loadPrio = 100
self.version = 0.9

function self:valid(key)
    return unitType == "remote" or unitType == "command"
end


function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
    local ms = getPlugin("menuscreener",true)
    if ms == nil then return end
    ms:addMenu("Pilot")
end

local function setScreen()

end


return self