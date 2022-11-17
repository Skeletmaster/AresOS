local self = {}
local auth = ""
function self:valid(key)
    if key ~= auth then return false end
    return transponder ~= nil
end
self.version = 0.9
self.loadPrio = 1000

function self:register(env)
	if not self:valid(auth) then return end
end
local core = core

return self
