local self = {}
self.version = 0.9
self.loadPrio = 1000
self.viewTags = {"screen"}
function self:valid(key)
    return unitType == "gunner"
end
local radar = radar[1]
local baseFly = getPlugin("BaseFlight",true)
local RW = getPlugin("RadarWidget",true,"AQN5B4-@7gSt1W?;")
local GH = getPlugin("GunnerHUD",true,"AQN5B4-@7gSt1W?;")
local weaponHits = {}
local weaponMisses = {}
local elementDestructions = {}
local kills = {}
local damage = {}
local log = {}
local lastHit = {}
local cData = {}
local RW = getPlugin("RadarWidget",true,"AQN5B4-@7gSt1W?;")
local SelTarget = 0
local rMode = true
local hDead = false
local noData = false
local Offset = 0
function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end

    register:addAction("OnHit", "combatData", function (targetId,d,w)
        if weaponHits[w.getLocalId()] == nil then weaponHits[w.getLocalId()] = 0 end
        weaponHits[w.getLocalId()] = weaponHits[w.getLocalId()] + 1
        if damage[targetId] == nil then damage[targetId] = 0 end
        damage[targetId] = damage[targetId] + d
        table.insert(log, "Hit: "  .. round(d)) -- ..  tostring(RW.CodeList[targetId]) .. "; Dmg: "
        lastHit[targetId] = system.getUtcTime()
    end)

    register:addAction("OnElementDestroyed", "combatData", function (targetId,itemId,w)
        if elementDestructions[targetId] == nil then elementDestructions[targetId] = {} end
        table.insert(elementDestructions[targetId], itemId)
        table.insert(log, "Element: " .. system.getItem(itemId).displayNameWithSize) --"EDestroyed: " .. tostring(RW.CodeList[targetId]) .. "; --    ---@return table value An item table with fields: {[int] id, [string] name, [string] displayName, [string] locDisplayName, [string] displayNameWithSize, [string] locDisplayNameWithSize, [string] description, [string] locDescription, [string] type, [number] unitMass, [number] unitVolume, [integer] tier, [string] scale, [string] iconPath, [table] schematics, [table] products}
    end)

    register:addAction("OnDestroyed", "combatData", function (targetId,w)
        table.insert(kills, targetId)
        table.insert(log, "Killed: " .. tostring(RW.CodeList[targetId]))
    end)

    register:addAction("OnMissed", "combatData", function (targetId,w)
        if weaponMisses[w.getLocalId()] == nil then weaponMisses[w.getLocalId()] = 0 end
        weaponMisses[w.getLocalId()] = weaponMisses[w.getLocalId()] + 1
        table.insert(log, "Missed: " .. tostring(RW.CodeList[targetId]))
        lastHit[targetId] = system.getUtcTime()
    end)
    register:addAction("OnIdentified", "combatData", function (targetId)
        delay(function ()
            cData[targetId] = {["d"] = radar.getConstructInfos(targetId),["m"] = radar.getConstructMass(targetId)}
        end,0.5)
    end)
    local screener = getPlugin("screener",true)
    if screener ~= nil then
        screener:addScreen("screen1third",{
            offsetx=0.01,
            offsety=0.03,
            width=0.2,
            height=0.25,
            perspective="third",
            parent="mainScreenThird"
        })
        screener:registerDefaultScreen("screen1third","combatData")

        screener:addView("combatData",self)
    end

    local mscreener = getPlugin("menuscreener",true)
    if mscreener ~= nil then
        mscreener:addMenu("Commander", function (mx,my,ms,mouseInWindow)
            local function addShip(y,id,ID,name,Size,Type,MaxV,Dmg,lHit,o)
                mscreener:addButton(2.5,y-1.75,65,2.5,function ()
                    SelTarget = id
                    RW.tosearch = string.upper(ID)
                    RW.SpecialRadarMode = "Search"
                end)
                local lookup = {"Uni","Pla","Ast","Sta","Dyn","Spa","Ali"}
                local c = "4682B4"
                local opacity = 0
                if o then opacity = 0.35 end
                if (y-1.75 <= my and my <= y-1.75 + 2.5 and  2.5 <= mx and mx <=  2.5 + 65) then
                    c = "244c9c"
                    opacity = 0.35
                end
                MaxV = MaxV or "plsIdent"
                local HTML =  [[<text x="3%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..ID..[[</text>
                <text x="7.8%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..name..[[</text>
                <text x="28%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..Size..[[</text>
                <text x="33%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..lookup[Type]..[[</text>
                <text x="39%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..MaxV..[[</text>
                <text x="47%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..Dmg..[[</text>
                <text x="57%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">T - ]]..lHit..[[ s</text>
                <rect x="2.5%" y="]]..y-1.75 ..[[%" rx="2" ry="2" width="65%" height="2.5%" style="fill:#]]..c..[[;fill-opacity:]]..opacity..[[" />]]
                return HTML
            end
            if mouseInWindow and (9 <= my and my <= 98 and  2 <= mx and mx <=  68) then
                if baseFly ~= nil then baseFly:setUpdateState(false) end
                Offset = Offset + system.getMouseWheel() * -1
            else
                if baseFly ~= nil then baseFly:setUpdateState(true) end
            end
            if Offset < 0 then Offset = 0 end
            local dps = 0
            for _,d in pairs(damage) do

            end
            HTML = [[
            <rect x="2%" y="9%" rx="2" ry="2" width="66%" height="89%" style="fill:#4682B4;fill-opacity:0.35" />
            <rect x="70%" y="9%" rx="2" ry="2" width="28%" height="40%" style="fill:#4682B4;fill-opacity:0.35" />
            <rect x="70%" y="51%" rx="2" ry="2" width="28%" height="47%" style="fill:#4682B4;fill-opacity:0.35" />

            <text x="4%" y="17%" style="fill:#FFFFFF;font-size:5">ID</text>
            <text x="8%" y="17%" style="fill:#FFFFFF;font-size:5">Name</text>
            <text x="28%" y="17%" style="fill:#FFFFFF;font-size:5">Size</text>
            <text x="33%" y="17%" style="fill:#FFFFFF;font-size:5">Type</text>
            <text x="39%" y="17%" style="fill:#FFFFFF;font-size:5">MaxV</text>
            <text x="47%" y="17%" style="fill:#FFFFFF;font-size:5">TotalDmg</text>
            <text x="57%" y="17%" style="fill:#FFFFFF;font-size:5">lastHit</text>

            <line x1="10" y1="52" x2="200" y2="52" style="stroke:#FFFFFF;stroke-width:0.5" />
            
            <line x1="23" y1="48" x2="23" y2="290" style="stroke:#FFFFFF;stroke-width:0.5" />
            <line x1="82" y1="48" x2="82" y2="290" style="stroke:#FFFFFF;stroke-width:0.5" />
            <line x1="97" y1="48" x2="97" y2="290" style="stroke:#FFFFFF;stroke-width:0.5" />
            <line x1="115" y1="48" x2="115" y2="290" style="stroke:#FFFFFF;stroke-width:0.5" />
            <line x1="139" y1="48" x2="139" y2="290" style="stroke:#FFFFFF;stroke-width:0.5" />
            <line x1="169" y1="48" x2="169" y2="290" style="stroke:#FFFFFF;stroke-width:0.5" />
            
            <text x="72%" y="12%" style="fill:#FFFFFF;font-size:7">DamageDealt:</text>
            <text x="72%" y="15%" style="fill:#FFFFFF;font-size:5">You:</text>  <text x="85%" y="15%" style="fill:#FFFFFF;font-size:5">]]..round(dps)..[[</text>

            <text x="72%" y="54%" style="fill:#FFFFFF;font-size:7">TargetInfos:</text>
            ]]
            if radar.isConstructIdentified(SelTarget) == 1 then
                cData[SelTarget] = {["d"] = radar.getConstructInfos(SelTarget),["m"] = radar.getConstructMass(SelTarget)}
            end
            if SelTarget == 0 or cData[SelTarget] == nil then
                HTML = HTML .. [[<text x="72%" y="57%" style="fill:#FFFFFF;font-size:5">NoTargetSelected</text>]]
            else
                local data = cData[SelTarget]
                HTML = HTML .. [[
                    <text x="72%" y="57%" style="fill:#FFFFFF;font-size:5">Weapon:</text>
                    <text x="72%" y="60%" style="fill:#FFFFFF;font-size:5">Radar:</text>
                    <text x="72%" y="63%" style="fill:#FFFFFF;font-size:5">antiGravity:</text>
                    <text x="72%" y="66%" style="fill:#FFFFFF;font-size:5">atmoEngines:</text>
                    <text x="72%" y="69%" style="fill:#FFFFFF;font-size:5">spaceEngines:</text>
                    <text x="72%" y="72%" style="fill:#FFFFFF;font-size:5">rocketEngines:</text>
                    <text x="72%" y="75%" style="fill:#FFFFFF;font-size:5">Mass:</text>

                    <text x="85%" y="57%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.weapons)..[[</text>
                    <text x="85%" y="60%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.radars)..[[</text>
                    <text x="85%" y="63%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.antiGravity)..[[</text>
                    <text x="85%" y="66%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.atmoEngines)..[[</text>
                    <text x="85%" y="69%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.spaceEngines)..[[</text>
                    <text x="85%" y="72%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.rocketEngines)..[[</text>
                    <text x="85%" y="75%" style="fill:#FFFFFF;font-size:5">]]..round(data.m)..[[</text>]]
                if radar.hasMatchingTransponder(SelTarget) == 1 then
                    local i,o = radar.getConstructOwnerEntity(id)
                    local n
                    if o then
                        n =system.getOrganization(i)
                    else
                        n = system.getPlayerName(i)
                    end
                    HTML = HTML .. [[
                        <text x="72%" y="81%" style="fill:#FFFFFF;font-size:5">Owner:</text>
                        <text x="85%" y="81%" style="fill:#FFFFFF;font-size:5">]]..n..[[</text>
                    ]]
                end
            end
            --{[float] weapons, [float] radars, [float] antiGravity, [float] atmoEngines, [float] spaceEngines, [float] rocketEngines} 
            local n = "ShowHostile"
            if rMode then n = "ShowFriendly" end
            HTML = HTML .. mscreener:addFancyButton(4,10,15,3,function ()
                rMode = not rMode
            end,n,mx,my)
            if hDead then n = "ShowDead" else n = "HideDead" end
            HTML = HTML .. mscreener:addFancyButton(20,10,15,3,function ()
                hDead = not hDead
            end,n,mx,my)
            if noData then n = "ShowAll" else n = "OnlyNoData" end
            HTML = HTML .. mscreener:addFancyButton(36,10,15,3,function ()
                noData = not noData
            end,n,mx,my)
            local y = 20
            local o = true
            --crawler
            local Hostile = 1
            if rMode then Hostile = 0 end
            local constructs = {}
            for _, id in pairs(radar.getConstructIds()) do
                if Hostile ~= radar.hasMatchingTransponder(id) then goto skip end
                if hDead then if radar.isConstructAbandoned(id) == 1 then goto skip end end
                if noData then if cData[id] ~= nil then goto skip end end
                table.insert(constructs,id)
                ::skip::
            end
            --drawer
            local time = system.getUtcTime()
            for i = 1, 109, 1 do
                local id = constructs[i+Offset]
                if id == nil then break end
                local lhit = lastHit[id] or time
                local mv
                if cData[id] ~= nil then
                    mv = round(GH:MasstoMaxV(cData[id].m)*3.6)
                    if radar.getConstructKind(id) ~= 5 then mv = "static" end
                end
                local d = damage[id] or 0
                HTML = HTML .. addShip(y,id,tostring(RW.CodeList[id]),string.sub(radar.getConstructName(id),0,19),radar.getConstructCoreSize(id),radar.getConstructKind(id),mv,d,round(time - lhit),o)
                o = not o
                y = y + 2.5
                if y > 97 then break end
            end
            --HTML = HTML .. addShip(y,3213212,"DAW","LEGION Hunter","XL",5,52121,1424555,"5 min",o)
            --HTML = HTML .. addShip(y+2.5,3213212,"DAW","LEGION Hunter","XL",5,52121,1424555,"5 min",not o)

            return HTML
        end)
    end
end
function self:setScreen()
    local id = weapon[1].getTargetId()
    if elementDestructions[id] == nil then elementDestructions[id] = {} end
    if damage[id] == nil then damage[id] = 0 end
    local dmg = 0
    for _,d in pairs(damage) do
        dmg = dmg + d
    end

    local svg = [[
        <svg viewBox="0 0 100 80" style="width:100%;height:100%">
            <rect x="0%" y="0%" rx="2" ry="2" width="100%" height="80%" style="fill:#4682B4;fill-opacity:0.35" />
            <text x="5%" y="7.5%" style="fill:#FFFFFF;font-size:5">CombatLog</text>
            <text x="50%" y="7.5%" style="fill:#FFFFFF;font-size:4">TargetData</text>
            <text x="50%" y="12%" style="fill:#FFFFFF;font-size:3">Dmg: </text>
            <text x="50%" y="16%" style="fill:#FFFFFF;font-size:3">DesElements: </text>
            <text x="80%" y="12%" style="fill:#FFFFFF;font-size:3">]].. round(damage[id]) ..[[</text>
            <text x="80%" y="16%" style="fill:#FFFFFF;font-size:3">]].. #elementDestructions[id] ..[[</text>

            <text x="50%" y="30%" style="fill:#FFFFFF;font-size:3">TotalDmg: </text>
            <text x="80%" y="30%" style="fill:#FFFFFF;font-size:3">]].. round(dmg) ..[[</text>

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
        local n1 = string.find(n,"%[") + 1
        local n2 = string.find(n,"]") - 1
        n = string.sub(n,n1,n2)
        svg = svg .. [[<text x="50%" y="]] .. 50 + y .. [[%" style="fill:#FFFFFF;font-size:3">]]..n..[[: </text>]]
        svg = svg .. [[<text x="65%" y="]] .. 50 + y .. [[%" style="fill:#FFFFFF;font-size:3">]]..round(pro,2)..[[%</text>]]
        svg = svg .. [[<text x="80%" y="]] .. 50 + y .. [[%" style="fill:#FFFFFF;font-size:3">]]..shots..[[</text>]]
        y = y + 4
    end
    for i = 0,15,1 do
        if i >= #log then break end
        svg = svg .. [[<text x="2%" y="]] .. 12 + i*4 .. [[%" style="fill:#FFFFFF;font-size:3">]]..log[#log - i]..[[</text>]]
    end
    return svg .. [[</svg>]]
end
return self