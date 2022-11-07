local self = {}
local auth = ""
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "gunner"
end
self.version = 0.9
self.loadPrio = 1000
local Data = {}
function self:register(env)
	if not self:valid(auth) then return end
    --register:addAction("systemOnUpdate","radartracker",Tracking)
    addTimer("radartracker",1,Tracking)
    register:addAction("unitOnStop","radartracker", function ()
        print("Data:" .. json.encode(Data))
    end)

end
function Tracking()
    local r = radar[1]
    local c = construct
    local ts = tostring
    local ID = r.getTargetId()
    if ID ~= 0 then
        if r.hasMatchingTransponder(ID) == 1 and r.isConstructIdentified(ID) == 1 then
            if Data[ID] == nil then Data[ID] = {} end
            table.insert(Data[ID], [[{"t" : ]] ..  system.getArkTime() .. [[,"e" : {"iwp" : ]] .. ts(vec3(r.getConstructWorldPos(ID))) .. [[,"ip" : ]] .. ts(vec3(r.getConstructPos(ID))) .. [[,"d" : ]] .. r.getConstructDistance(ID) .. [[,"iv" : ]] .. ts(vec3(r.getConstructVelocity(ID))) .. [[,"iwv" : ]] .. ts(vec3(r.getConstructWorldVelocity(ID))) .. [[,"v" : ]] .. r.getConstructSpeed(ID) .. [[,"av" : ]] .. r.getConstructAngularSpeed(ID) .. [[,"rv" : ]] .. r.getConstructRadialSpeed(ID) .. [[},"o" : {"wp" : ]] .. ts(vec3(c.getWorldPosition())) .. [[,"wv" : ]] .. ts(vec3(c.getWorldVelocity())) .. [[,}}]])
        end
    end
end
return self
