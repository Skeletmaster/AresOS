local self = {}
self.loadPrio = 100
self.version = 0.9
local auth = "AQN5B4-@7gSt1W?;"
local Offset = 0
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "gunner"
end

function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
    local mscreener = getPlugin("menuscreener",true,auth)
    if mscreener == nil then return end
    if core ~= nil then 
        local tanks = getTanks()
        self.SpaceTanks,self.RocketTanks = tanks.space,tanks.rocket
    end
    mscreener:addMenu("Main", function (mx,my,ms,mouseInWindow)
        HTML = [[
        <rect x="66%" y="9%" rx="2" ry="2" width="32%" height="20%" style="fill:#4682B4;fill-opacity:0.35" />
        <text x="70%" y="13%" style="fill:#FFFFFF;font-size:8">Destinations</text>]]
        HTML = HTML .. mscreener:addFancyButton(68,15,28,5,function ()
            system.setWaypoint("::pos{0,0,-91264.7828,408204.8952,40057.4424}")
        end,"Base",mx,my)
        HTML = HTML .. mscreener:addFancyButton(3,93,15,4,function ()
            unit.exit()
        end,"AllExit",mx,my)
        HTML = HTML .. mscreener:addFancyButton(19,93,15,4,function ()
            unit.exit()
        end,"GunnerExit",mx,my)
        return HTML
    end)

    mscreener:addMenu("Ship", function (mx,my,ms,mouseInWindow)
        HTML = [[
            <rect x="2%" y="9%" rx="2" ry="2" width="56%" height="89%" style="fill:#4682B4;fill-opacity:0.35" />
            <rect x="60%" y="9%" rx="2" ry="2" width="38%" height="49%" style="fill:#4682B4;fill-opacity:0.35" />
            <rect x="60%" y="60%" rx="2" ry="2" width="38%" height="38%" style="fill:#4682B4;fill-opacity:0.35" />

            <text x="6%" y="13%" style="fill:#FFFFFF;font-size:8">Elements</text>
            <text x="64%" y="13%" style="fill:#FFFFFF;font-size:8">Tanks</text>
            <text x="64%" y="64%" style="fill:#FFFFFF;font-size:8">Shield</text>]]
        if mouseInWindow and (9 <= my and my <= 98 and  2 <= mx and mx <=  68) then
            if baseFly ~= nil then baseFly:setUpdateState(false) end
            Offset = Offset + system.getMouseWheel() * -1
        else
            if baseFly ~= nil then baseFly:setUpdateState(true) end
        end
        if core ~= nil then
            local off = 0                
            HTML = HTML .. [[<text x="64%" y="16%" style="fill:#FFFFFF;font-size:8">Space:</text>]]
            for k,v in pairs(self.SpaceTanks) do
                local fl = CalculateFuelLevel(v)*100
                HTML = HTML .. [[
                    <text x="64%" y="]].. 19+off ..[[%" style="fill:#FFFFFF;font-size:8">]] .. v[1] .. [[</text>
                    <text x="75%" y="]].. 19+off ..[[%" style="fill:#FFFFFF;font-size:8">]].. round(fl,2) ..[[</text>
                ]]
                off = off + 3
            end
            off = off + 3
            HTML = HTML .. [[<text x="64%" y="]].. 19+off ..[[%" style="fill:#FFFFFF;font-size:8">Rocket:</text>]]
            for k,v in pairs(self.RocketTanks) do
                local fl = CalculateFuelLevel(v)*100
                HTML = HTML .. [[
                    <text x="64%" y="]].. 19+off ..[[%" style="fill:#FFFFFF;font-size:8">]] .. v[1] .. [[</text>
                    <text x="75%" y="]].. 19+off ..[[%" style="fill:#FFFFFF;font-size:8">]].. round(fl,2) ..[[</text>
                ]]
                off = off + 3
            end
            local elementHp = 0
            local elementHpMax = 0
            local elementDmg = {}
            for _, id in pairs(core.getElementIdList()) do
                local hp = core.getElementHitPointsById(id)
                local hpmax = core.getElementMaxHitPointsById(id)
                elementHp = elementHp + hp
                elementHpMax = elementHpMax + hpmax
                if hp ~= hpmax then table.insert(elementDmg,id) end
            end
            HTML = HTML .. [[
                    <text x="6%" y="]].. 19 ..[[%" style="fill:#FFFFFF;font-size:8">ElementHP:</text>
                    <text x="30%" y="]].. 19 ..[[%" style="fill:#FFFFFF;font-size:8">]].. round(elementHp) .. "/" .. round(elementHpMax) ..[[</text>]]
            HTML = HTML .. [[
                <text x="6%" y="]].. 22 ..[[%" style="fill:#FFFFFF;font-size:8">CoreStress:</text>
                <text x="30%" y="]].. 22 ..[[%" style="fill:#FFFFFF;font-size:8">]].. round(core.getCoreStress()) .. "/" .. round(core.getMaxCoreStress()) ..[[</text>]]
            off = 28
            for i = 1, 20, 1 do
                local id = elementDmg[i+Offset]
                if id == nil then break end
                HTML = HTML .. [[
                    <text x="6%" y="]].. off ..[[%" style="fill:#FFFFFF;font-size:8">]] .. core.getElementDisplayNameById(id) .. [[</text>
                    <text x="30%" y="]].. off ..[[%" style="fill:#FFFFFF;font-size:8">]]..  round(core.getElementHitPointsById(id)/core.getElementMaxHitPointsById(id)*100,2) ..[[</text>
                ]]
                off = off + 3
            end     
        end
        if shield ~= nil then
            HTML = HTML .. [[
                <text x="64%" y="67%" style="fill:#FFFFFF;font-size:5">State</text>
                <text x="64%" y="70%" style="fill:#FFFFFF;font-size:5">HP</text>
                <text x="64%" y="73%" style="fill:#FFFFFF;font-size:5">venting</text>
                <text x="64%" y="76%" style="fill:#FFFFFF;font-size:5">VentingCd</text>
                <text x="64%" y="79%" style="fill:#FFFFFF;font-size:5">Resistances</text>
                <text x="64%" y="82%" style="fill:#FFFFFF;font-size:5">ResCd</text>
                <text x="64%" y="85%" style="fill:#FFFFFF;font-size:5">ResPool</text>
                <text x="64%" y="88%" style="fill:#FFFFFF;font-size:5">StressRatio</text>
                <text x="64%" y="91%" style="fill:#FFFFFF;font-size:5">StressHp</text>
                <text x="64%" y="94%" style="fill:#FFFFFF;font-size:5"></text>
                <text x="64%" y="97%" style="fill:#FFFFFF;font-size:5"></text>

                <text x="75%" y="67%" style="fill:#FFFFFF;font-size:5">]] .. shield.isActive() .. [[</text>
                <text x="75%" y="70%" style="fill:#FFFFFF;font-size:5">]] .. round(shield.getShieldHitpoints()) .. "  /  " .. shield.getMaxShieldHitpoints()  .. [[</text>
                <text x="75%" y="73%" style="fill:#FFFFFF;font-size:5">]] .. shield.isVenting() .. [[</text>
                <text x="75%" y="76%" style="fill:#FFFFFF;font-size:5">]] .. round(shield.getVentingCooldown()).. "  /  " .. shield.getVentingMaxCooldown() .. [[</text>
                <text x="75%" y="79%" style="fill:#FFFFFF;font-size:5">]] .. shield.getResistances()[1].." ".. shield.getResistances()[2] .." ".. shield.getResistances()[3].." ".. shield.getResistances()[4] .. [[</text>
                <text x="75%" y="82%" style="fill:#FFFFFF;font-size:5">]] .. shield.getResistancesCooldown() .. "  /  " .. shield.getResistancesMaxCooldown() .. [[</text>
                <text x="75%" y="85%" style="fill:#FFFFFF;font-size:5">]] .. shield.getResistancesRemaining() .. "  /  " .. shield.getResistancesPool() .. [[</text>
                <text x="75%" y="88%" style="fill:#FFFFFF;font-size:5">]] .. shield.getStressRatioRaw()[1].." ".. shield.getStressRatioRaw()[2] .." ".. shield.getStressRatioRaw()[3].." ".. shield.getStressRatioRaw()[4] .. [[</text>
                <text x="75%" y="91%" style="fill:#FFFFFF;font-size:5">]] .. shield.getStressHitpointsRaw() .. [[</text>]]

            local c = "FF0000"
            if shield.isActive() == 1 then c = "00FF00" end
            HTML = HTML .. mscreener:addFancyButton(62,93,25,4,function ()
                shield.activate()
            end,"activate Shield",mx,my,c)
        end
        return HTML
    end)
end
function CalculateFuelLevel(id)
    return (core.getElementMassById(id[1]) - id["me"]) / id["mv"]
end
function getTanks()
	local atmos, space, rocket  = {}, {}, {}
    local ids = core.getElementIdList()
	fuelTankHandlingAtmos = fuelTankHandlingAtmos or 0
	fuelTankHandlingSpace = fuelTankHandlingSpace or 0
	fuelTankHandlingRocket = fuelTankHandlingRocket or 0
	
	ContainerOptimization = ContainerOptimization or 0
	FuelTankOptimization = FuelTankOptimization or 0	
    local function CalcMaxVol(mv)
        local f1, f2 = 0, 0

        if ContainerOptimization > 0 then 
            f1 = ContainerOptimization * 0.05
        end
        if FuelTankOptimization > 0 then 
            f2 = FuelTankOptimization * 0.05
        end
        return mv * (1 - (f1 + f2))        
    end
	local tanks = {atmo = {},space ={} ,rocket = {}}
	local slots = getPlugin("slots")
	for _,id in pairs(ids) do
		local type = core.getElementClassById(id)
		local typeTranslate = slots:getClassType(type)
		if typeTranslate ~= nil then
			if typeTranslate == "atmofueltank" or typeTranslate == "spacefueltank" or typeTranslate == "rocketfueltank" then
				local hp = core.getElementMaxHitPointsById(id)
				local handling = 0
				if typeTranslate == "atmofueltank" then
					handling = fuelTankHandlingAtmos
				elseif typeTranslate == "spacefueltank" then
					handling = fuelTankHandlingSpace
				elseif typeTranslate == "rocketfueltank" then
					handling = fuelTankHandlingRocket
				end
				local MaxVolume, massEmpty = tankStatsDefault(typeTranslate,hp,handling)
				local hasLink = false
				hasLink,MaxVolume,massEmpty = tankStats(id,typeTranslate,MaxVolume,massEmpty)
				if not hasLink then
					MaxVolume = MaxVolume + (MaxVolume * (handling * 0.2))
					MaxVolume = CalcMaxVol(MaxVolume)
				end
				
				local list = {[1] = id,["mv"] = MaxVolume,["me"] = massEmpty}
				if typeTranslate == "atmofueltank" then
					table.insert(tanks.atmo, list)
				elseif typeTranslate == "spacefueltank" then
					table.insert(tanks.space, list)
				elseif typeTranslate == "rocketfueltank" then
					table.insert(tanks.rocket, list)
				end
			end
		end
	end
	for _,typelist in pairs(tanks) do
		table.sort(typelist, function(a,b) return a[1] < b[1] end)
	end
	
    return tanks
end
local tankDefinitions = {
	atmofueltank={
		{w=10000,mv=51200,me=5480}, -- volume in kg of L
		{w=1300,mv=6400,me=988.67}, -- volume in kg of M
		{w=150,mv=1600,me=182.67},  -- volume in kg of S
		{w=0,mv=400,me=35.03}		-- volume in kg of XS
	},
	spacefueltank={
		{w=10000,mv=76800,me=5480}, -- volume in kg of L
		{w=1300,mv=9600,me=988.67}, -- volume in kg of M
		{w=150,mv=2400,me=182.67},  -- volume in kg of S
		{w=0,mv=2400,me=182.67}		-- volume in kg of XS
	},
	rocketfueltank={
		{w=65000,mv=50000 * 0.8,me=25740},	-- volume in kg of L
		{w=1300,mv=6400 * 0.8,me=4720}, 	-- volume in kg of M
		{w=150,mv=800 * 0.8,me=886.72},		-- volume in kg of S
		{w=0,mv=400 * 0.8,me=173.42}		-- volume in kg of XS
	}
}
function tankStatsDefault(typeName, hp)
	for _,stats in pairs(tankDefinitions[typeName]) do
		if hp > stats.w then
			return stats.mv,stats.me
		end
	end
	return 0,0
end
function tankStats(id,listName,MaxVolume,massEmpty)
	local hasLink = false
	
	for _,tank in pairs(_ENV[listName]) do
		if tank.getLocalId() == id then
			hasLink = true
			MaxVolume = tank.getMaxVolume() * 4
			massEmpty = tank.getSelfMass()
			break
		end
	end
	return hasLink,MaxVolume,massEmpty
end
return self
