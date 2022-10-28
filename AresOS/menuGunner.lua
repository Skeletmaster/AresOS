local self = {}
self.loadPrio = 100
self.version = 0.9
local auth = "AQN5B4-@7gSt1W?;"
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
        self.SpaceTanks,self.RocketTanks = getTankId()
    end
    mscreener:addMenu("Main", function (mx,my,ms,mouseInWindow)
        HTML = [[
        <rect x="66%" y="9%" rx="2" ry="2" width="32%" height="20%" style="fill:#4682B4;fill-opacity:0.35" />
        <text x="70%" y="13%" style="fill:#FFFFFF;font-size:8">Destinations</text>]]
        HTML = HTML .. mscreener:addFancyButton(68,15,28,5,function ()
            system.setWaypoint("::pos{0,0,-91264.7828,408204.8952,40057.4424}")
        end,"Base",mx,my)
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
                <text x="75%" y="70%" style="fill:#FFFFFF;font-size:5">]] .. shield.getShieldHitpoints() .. "  /  " .. shield.getMaxShieldHitpoints()  .. [[</text>
                <text x="75%" y="73%" style="fill:#FFFFFF;font-size:5">]] .. shield.isVenting() .. [[</text>
                <text x="75%" y="76%" style="fill:#FFFFFF;font-size:5">]] .. shield.getVentingCooldown().. "  /  " .. shield.getVentingMaxCooldown() .. [[</text>
                <text x="75%" y="79%" style="fill:#FFFFFF;font-size:5">]] .. shield.getResistances()[1].." ".. shield.getResistances()[2] .." ".. shield.getResistances()[3].." ".. shield.getResistances()[4] .. [[</text>
                <text x="75%" y="82%" style="fill:#FFFFFF;font-size:5">]] .. shield.getResistancesCooldown() .. "  /  " .. shield.getResistancesMaxCooldown() .. [[</text>
                <text x="75%" y="85%" style="fill:#FFFFFF;font-size:5">]] .. shield.getResistancesRemaining() .. "  /  " .. shield.getResistancesPool() .. [[</text>
                <text x="75%" y="88%" style="fill:#FFFFFF;font-size:5">]] .. shield.getStressRatioRaw()[1].." ".. shield.getStressRatioRaw()[2] .." ".. shield.getStressRatioRaw()[3].." ".. shield.getStressRatioRaw()[4] .. [[</text>
                <text x="75%" y="91%" style="fill:#FFFFFF;font-size:5">]] .. shield.getStressHitpointsRaw() .. [[</text>]]
        end
        return HTML
    end)
end
function getTankId()
    local space = {}
    local rocket = {}
    local ids = core.getElementIdList()

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

    for _,id in pairs(ids) do
        local type = core.getElementDisplayNameById(id)
        if type == "Space Fuel Tank" then
            local hp = core.getElementMaxHitPointsById(id)
            local MaxVolume = 2400
            local massEmpty = 182.67
            if hp > 10000 then
                MaxVolume = 76800 -- volume in kg of L tank
                massEmpty = 5480
            elseif hp > 1300 then
                MaxVolume = 9600 -- volume in kg of M
                massEmpty = 988.67
            end
            MaxVolume = MaxVolume + (MaxVolume * (fuelTankHandlingSpace * 0.2))
            table.insert(space, {[1] = id,["mv"] = CalcMaxVol(MaxVolume),["me"] = massEmpty})

        elseif type == "Rocket Fuel Tank" then
            local hp = core.getElementMaxHitPointsById(id)
            local MaxVolume = 400 * 0.8
            local massEmpty = 173.42
            if hp > 65000 then
                MaxVolume = 50000 * 0.8  -- volume in kg of L tank
                massEmpty = 25740
            elseif hp > 6000 then
                MaxVolume = 6400 * 0.8 -- volume in kg of M
                massEmpty = 4720
            elseif hp > 700 then
                MaxVolume = 800 * 0.8 -- volume in kg of S
                massEmpty = 886.72
            end
            MaxVolume = MaxVolume + (MaxVolume * (fuelTankHandlingRocket * 0.2))
            table.insert(rocket, {[1] = id,["mv"] = CalcMaxVol(MaxVolume),["me"] = massEmpty})
        end
    end
    table.sort(space, function(a,b) return a[1] < b[1] end)
    table.sort(rocket, function(a,b) return a[1] < b[1] end)
    return space,rocket                    
end
function CalculateFuelLevel(id)
    return (core.getElementMassById(id[1]) - id["me"]) / id["mv"]
end
return self