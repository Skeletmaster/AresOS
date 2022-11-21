local self = {}
local auth = ""
function self:valid(key)
    if key ~= auth then return false end
    return transponder ~= nil
end
self.version = 0.9
self.loadPrio = 1000
local radar = radar[1]

function self:register(env)
	if not self:valid(auth) then return end
    _ENV = env
    rw = getPlugin("radarwidget",true,"AQN5B4-@7gSt1W?;")
    register:addAction("option2Start","Crawl",function ()
        local list = {}
        for _,ID in pairs(radar.getConstructIds()) do
            if radar.hasMatchingTransponder(ID) == 1 then 
                table.insert(list,radar.getConstructOwnerEntity(ID))
            else
                print("")
            end
        end
        print(json.encode(list))
    end)
end

return self
