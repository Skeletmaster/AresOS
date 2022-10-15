local self = {}
local auth = ""
function self:valid(key)
    if key == auth then return true end
    return unitType == "gunner"
end
self.version = 0.9
local Widgets = nil
s = system
u = unit
function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
	
	Widgets = getPlugin("WidgetCreator",true) -- parameter 2 "true" prevents exception
    RW = getPlugin("RadarWidget")
	if Widgets == nil then return end
	
    register:addAction("unitOnStart", "WeaponStart", function() 
        register:addAction("systemOnUpdate", "WeaponWidget", function() self:ReWriteWeapon() end)
    end)
end

--compacts the weapon widget
function self:ReWriteWeapon()
    for k,ID in pairs(Widgets.DataIDs) do
        local data2 = weapon[k].getWidgetData()
        data = data2
        if data ~= nil then 
            local _,n1 = string.find(data,[["ammoName":"]])
            local _,n2 = string.find(data,[["]],n1  +1)
            if (n2 - n1) > 12 then 
                local ammo = mysplit(string.sub(data, n1, n2))
                ammo = string.sub(ammo[2],0,4) .. string.sub(ammo[3],0,3)
                data = string.sub(data, 0, n1) .. ammo .. string.sub(data, n2, #data)
            end
            local _,n1 = string.find(data,[["constructId":"]])
            local _,n2 = string.find(data,[["]],n1  +1)
            local tar = tonumber(string.sub(data, n1 +1, n2 -1))
            if tar ~= 0 then 
                local _,n1 = string.find(data,[["name":"]], n1)
                local _,n2 = string.find(data,[["]],n1  +1)
                data = string.sub(data, 0, n1) .. tostring(RW.CodeList[tar]) .. string.sub(data, n2, #data)
            end

            s.updateData(ID, data2)
        end
    end
end

return self