local self = {}
self.version = 0.9
self.loadPrio = 1000
self.viewTags = {"screen"}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "gunner"
end
local tostring,tonumber = tostring,tonumber
local radar = radar[1]
local baseFly = getPlugin("baseflight",true)
local RW = getPlugin("radarwidget",true,"AQN5B4-@7gSt1W?;")
local GH = getPlugin("gunnerhud",true,"AQN5B4-@7gSt1W?;")
local ownData,otherData,shipData,weaponHits,weaponMisses,log = {data = {kills = {},id = player.getId(), name = player.getName()}, ships = {}},{},{},{},{},{}
local SelTarget = 0
local rMode = true
local show = {
    Dead = true,
    [4] = true,
    [6] = true,
    [7] = true,
    [5] = true,
    XL = true,
    L = true,
    M = true,
    S = true,
    XS = true
}
local noData = 1
local Offset = 0
local slave = false
local Com = ""
local function getData()
    
end
function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
    addTimer("combatData",1,function ()
        local owner = ""
        if radar.hasMatchingTransponder(id) == 1 then
            local i = radar.getConstructOwnerEntity(id)
            if i.isOrganization then
                owner = system.getOrganization(i.id).name
            else
                owner = system.getPlayerName(i.id)
            end
        end
        for _, id in pairs(radar.getIdentifiedConstructIds()) do
            database.setStringValue(id,json.encode({d = radar.getConstructInfos(id),m = radar.getConstructMass(id),n = radar.getConstructName(id),s = radar.getConstructCoreSize(id),k = radar.getConstructKind(id), o = owner, h = radar.hasMatchingTransponder(id), a = (radar.isConstructAbandoned(id) == 1), t = system.getArkTime()}))
            shipData[id] = {d = radar.getConstructInfos(id),m = radar.getConstructMass(id),n = radar.getConstructName(id),s = radar.getConstructCoreSize(id),k = radar.getConstructKind(id), o = owner, h = radar.hasMatchingTransponder(id), a = (radar.isConstructAbandoned(id) == 1), t = system.getArkTime()}
        end
        local toGet = {}
        for _, id in pairs(database.getKeyList()) do
            id = tonumber(id)
            if id ~= nil then
                if radar.isConstructIdentified(id) == 0 then
                    local t = 0
                    if shipData[id] ~= nil then t = shipData[id].t end
                    table.insert(toGet,{k = id,t = t})
                end
            end
        end
        table.sort(toGet, function(a,b) return tonumber(a.t) < tonumber(b.t) end) -- only safe to around 500
        for i = 1, 10, 1 do
            if toGet[i] == nil then break end
            local d = toGet[i].k
            local tab = json.decode(database.getStringValue(d))
            if system.getArkTime() -  tab.t > 3600 then
                database.clearValue(d)
            else
                shipData[d] = tab
            end
        end
    end)
    RW:AddRadarMode("Automatic",function (Data)
        local primary = 0
        if database.hasKey ~= nil then
            if database.hasKey("Primary") == 1 then 
                primary = database.getIntValue("Primary")
                RW:AddShip(primary, Data, "primary - ",1)
            end
        end 
        if SelTarget ~= 0 then
            RW:AddShip(SelTarget, Data, "selected - ",2)
        end
        for _,id in pairs(radar.getIdentifiedConstructIds()) do
            if id == primary or id == SelTarget then goto skip end
            RW:AddShip(id, Data, "")
            ::skip::
        end
    end)
    local cmd = getPlugin("commandhandler")
    cmd:AddCommand("t",function(input)
        if RW.SpecialRadarMode == "Automatic" then
            SelTarget = RW.IDList[string.upper(input[2])]
        else
            RW.tosearch = string.upper(input[2])
            RW.SpecialRadarMode = "Search"
        end
    end,"show the target: /t TW4")
    cmd:AddCommand("reset",function(input)
        for _, id in pairs(database.getKeyList()) do
            if type(id) == "number" then
                database.clearValue(id)
            end
        end
        for _,key in pairs(database.getKeyList()) do
            if string.sub(key,0,3) == "dmg" then
                database.clearValue(key)
            end
        end
    end,"resets constructData")


    register:addAction("OnHit", "combatData", function (id,d,w)
        if weaponHits[w.getLocalId()] == nil then weaponHits[w.getLocalId()] = 0 end
        weaponHits[w.getLocalId()] = weaponHits[w.getLocalId()] + 1
        
        table.insert(log, "Hit: "  .. round(d))

        id = tostring(id)
        if ownData.ships[id] == nil then ownData.ships[id] = {} end
        if ownData.ships[id].dmg == nil then ownData.ships[id].dmg = 0 end
        ownData.ships[id].dmg = ownData.ships[id].dmg + d
        
        ownData.ships[id].lhit = system.getUtcTime()

    end)

    register:addAction("OnElementDestroyed", "combatData", function (id,itemId,w)
        table.insert(log, "E: " .. string.sub(system.getItem(itemId).displayNameWithSize),0,20)

        id = tostring(id)

        if ownData.ships[id] == nil then ownData.ships[id] = {} end
        if ownData.ships[id].edes == nil then ownData.ships[id].edes = {} end
        table.insert(ownData.ships[id].edes, itemId)

    end)

    register:addAction("OnDestroyed", "combatData", function (id,w)
        table.insert(ownData.data.kills, id)
        table.insert(log, "Killed: " .. tostring(RW.CodeList[id]))
    end)

    register:addAction("OnMissed", "combatData", function (id,w)
        if weaponMisses[w.getLocalId()] == nil then weaponMisses[w.getLocalId()] = 0 end
        weaponMisses[w.getLocalId()] = weaponMisses[w.getLocalId()] + 1

        table.insert(log, "Missed: " .. tostring(RW.CodeList[id]))

        id = tostring(id)
        if ownData.ships[id] == nil then ownData.ships[id] = {} end
        ownData.ships[id].lhit = system.getUtcTime()
    end)
    register:addAction("unitOnStop","DataPrint", function ()
        print(json.encode({ownData = ownData, shipData = shipData}))
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

    addTimer("dmgtoDB",1,function ()
        ownData.data.t = system.getArkTime()
        database.setStringValue("dmg"..unit.getLocalId(),json.encode(ownData))
    end)
    local function getotherData()
        for _,key in pairs(database.getKeyList()) do
            local oId = string.sub(key,4,#key)
            if string.sub(key,0,3) == "dmg" and oId ~= tostring(unit.getLocalId()) then
                local list = json.decode(database.getStringValue(key))
                if system.getArkTime()-list.data.t > 3600 then
                    database.clearValue(key)
                else
                    otherData[oId] = list
                end
                coroutine.yield()
            end
        end
    end
    local corouData
    delay(function ()
        corouData = coroutine.create(getotherData)
    end, 0.2)
    addTimer("dmgfromDb",0.5,function()
        if coroutine.status(corouData) == "dead" then corouData = coroutine.create(getotherData) else coroutine.resume(corouData) end
    end)
    if database.hasKey("dmg"..unit.getLocalId()) == 1 then
        ownData = json.decode(database.getStringValue("dmg"..unit.getLocalId()))
        if system.getArkTime()-ownData.data.t > 3600 then
            ownData = {data = {kills = {}}, ships = {}}
        end
        ownData.data.id = player.getId()
        ownData.data.name = player.getName()
    end
    local mscreener = getPlugin("menuscreener",true,auth)
    if mscreener ~= nil then
        mscreener:addMenu("Commander", function (mx,my,ms,mouseInWindow)
            local primary = "none"
            if database.hasKey ~= nil then
                if database.hasKey("Primary") == 1 then 
                    primary = database.getIntValue("Primary")
                    primary = tostring(RW.CodeList[primary])
                end
            end 
            local function addShip(y,id,ID,name,Size,Type,MaxV,Dmg,lHit,o)
                mscreener:addButton(2.5,y-1.75,60,2.5,function ()
                    SelTarget = id
                    if not slave then
                        RW.tosearch = string.upper(ID)
                        RW.SpecialRadarMode = "Search"
                    end
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
                local HTML =  [[<rect x="2.5%" y="]]..y-1.75 ..[[%" rx="2" ry="2" width="65%" height="2.5%" style="fill:#]]..c..[[;fill-opacity:]]..opacity..[[" /><text x="3%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..ID..[[</text>
                <text x="7.8%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..name..[[</text>
                <text x="28%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..Size..[[</text>
                <text x="33%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..lookup[Type]..[[</text>
                <text x="39%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..MaxV..[[</text>
                <text x="47%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">]]..Dmg..[[</text>
                <text x="57%" y="]]..y..[[%" style="fill:#FFFFFF;font-size:5">T - ]]..lHit..[[ s</text>
                ]]
                if Com == "You" then
                    mscreener:addButton(65,y-1.75,2.5,2.5,function ()
                        if database.hasKey ~= nil then
                            database.setIntValue("Primary", id)
                        end
                    end)
                    local c = "00FF00"
                    if id == SelTarget then
                        c = "FFFF00"
                    elseif primary == ID then
                        c = "FF0000" 
                    end
                    HTML = HTML .. [[<rect x="65%" y="]]..y-1.75 ..[[%" rx="2" ry="2" width="2.5%" height="2.5%" style="fill:#]]..c ..[[;fill-opacity:0.2" />]]
                end
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
            local dmgs = {}
            for _,d in pairs(ownData.ships) do
                dps = dps + d.dmg
            end
            for k,tab in pairs(otherData) do
                k = tab.data.name
                dmgs[k] = 0
                for _,d in pairs(tab.ships) do
                    dmgs[k] = dmgs[k] + d.dmg
                end
                --ToDo lHit
            end
            for id in pairs(shipData) do
                local ID = tostring(id)
                if ownData.ships[ID] ~= nil and ownData.ships[ID].lhit ~= nil then
                    shipData[id].lhit = ownData.ships[ID].lhit
                    print(id)
                end
                for key, tab in pairs(otherData) do
                    if tab.ships[ID] ~= nil and tab.ships[ID].lhit ~= nil then
                        if shipData[id].lhit < tab.ships[ID].lhit then
                            shipData[id].lhit = tab.ships[ID].lhit 
                        end
                    end
                end
            end
            HTML = [[
            <rect x="2%" y="9%" rx="2" ry="2" width="66%" height="89%" style="fill:#4682B4;fill-opacity:0.35" />
            <rect x="70%" y="9%" rx="2" ry="2" width="28%" height="20%" style="fill:#4682B4;fill-opacity:0.35" />
            <rect x="70%" y="31%" rx="2" ry="2" width="28%" height="47%" style="fill:#4682B4;fill-opacity:0.35" />
            <rect x="70%" y="80%" rx="2" ry="2" width="28%" height="18%" style="fill:#4682B4;fill-opacity:0.35" />

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

            <text x="72%" y="34%" style="fill:#FFFFFF;font-size:7">TargetInfos:</text>]]
            local y = 18
            for k, d in pairs(dmgs) do
                HTML = HTML .. [[<text x="72%" y="]] .. y .. [[%" style="fill:#FFFFFF;font-size:5">]].. k ..[[</text>  <text x="85%" y="]] .. y .. [[%" style="fill:#FFFFFF;font-size:5">]]..round(d)..[[</text>]]
                y = y + 3
            end
            Com = ""
            if database.hasKey ~= nil then
                if database.hasKey("Com") == 1 then
                    Com = database.getStringValue("Com")
                    if Com == player.getName() then
                        Com = "You"
                    end
                end
            end
            HTML = HTML .. mscreener:addFancyButton(71,81,26,3,function ()
                if database == nil then return end
                if Com == "You" then
                    database.clearValue("Com")
                else
                    database.setStringValue("Com",player.getName())
                end
            end,"Commander:    " .. Com,mx,my)
            HTML = HTML .. [[<text x="72%" y="90%" style="fill:#FFFFFF;font-size:7">Primary:</text> <text x="85%" y="90%" style="fill:#FFFF00;font-size:10">]]..primary..[[</text>]]
            slave = RW.SpecialRadarMode == "Automatic"
            HTML = HTML .. mscreener:addFancyButton(71,94,10,3,function ()
                slave = not slave
                if slave then RW.SpecialRadarMode = "Automatic" else RW.SpecialRadarMode = nil end
            end,"Slave:  " .. tostring(slave),mx,my)

            if SelTarget == 0 or shipData[SelTarget] == nil then
                HTML = HTML .. [[<text x="72%" y="37%" style="fill:#FFFFFF;font-size:5">NoTargetSelected</text>]]
            else
                local data = shipData[SelTarget]
                HTML = HTML .. [[
                    <text x="72%" y="37%" style="fill:#FFFFFF;font-size:5">Weapon:</text>
                    <text x="72%" y="40%" style="fill:#FFFFFF;font-size:5">Radar:</text>
                    <text x="72%" y="43%" style="fill:#FFFFFF;font-size:5">antiGravity:</text>
                    <text x="72%" y="46%" style="fill:#FFFFFF;font-size:5">atmoEngines:</text>
                    <text x="72%" y="49%" style="fill:#FFFFFF;font-size:5">spaceEngines:</text>
                    <text x="72%" y="52%" style="fill:#FFFFFF;font-size:5">rocketEngines:</text>
                    <text x="72%" y="55%" style="fill:#FFFFFF;font-size:5">Mass:</text>

                    <text x="85%" y="37%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.weapons)..[[</text>
                    <text x="85%" y="40%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.radars)..[[</text>
                    <text x="85%" y="43%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.antiGravity)..[[</text>
                    <text x="85%" y="46%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.atmoEngines)..[[</text>
                    <text x="85%" y="49%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.spaceEngines)..[[</text>
                    <text x="85%" y="52%" style="fill:#FFFFFF;font-size:5">]]..tostring(data.d.rocketEngines)..[[</text>
                    <text x="85%" y="55%" style="fill:#FFFFFF;font-size:5">]]..round(data.m)..[[</text>]]
                if data.h == 1 then
                    HTML = HTML .. [[
                        <text x="72%" y="61%" style="fill:#FFFFFF;font-size:5">Owner:</text>
                        <text x="80%" y="61%" style="fill:#FFFFFF;font-size:5">]]..data.o..[[</text>
                    ]]
                end
            end
            --{[float] weapons, [float] radars, [float] antiGravity, [float] atmoEngines, [float] spaceEngines, [float] rocketEngines} 
            local n = "ShowHostile"
            if rMode then n = "ShowFriendly" end
            HTML = HTML .. mscreener:addFancyButton(4,10,15,3,function ()
                rMode = not rMode
            end,n,mx,my)

            if noData == 1 then n = "All" elseif noData == 2 then n = "OnlyNoData"  else n = "OnlyData"  end
            HTML = HTML .. mscreener:addFancyButton(20,10,15,3,function ()
                noData = noData + 1
                if noData > 3 then noData = 1 end
            end,n,mx,my)
            local function addToggle(x,y,k,mx,my)
                local lookup = {"Uni","Pla","Ast","Sta","Dyn","Spa","Ali"}
                local n = k
                if type(n) == "number" then n = lookup[n] end
                local c = "FF0000"
                if show[k] then c = "00FF00" end
                return mscreener:addFancyButton(x,y,4,2,function ()
                    show[k] = not show[k]
                end,n,mx,my,c)
            end
            HTML = HTML .. addToggle(40,10,"Dead",mx,my)
            HTML = HTML .. addToggle(45,10,4,mx,my)
            HTML = HTML .. addToggle(50,10,6,mx,my)
            HTML = HTML .. addToggle(55,10,7,mx,my)
            HTML = HTML .. addToggle(60,10,5,mx,my)

            HTML = HTML .. addToggle(40,13,"XL",mx,my)
            HTML = HTML .. addToggle(45,13,"L",mx,my)
            HTML = HTML .. addToggle(50,13,"M",mx,my)
            HTML = HTML .. addToggle(55,13,"S",mx,my)
            HTML = HTML .. addToggle(60,13,"XS",mx,my)

            local y = 20
            local o = true
            --crawler
            local Hostile = 1
            if rMode then Hostile = 0 end
            local constructs = {}
            local constructData = radar.getConstructIds()
            if noData == 3 then
                constructData = shipData
            end
            for ID, id in pairs(constructData) do
                if noData == 3 then
                    id = ID
                end
                if shipData[id] == nil then
                    if Hostile ~= radar.hasMatchingTransponder(id) then goto skip end
                    if not show["Dead"] and radar.isConstructAbandoned(id) == 1 then goto skip end
                    if not show[radar.getConstructKind(id)] then goto skip end
                    if not show[radar.getConstructCoreSize(id)] then  goto skip end
                else
                    if Hostile ~= shipData[id].h then goto skip end
                    if not show["Dead"] and shipData[id].a then goto skip end
                    if not show[shipData[id].k] then goto skip end
                    if not show[shipData[id].s] then  goto skip end
                    if noData == 2 then goto skip end
                end
                table.insert(constructs,id)
                ::skip::
            end
            --drawer
            local time = system.getUtcTime()
            for i = 1, 109, 1 do
                local id = constructs[i+Offset]
                if id == nil then break end
                local lhit =  time
                local d = 0 
                local mv
                if shipData[id] ~= nil then
                    mv = round(GH:MasstoMaxV(shipData[id].m)*3.6)
                    if shipData[id].k ~= 5 then mv = "static" end
                    lhit = shipData[id].lhit or time
                    local ID = tostring(id)
                    if ownData.ships[ID] ~= nil and  ownData.ships[ID].dmg ~= nil then
                        d = ownData.ships[ID].dmg 
                    end
                end
                if shipData[id] == nil then
                    HTML = HTML .. addShip(y,id,tostring(RW.CodeList[id]),string.sub(radar.getConstructName(id),0,19),radar.getConstructCoreSize(id),radar.getConstructKind(id),mv,0,tostring(round(time - lhit)),o)
                else
                    HTML = HTML .. addShip(y,id,tostring(RW.CodeList[tonumber(id)]),string.sub(shipData[id].n,0,19),shipData[id].s,shipData[id].k,mv,round(d),tostring(round(time - lhit)),o)
                end
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
    local id = 0
    if weapon[1] ~= nil then
        id = weapon[1].getTargetId()
    end
    local dmg = 0
    for _,d in pairs(ownData.ships) do
        dmg = dmg + d.dmg
    end
    
    local svg = [[
        <svg viewBox="0 0 100 80" style="width:100%;height:100%">
            <rect x="0%" y="0%" rx="2" ry="2" width="100%" height="80%" style="fill:#4682B4;fill-opacity:0.1" />
            <text x="5%" y="7.5%" style="fill:#FFFFFF;font-size:5">CombatLog</text>
            <text x="50%" y="7.5%" style="fill:#FFFFFF;font-size:4">TargetData</text>
            <text x="50%" y="12%" style="fill:#FFFFFF;font-size:3">Dmg: </text>
            <text x="50%" y="16%" style="fill:#FFFFFF;font-size:3">DesElements: </text>


            <text x="50%" y="30%" style="fill:#FFFFFF;font-size:3">TotalDmg: </text>
            <text x="50%" y="35%" style="fill:#FFFFFF;font-size:3">TotalKills: </text>

            <text x="50%" y="50%" style="fill:#FFFFFF;font-size:4">WData</text>
            <text x="65%" y="50%" style="fill:#FFFFFF;font-size:3">Hits</text>
            <text x="80%" y="50%" style="fill:#FFFFFF;font-size:3">Shots</text>
        ]]
    local ID = tostring(id)
    if id > 1 and ownData.ships[ID] ~= nil then
        svg = svg .. [[
            <text x="80%" y="12%" style="fill:#FFFFFF;font-size:3">]].. round(ownData.ships[ID].dmg) ..[[</text>
            <text x="80%" y="16%" style="fill:#FFFFFF;font-size:3">]].. #ownData.ships[ID].edes ..[[</text>]]
    end
    svg = svg .. [[<text x="80%" y="30%" style="fill:#FFFFFF;font-size:3">]].. round(dmg) ..[[</text>]]
    svg = svg .. [[<text x="80%" y="35%" style="fill:#FFFFFF;font-size:3">]].. round(#ownData.data.kills) ..[[</text>]]
    local y = 4
    for _,w in pairs(weapon) do
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