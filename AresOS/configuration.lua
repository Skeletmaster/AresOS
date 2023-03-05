local self = {}
local auth = ""
function self:valid(key)
    if key ~= auth then return false end
end
self.version = 0.91
self.loadPrio = 1000

function self:register(env)
	if not self:valid(auth) then return end
    _ENV = env
end

self.owner = 2041
self.creator = 17654
self.basePos = "::pos{0,0,-91264.7828,408204.8952,40057.4424}"
self.friOrgs = {}
self.friPlayer = {}
return self
