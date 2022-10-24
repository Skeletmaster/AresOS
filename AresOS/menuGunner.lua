local self = {}
self.loadPrio = 100
self.version = 0.9

function self:valid(key)
    return unitType == "gunner"
end

function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
    local ms = getPlugin("menuscreener",true)
    if ms == nil then return end
end

local function setScreen()

end


return self