local self = {}
self.version = 0.91
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return shield ~= nil
end
function self:register(env)
    _ENV = env
	if shield == nil then return end
    shield.activate()
    register:addAction("OnAbsorbed", "shieldreconfigure", Shieldreconfigure) --TODO
end
local ress_old = {0,0,0,0}
function getRes(stress, pool)
    local res = {0.15,0.15,0.15,0.15}
    if stress[1] >= stress[2] and 
        stress[1] >= stress[3] and 
        stress[1] > stress[4] then
        res = {pool,0,0,0}
    elseif stress[2] >= stress[1] and 
            stress[2] >= stress[3] and 
            stress[2] > stress[4] then
        res = {0,pool,0,0}
    elseif stress[3] >= stress[1] and 
            stress[3] >= stress[2] and 
            stress[3] > stress[4] then
        res = {0,0,pool,0}
    elseif stress[4] >= stress[1] and 
            stress[4] >= stress[2] and 
            stress[4] > stress[3] then
        res = {0,0,0,pool}
    else
        print("Fehler! Im else...")
    end
    return res
end

function Shieldreconfigure()
    if shield.getResistancesCooldown() == 0 then
    --print("Schilde rekonfigurieren!!!")
    local pool = shield.getResistancesPool()
    local stress = shield.getStressRatioRaw()
    local res = getRes(stress, pool)
    if ress_old[1] == res[1] and 
        ress_old[2] == res[2] and 
        ress_old[3] == res[3] and 
        ress_old[4] == res[4] then
        --print("Ress sind gleich!")
    else
        if shield.setResistances(res[1],res[2],res[3],res[4]) == 1 then
            print("Schilde rekonfiguriert!")
            ress_old[1] = res[1]
            ress_old[2] = res[2]
            ress_old[3] = res[3]
            ress_old[4] = res[4]
        else
            print("Fehler: "..shield.getStressRatioRaw()[1]..", "
                                ..shield.getStressRatioRaw()[2]..", "
                                ..shield.getStressRatioRaw()[3]..", "
                                ..shield.getStressRatioRaw()[4])   
        end
    end
    end
end
return self
