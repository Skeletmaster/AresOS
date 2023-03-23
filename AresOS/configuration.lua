local self = {}
local auth = ""
function self:valid(key)
    return true
end
self.version = 0.91
self.loadPrio = 1000

function self:register(env)
    _ENV = env
end

self.owner = 2041
self.creator = 17654
self.basePos = "::pos{0,0,-91264.7828,408204.8952,40057.4424}"
self.friOrgs = {11169,7922,8228,2917,17654,6714,13995,9355,18058,4699,9574,17981,12746,5870,12601,8180,3516,9151,8697,3644,14719,6707,18488}
self.friPlayer = {94563,57230,61799,27464,105615,55748,47124,47130,95815,105050,71758,114939,51450,72744}
return self
