local self = {}
local auth = ""
function self:valid(key)
    if key ~= auth then return false end
    return transponder ~= nil
end
self.version = 0.91
self.loadPrio = 1000

function self:register(env)
	if not self:valid(auth) then return end
    _ENV = env
end
local core = core

return self
