local self = {}
self.version = 0.9
self.loadPrio = 1000
self.viewTags = {"screen"}
function self:valid(key)
    return unitType == "gunner"
end

weaponHits = {}
weaponMisses = {}
elementDestructions = {}
kills = {}
damage = {}
log = {}
RW = getPlugin("RadarWidget",true,"AQN5B4-@7gSt1W?;")
function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end

    register:addAction("OnHit", "combatData", function (targetId,damage,w)
        if weaponHits[w.getLocalId()] == nil then weaponHits[w.getLocalId()] = 0 end
        weaponHits[w.getLocalId()] = weaponHits[w.getLocalId()] + 1
        if damage[targetId] == nil then damage[targetId] = 0 end
        damage[targetId] = damage[targetId] + damage
        table.insert(log, "Hit: " .. tostring(RW.CodeList[targetId]) .. "; Dmg: " .. damage)
    end)

    register:addAction("OnElementDestroyed", "combatData", function (targetId,itemId,w)
        if elementDestructions[targetId] == nil then elementDestructions[targetId] = {} end
        table.insert(elementDestructions[targetId], itemId)
        table.insert(log, "ElementDestroyed: " .. tostring(RW.CodeList[targetId]) .. "; Element: " .. system.getItem(itemId).displayName)
    end)

    register:addAction("OnDestroyed", "combatData", function (targetId,w)
        table.insert(kills, targetId)
        table.insert(log, "Killed: " .. tostring(RW.CodeList[targetId]))
    end)

    register:addAction("OnMissed", "combatData", function (targetId,w)
        if weaponMisses[w.getLocalId()] == nil then weaponMisses[w.getLocalId()] = 0 end
        weaponMisses[w.getLocalId()] = weaponMisses[w.getLocalId()] + 1
        table.insert(log, "Missed: " .. tostring(RW.CodeList[targetId]))
    end)

    local screener = getPlugin("screener",true)
    if screener ~= nil then
        screener:addScreen("screen1third",{
            offsetx=0.005,
            offsety=0.005,
            width=0.2,
            height=0.3,
            perspective="third",
            parent="mainScreenThird"
        })
        screener:registerDefaultScreen("screen1third","combatData")
        screener:addView("combatData",self)
    end
end
function self:setScreen()
    local id = weapon[1].getTargetId()
    if elementDestructions[id] == nil then elementDestructions[id] = {} end
    if damage[id] == nil then damage[id] = 0 end
    local svg = [[
        <svg viewBox="0 0 100 100">
            <rect x="0%" y="0%" rx="2" ry="2" width="100%" height="100%" style="fill:#4682B4;fill-opacity:0.35" />
            <text x="5%" y="7.5%" style="fill:#FFFFFF;font-size:5">CombatLog</text>
            <text x="50%" y="7.5%" style="fill:#FFFFFF;font-size:4">TargetData</text>
            <text x="50%" y="12%" style="fill:#FFFFFF;font-size:3">Dmg: </text>
            <text x="50%" y="16%" style="fill:#FFFFFF;font-size:3">DesElements: </text>
            <text x="80%" y="12%" style="fill:#FFFFFF;font-size:3">]].. round(damage[id]) ..[[</text>
            <text x="80%" y="16%" style="fill:#FFFFFF;font-size:3">]].. #elementDestructions[id] ..[[</text>

            <text x="50%" y="50%" style="fill:#FFFFFF;font-size:4">WData</text>
            <text x="65%" y="50%" style="fill:#FFFFFF;font-size:3">Hits</text>
            <text x="80%" y="50%" style="fill:#FFFFFF;font-size:3">Shots</text>
        ]]
    local y = 4
    for k,w in pairs(weapon) do 
        local id = w.getLocalId()
        if weaponMisses[id] == nil then weaponMisses[id] = 0 end
        if weaponHits[id] == nil then weaponHits[id] = 0 end

        local shots = weaponHits[id] + weaponMisses[id]
        local pro = 100
        if shots > 0 then 
            pro = weaponHits[id] / shots * 100
        end
        local n = w.getName()
        n = string.sub(n,#n-2,#n-1)
        svg = svg .. [[<text x="50%" y="]] .. 50 + y .. [[%" style="fill:#FFFFFF;font-size:3">]]..n..[[: </text>]]
        svg = svg .. [[<text x="65%" y="]] .. 50 + y .. [[%" style="fill:#FFFFFF;font-size:3">]]..pro..[[%</text>]]
        svg = svg .. [[<text x="80%" y="]] .. 50 + y .. [[%" style="fill:#FFFFFF;font-size:3">]]..shots..[[</text>]]
        y = y + 4
    end
    for i = 0,20,1 do
        if i >= #log then break end
        svg = svg .. [[<text x="2%" y="]] .. 12 + i*4 .. [[%" style="fill:#FFFFFF;font-size:3">]]..log[#log - i]..[[</text>]]
    end
    return svg .. [[</svg>]]
end
return self