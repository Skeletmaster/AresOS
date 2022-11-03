local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "gunner"
end
self.version = 0.9
local Widgets = nil
local weapon = weapon
s = system
u = unit
local Widgets,RW
function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
	
	Widgets = getPlugin("widgetcreator",true,"AQN5B4-@7gSt1W?;") -- parameter 2 "true" prevents exception
    RW = getPlugin("radarwidget",true,"AQN5B4-@7gSt1W?;")
	if Widgets == nil then return end
	
    register:addAction("unitOnStart", "WeaponStart", function() 
        register:addAction("systemOnUpdate", "weaponwidget", function() self:ReWriteWeapon() end)
    end)
end

--compacts the weapon widget
function self:ReWriteWeapon()
    for k,ID in pairs(Widgets.DataIDs) do
        local data = weapon[k].getWidgetData()
        if data ~= nil then
            local _,n1 = string.find(data,[["ammoName":"]])
            local _,n2 = string.find(data,[["]],n1  +1)
            if (n2 - n1) > 12 then
                local ammo = mysplit(string.sub(data, n1, n2))
                ammo = string.sub(ammo[2],0,4) .. string.sub(ammo[3],0,3)
                data = string.sub(data, 0, n1) .. ammo .. string.sub(data, n2, #data)
            end
            local _,n3 = string.find(data,[["constructId":"]])
            local tar = weapon[k].getTargetId()
            local _,n5 = string.find(data,[["name":"]] , n3)
            if n5 ~= nil then
                local _,n6 = string.find(data,[["]],n5  +1)
                data = string.sub(data, 0, n5) .. tostring(RW.CodeList[tar]) .. string.sub(data, n6, #data)
            end

            local _,n1 = string.find(data,[["name":"]]) --"name": "Exotic Precision Laser l [157]",
            local _,n2 = string.find(data,[["]],n1  +1)
            if (n2 - n1) > 12 then
                local ammo = weapon[k].getLocalId() .. "  HC:  " .. round(weapon[k].getHitProbability()*100,2)
                data = string.sub(data, 0, n1) .. ammo .. string.sub(data, n2, #data)
            end
            s.updateData(ID, data)
        end
    end
end

return self
