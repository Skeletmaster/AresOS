local self = {}
local auth = ""
function self:valid(key)
    if key ~= auth then return false end
    return transponder ~= nil
end
self.version = 0.91
self.loadPrio = 1000
local radar = radar[1]

function self:register(env)
	if not self:valid(auth) then return end
    _ENV = env
    register:addAction("option2Start","Crawl",function ()
        local list = {}
        for _,ID in pairs(radar.getConstructIds()) do
            if radar.hasMatchingTransponder(ID) then
                local t = radar.getConstructOwnerEntity(ID)
                local id = t.id
                local o = t.isOrganization
                if o then
                    owner = system.getOrganization(id).name
                else
                    owner = system.getPlayerName(id)
                end
                list[id] = {n = owner,isOrg = o}
            end
        end
        print(json.encode(list))
    end)
end

return self

