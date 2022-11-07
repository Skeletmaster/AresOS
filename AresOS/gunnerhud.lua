local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "gunner"
end
self.version = 0.9
self.loadPrio = 1000
self.viewTags = {"hud"}
local newShipWar = 0
local newShip = {}
local oldTargetspeed = 0
local u = unit
local s = system
local uiDied = 0
local lastShip = 0
function self:register(env)
	if not self:valid(auth) then return end

    ownShortName = getPlugin("shortname",true,"AQN5B4-@7gSt1W?;"):getShortName(construct.getId())
    register:addAction("OnEnter","Alarm",function (id)
        newShipWar = 20
        table.insert(newShip,id)
        lastShip = id
    end)
    register:addAction("OnDestroyed","Kill",function (id)
        uiDied = system.getArkTime()
    end)
    local screener = getPlugin("screener")
    if screener ~= nil then
        screener:registerDefaultScreen("mainScreenThird","gunnerhud")
        screener:registerDefaultScreen("mainScreenFirst","gunnerhud")

        screener:addView("gunnerhud",self)
    end

    register:addAction("option8Start","Vent",function()
        if shield ~= nil then
            if shield.isVenting() == 0 then
                shield.startVenting()
                system.playSound("HSC/venting_shield.mp3")
            else
                shield.stopVenting()
            end
        end
    end)
end

function self:setScreen()
	local uiShieldPercent = 0
	local uiShieldActive = 0
    if shield ~= nil then           
        uiShieldPercent = math.ceil(shield.getShieldHitpoints() / shield.getMaxShieldHitpoints()*100)
        uiShieldActive = shield.isActive()
    end
    local uiHitchance, uiTargetSpeed, uiTargetSpeedUp, uiTargetDist, uiTargetID, uiMaxV, _, uiAmmoType = targetHud()

    local rw = getPlugin("radarwidget",true,"AQN5B4-@7gSt1W?;")
    
    local uiAmmoPercent,uiRelaodTime = getMinAmmo()
    local shieldBar = uiShieldPercent
    local ammoBar = uiAmmoPercent
    local corestress = 0
    if core ~= nil then
        corestress = (1-core.getCoreStressRatio()) * 100
    end
    local color

    ------
    local svgOut = "<svg width=\"100%\" height=\"94.5%\" viewBox=\"0 0 1920 1080\" style=\"top:0;left:0\">"

    -- window mid buttom
    svgOut = svgOut .. "<rect x=\"52%\" y=\"93.95%\" rx=\"2\" ry=\"2\" width=\"23.15%\" height=\"4.8%\" style=\"fill:#4682B4;fill-opacity:0.35\" />" ..
                    "<rect x=\"52.2%\" y=\"96.4%\" width=\"7.25%\" height=\"1.9%\" style=\"fill:none;stroke:#FFFFFF;stroke-width:1px\" />" ..
                    "<rect x=\"59.95%\" y=\"96.4%\" width=\"7.25%\" height=\"1.9%\" style=\"fill:none;stroke:#FFFFFF;stroke-width:1px\" />" ..
                    "<rect x=\"67.7%\" y=\"96.4%\" width=\"7.25%\" height=\"1.9%\" style=\"fill:none;stroke:#FFFFFF;stroke-width:1px\" />" 

    -- shield
    if shield ~= nil then           
        svgOut = svgOut .. "<text x=\"52.35%\" y=\"95.8%\" font-family=\"Super Sans\" text-anchor=\"start\" style=\"fill:#FFFFFF;font-size:15px\">Shield (" .. round(uiShieldPercent,2) .."%)</text>"
        if uiShieldActive == 0 then 
            color = "#777777"
        else
            if shieldBar >= 66 then color = "#009acd" else
                if shieldBar < 66 and shieldBar > 33 then color = "#FFA500" end
                if shieldBar <= 33  then color = "#FF0000" end
            end
        end
        for i = 0,19,1 do
            if shieldBar > 0 then svgOut = svgOut .. "<rect width=\"0.25%\" height=\"1.225%\" x=\"" .. 52.35 + (0.35*i) .. "%\" y=\"96.7%\" style=\"fill:" .. color .. "\" />" end
            if shieldBar <= 0 then svgOut = svgOut .. "<rect width=\"0.25%\" height=\"1.225%\" x=\"" .. 52.35 + (0.35*i) .. "%\" y=\"96.7%\" style=\"fill:#2C3539\" />" end    
            shieldBar = shieldBar - 5
        end       
    end

    -- core stress
    if core ~= nil then
        svgOut = svgOut .. "<text x=\"60.1%\" y=\"95.8%\" font-family=\"Super Sans\" text-anchor=\"start\" style=\"fill:#FFFFFF;font-size:15px\">C. Stress ("..round((1-core.getCoreStressRatio()) * 100,2).."%)</text>"
        if corestress >= 100 then color = "#32CD32" else
            if corestress < 100 and corestress > 66 then color = "#FFA500" end
            if corestress <= 66 then color = "#FF0000" end
        end
        for i = 0,19,1 do
            if corestress > 0 then svgOut = svgOut .. "<rect width=\"0.25%\" height=\"1.225%\" x=\"" .. 60.1 + (0.35*i) .. "%\" y=\"96.7%\" style=\"fill:" .. color .. "\" />" end
            if corestress <= 0 then svgOut = svgOut .. "<rect width=\"0.25%\" height=\"1.225%\" x=\"" .. 60.1 + (0.35*i) .. "%\" y=\"96.7%\" style=\"fill:#2C3539\" />" end    
            corestress = corestress - 5
        end    
    end

    -- ammo
    svgOut = svgOut .. "<text x=\"67.85%\" y=\"95.8%\" font-family=\"Super Sans\" text-anchor=\"start\" style=\"fill:#FFFFFF;font-size:15px\">Ammo (" .. uiRelaodTime .. ")</text>"
    if ammoBar > 33 then color = "#CD661D" else
        if ammoBar <= 33 then color = "#FF0000" end
    end
    for i = 0,19,1 do
        if ammoBar > 0 then svgOut = svgOut .. "<rect width=\"0.25%\" height=\"1.225%\" x=\"" .. 67.85 + (0.35*i) .. "%\" y=\"96.7%\" style=\"fill:" .. color .. "\" />" end
        if ammoBar <= 0 then svgOut = svgOut .. "<rect width=\"0.25%\" height=\"1.225%\" x=\"" .. 67.85 + (0.35*i) .. "%\" y=\"96.7%\" style=\"fill:#2C3539\" />" end    
        ammoBar = ammoBar - 5
    end  

    if radar[1].getTargetId() ~= 0 then
        local s = rw.CodeList[radar[1].getTargetId()]
        if system.isViewLocked() ~= 1 then
            svgOut = svgOut .. "<text x=\"49.2%\" y=\"49%\" font-family=\"Super Sans\" text-anchor=\"start\" style=\"fill:#FFFFFF;font-size:15px\">" .. s .. "</text>"
        else
            svgOut = svgOut .. "<text x=\"49%\" y=\"3%\" font-family=\"Super Sans\" text-anchor=\"start\" style=\"fill:#FFFFFF;font-size:25px\">" .. s .. "</text>"
        end
    end


    local content5 = ""
    -- target data
    if uiTarget == true then
        if uiHitchance < 10 then 
            color = "#FF0000" 
        elseif uiHitchance <= 30 then 
            color = "#FFA500"
        else
            color = "#32CD32"
        end

        svgOut = svgOut .. "<rect x=\"" .. 52 .. "%\" y=\"89%\" rx=\"2\" ry=\"2\" width=\"23.15%\" height=\"4.8%\" style=\"fill:#4682B4;fill-opacity:0.35\"/>"
        svgOut = svgOut .. "<text x=\"" .. 52 + 0.5 .. "%\" y=\"91.8%\" style=\"fill:#FFFFFF;font-size:12px\">" .. "Hitchance:" .. "</text>"
                        .. "<text x=\"" .. 52 + 4 .. "%\" y=\"92%\" style=\"fill:".. color ..";font-size:20px\">" .. uiHitchance .."%</text>"
        if uiTargetSpeedUp == 0 then color = "#FFA500" elseif uiTargetSpeedUp < 0 then color = "#FF0000" else color = "#32CD32" end

        svgOut = svgOut .. "<text x=\"" .. 59 .. "%\" y=\"90.5%\" style=\"fill:#FFFFFF;font-size:12px\">" .. "Target Speed:" .. "</text>"
                        .. "<text x=\"" .. 59 + 4.5 .. "%\" y=\"91%\" style=\"fill:".. color ..";font-size:20px\">" .. uiTargetSpeed .."</text>"

        local DifSpeed = construct.getMaxSpeed()*3.6 - uiMaxV
        if math.abs(DifSpeed) < 500 then color = "#FFA500" elseif DifSpeed < 0 then color = "#FF0000" else color = "#32CD32" end
        if radar[1].getConstructKind(uiTargetID) == 5 then
            svgOut = svgOut .. "<text x=\"" .. 59 .. "%\" y=\"93.1%\" style=\"fill:#FFFFFF;font-size:12px\">" .. "   Max Speed:" .. "</text>"
                            .. "<text x=\"" .. 59 + 4.2 .. "%\" y=\"93.3%\" style=\"fill:".. color ..";font-size:15px\">" .. uiMaxV .."</text>"
        else
            svgOut = svgOut .. "<text x=\"" .. 59 .. "%\" y=\"93.1%\" style=\"fill:#FFFFFF;font-size:12px\">" .. "   Max Speed:" .. "</text>"
                            .. "<text x=\"" .. 59 + 4.2 .. "%\" y=\"93.3%\" style=\"fill:#FFFFFF;font-size:15px\"> Static </text>"
        end


        ammo = uiAmmoType
        
        --svgOut = svgOut .. "<text x=\"" .. 67 + 0.5 .. "%\" y=\"90.5%\" style=\"fill:#FFFFFF;font-size:14px\">" .. "Radial Speed:" .. "</text>"
        --                .. "<text x=\"" .. 72 + 0.5 .. "%\" y=\"90.5%\" style=\"fill:".. color ..";font-size:14px\">" .. uiTargetRadialSpeed .."</text>"
        local w = "false"
        if radar[1].getConstructInfos(uiTargetID).weapons ~= 0 then w = "true" end
        svgOut = svgOut .. "<text x=\"" .. 67 + 0.5 .. "%\" y=\"90.5%\" style=\"fill:#FFFFFF;font-size:12px\">" .. "Weaponised:" .. "</text>"
                        .. "<text x=\"" .. 71 + 0.5 .. "%\" y=\"90.5%\" style=\"fill:#FFFFFF;font-size:12px\">" .. w .."</text>"
        
        svgOut = svgOut .. "<text x=\"" .. 67 + 0.5 .. "%\" y=\"93.1%\" style=\"fill:#FFFFFF;font-size:12px\">" .. "Ammo Typ:" .. "</text>"
                        .. "<text x=\"" .. 71 + 0.5 .. "%\" y=\"93.1%\" style=\"fill:#FFFFFF;font-size:12px\">" .. ammo .."</text>"
        
        if math.abs(uiDied - system.getArkTime()) < 3  then
            content5 = [[
				<style>
					#KillMarker {display:block; position:absolute; top:0; left:0} 
				</style>
                </svg>
                <svg id="KillMarker" height="100%" width="100%">
                    <circle cx="50%" cy="50%" r="5%" stroke="red" stroke-width="1.5%" fill="none" opacity="0.5"/>
                </svg>
            ]]
        end
    end

    if ownShortName ~= nil and system.isViewLocked() ~= 1 then
        svgOut = svgOut .. "<rect x=\"" .. 69.4 .. "%\" y=\"84.1%\" rx=\"2\" ry=\"2\" width=\"5.75%\" height=\"4.75%\" style=\"fill:#4682B4;fill-opacity:0.35\"/>"
        svgOut = svgOut .. "<text x=\"" .. 70.4 .. "%\" y=\"87.1%\" style=\"fill:#FFFFFF;font-size:20px\">ID: " .. ownShortName .."</text>"
    end 

    if leaderTag ~= nil then
        local ID = findIdbyTag(leaderTag)
        if ID ~= nil then
            local Dis = radar[1].getConstructDistance(ID) / (1000)
            if Dis <= 0 or Dis == nil then
                svgOut = svgOut .. "<rect x=\"" .. 58 .. "%\" y=\"86.1%\" rx=\"2\" ry=\"2\" width=\"11.38%\" height=\"2.75%\" style=\"fill:#4682B4;fill-opacity:0.35\"/>"
                svgOut = svgOut .. "<text x=\"" .. 58.4 .. "%\" y=\"88%\" style=\"fill:#FF0000;font-size:15px\">Leader is out of Range</text>"                                
            else
                if Dis < 100 then color = "#32CD32" elseif Dis < 300 then color = "#FFA500" else color = "#FF0000" end 
                svgOut = svgOut .. "<rect x=\"" .. 58 .. "%\" y=\"86.1%\" rx=\"2\" ry=\"2\" width=\"11.38%\" height=\"2.75%\" style=\"fill:#4682B4;fill-opacity:0.35\"/>"
                svgOut = svgOut .. "<text x=\"" .. 58.4 .. "%\" y=\"88%\" style=\"fill:#FFFFFF;font-size:15px\">Distance to Leader:</text>"
                if Dis < 100 then
                    svgOut = svgOut .. "<text x=\"" .. 66.3 .. "%\" y=\"88%\" style=\"fill:".. color ..";font-size:15px\">" .. round(Dis, 1) .. "</text>"
                    svgOut = svgOut .. "<text x=\"" .. 68 .. "%\" y=\"88%\" style=\"fill:#FFFFFF;font-size:15px\">km</text>"
                else
                    svgOut = svgOut .. "<text x=\"" .. 66.3 .. "%\" y=\"88%\" style=\"fill:".. color ..";font-size:15px\">" .. round(Dis / 200,1) .. "</text>"
                    svgOut = svgOut .. "<text x=\"" .. 68 .. "%\" y=\"88%\" style=\"fill:#FFFFFF;font-size:15px\">su</text>"
                end
            end
        else
            svgOut = svgOut .. "<rect x=\"" .. 58 .. "%\" y=\"86.1%\" rx=\"2\" ry=\"2\" width=\"11.38%\" height=\"2.75%\" style=\"fill:#4682B4;fill-opacity:0.35\"/>"
            svgOut = svgOut .. "<text x=\"" .. 58.4 .. "%\" y=\"88%\" style=\"fill:#FF0000;font-size:15px\">Leader is out of Range</text>"
        end
    end
    svgOut = svgOut .. "</g>"

    -- Key-Bindings
    svgOut = svgOut .. "<rect x=\"28.25%\" y=\"91.95%\" rx=\"2\" ry=\"2\" width=\"8.2%\" height=\"6.8%\" style=\"fill:#4682B4;fill-opacity:0.35\" />"
    if uiShieldActive == 1 then colorShield = "#FFFFFF" else colorShield = "#FF0000" end 
    if isVenting == 0 then colorVenting = "#FFFFFF" else colorVenting = "#00FF00" end 

    if shield ~= nil then
    svgOut = svgOut .. "<text x=\"28.5%\" y=\"95.8%\" font-family=\"Super Sans\" text-anchor=\"start\" style=\"fill:" .. colorVenting ..";font-size:15px\">" ..
                    "Venting (Alt+8)  " .. round(shield.getVentingCooldown(),0) .. " </text>"
    end
    svgOut = svgOut .. "<text x=\"28.5%\" y=\"93.8%\" font-family=\"Super Sans\" text-anchor=\"start\" style=\"fill:#FFFFFF;font-size:15px\">CMCI off (Alt+6) </text>"
    
    svgOut = svgOut .. "<text x=\"28.5%\" y=\"97.8%\" font-family=\"Super Sans\" text-anchor=\"start\" style=\"fill:#FFFFFF;font-size:15px\">" ..
                    "Radar (Alt+3) </text>"

    svgOut = svgOut .. "</svg>"
    local a,b = pcall(AlarmHud)
    if not a then b = "" end
    return svgOut .. content5 .. StatsHud() .. b
end

function ConeHUD() --zu groß
    local w = weapon[1]
    svg = [[ 
        <svg id="StatsHud" height="100%" width="100%" viewBox="0 0 1920 1080">]]

    local dist = w.getOptimalDistance()
    print(dist)
    if w.getTargetId() > 0 then 
        dist = radar[1].getConstructDistance(w.getTargetId())
    end
    local pos = construct.getWorldPosition()
    local wf = construct.getWorldForward()
    local wr = construct.getWorldOrientationRight()
    local gegen = math.tan(w.getOptimalAimingCone()) * dist
    local v = library.getPointOnScreen({pos[1]+ wf[1]*dist, pos[2]+ wf[2]*dist, pos[3]+ wf[3]*dist})
    local v2 = library.getPointOnScreen({pos[1]+ wf[1]*dist + wr[1]*gegen, pos[2]+ wf[2]*dist + wr[2]*gegen, pos[3]+ wf[3]*dist + wr[3]*gegen})
    if v[1] == 0 and v[2] == 0 and v[3] == 0 then v = {-10,-10,-10} v2 = {-10,-10,-10} end
    --v2 = v2[1] - v[1]
    print(v2)
    svg = svg .. "<circle style=\"fill:#00FF00;opacity:0.1;\" cx=\"".. v[1]*1920 .. "\" cy=\"".. v[2]*1080 .. "\" r=\"" .. 0.3*1080 .."\" />" --svgGegenScope
    svg = svg .. "<circle style=\"fill:#00FF00;opacity:0.1;\" cx=\"".. v2[1]*1920 .. "\" cy=\"".. v2[2]*1080 .. "\" r=\"" .. 0.1*1080 .."\" />" --svgGegenScope

    return svg .. "</svg>"
end

function StatsHud()
    local rw = getPlugin("radarwidget",true,"AQN5B4-@7gSt1W?;")
    local content6 = [[
		<style>
			#StatsHud {display:block; position:absolute; top:0; left:0} 
			#StatsHud text {fill:aqua;font-family:Montserrat;fill:#FFFFFF;font-size:12px}
		</style>

        <svg id="StatsHud" height="100%" width="100%" viewBox="0 0 1920 1080">]]

    --FightStats
    content6 = content6 .. "<rect x=\"76.06%\" y=\"93.95%\" rx=\"2\" ry=\"2\" width=\"15%\" height=\"4.8%\" style=\"fill:#4682B4;fill-opacity:0.35\" />"

    content6 = content6 .. "<text x=\"76.6%\" y=\"95.2%\">Type</text>"
    content6 = content6 .. "<text x=\"76.6%\" y=\"96.7%\">Hostile</text>"
    content6 = content6 .. "<text x=\"76.6%\" y=\"98.2%\">Friendly</text>"

    content6 = content6 .. "<text x=\"80.1%\" y=\"95.2%\">L</text>"
    content6 = content6 .. "<text x=\"80.1%\" y=\"96.7%\">".. #rw.ConstructSort[0][5].L .."</text>"
    content6 = content6 .. "<text x=\"80.1%\" y=\"98.2%\">".. #rw.ConstructSort[1][5].L .."</text>"

    content6 = content6 .. "<text x=\"82.1%\" y=\"95.2%\">M</text>"
    content6 = content6 .. "<text x=\"82.1%\" y=\"96.7%\">".. #rw.ConstructSort[0][5].M .."</text>"
    content6 = content6 .. "<text x=\"82.1%\" y=\"98.2%\">".. #rw.ConstructSort[1][5].M .."</text>"

    content6 = content6 .. "<text x=\"84.1%\" y=\"95.2%\">S</text>"
    content6 = content6 .. "<text x=\"84.1%\" y=\"96.7%\">".. #rw.ConstructSort[0][5].S .."</text>"
    content6 = content6 .. "<text x=\"84.1%\" y=\"98.2%\">".. #rw.ConstructSort[1][5].S .."</text>"

    content6 = content6 .. "<text x=\"86.1%\" y=\"95.2%\">XS</text>"
    content6 = content6 .. "<text x=\"86.1%\" y=\"96.7%\">".. #rw.ConstructSort[0][5].XS .."</text>"
    content6 = content6 .. "<text x=\"86.1%\" y=\"98.2%\">".. #rw.ConstructSort[1][5].XS .."</text>"

    local StaF = rw.ConstructSort[1][6]
    local StaH = rw.ConstructSort[0][6]
    content6 = content6 .. "<text x=\"88.1%\" y=\"95.2%\">Station</text>"
    content6 = content6 .. "<text x=\"88.1%\" y=\"96.7%\">".. #StaH.L + #StaH.M + #StaH.S + #StaH.XS .."</text>"
    content6 = content6 .. "<text x=\"88.1%\" y=\"98.2%\">".. #StaF.L + #StaF.M + #StaF.S + #StaF.XS .."</text>"

    content6 = content6 .. [[</svg>

        ]]
    return content6
end

function AlarmHud()
    local old_radar = 0
    local content2 = [[
		<style>
			#AlarmHud, #AlarmHud svg {display:block; position:absolute; top:0; left:0} 
			#AlarmHud #FriendContact line {stroke:#01DF01;opacity:0.4;stroke-width:10%;fill-opacity:0;}
			#AlarmHud #EnemyContact line {stroke:#FF0000;opacity:0.4;stroke-width:10%;fill-opacity:0;}
		</style>

        <svg id="AlarmHud" height="100%" width="100%" viewBox="0 0 1920 1080">
        <g id="Layer_2">
        <title>Layer 2</title>
        ]]   

    local zone = false
    if weapon[1] ~= nil then
        if weapon[1].getWidgetData ~= nil then
            data1 = json.decode(weapon[1].getWidgetData())
            zone = data1.properties.outOfZone
        end
    end
    if zone == false then
        if newShipWar > 0 then      
            if #newShip > 0 and not devMode then
                local sizex = radar[1].getConstructCoreSize(newShip[1])
                print("------------")
                print("New Contact")
                print(sizex)
                print(getPlugin("shortname",true,"AQN5B4-@7gSt1W?;"):getShortName(newShip[1]) .. "-" .. radar[1].getConstructName (newShip[1])) 
                print(newShip[1])
                print(system.getWaypointFromPlayerPos())
                table.remove(newShip,1)
            end
            if radar[1].hasMatchingTransponder(lastShip) == 1 then
                system.playSound("HSC/new_radar_friend.mp3")
                content2 = content2..[[
                <svg id="FriendContact" x="0%" y="0%">
                <line stroke-linecap="undefined" stroke-linejoin="undefined" id="svg_2" y2="0" x2="1920" y1="0" x1="0" fill="none"/>
                <line stroke-linecap="undefined" stroke-linejoin="undefined" id="svg_3" y2="1080" x2="0" y1="0" x1="0" fill="none"/>
                <line stroke-linecap="undefined" stroke-linejoin="undefined" id="svg_4" y2="1080" x2="1920" y1="0" x1="1920" fill="none"/>
                <line stroke-linecap="undefined" stroke-linejoin="undefined" id="svg_5" y2="1080" x2="1920" y1="1080" x1="0" fill="none"/>
                ]]
            else                        
                system.playSound("HSC/new_radarcontact.mp3") 
                content2 = content2..[[
                    <svg id="EnemyContact" x="0%" y="0%">
                    <line stroke-linecap="undefined" stroke-linejoin="undefined" id="svg_2" y2="0" x2="1920" y1="0" x1="0" fill="none"/>
                    <line stroke-linecap="undefined" stroke-linejoin="undefined" id="svg_3" y2="1080" x2="0" y1="0" x1="0" fill="none"/>
                    <line stroke-linecap="undefined" stroke-linejoin="undefined" id="svg_4" y2="1080" x2="1920" y1="0" x1="1920" fill="none"/>
                    <line stroke-linecap="undefined" stroke-linejoin="undefined" id="svg_5" y2="1080" x2="1920" y1="1080" x1="0" fill="none"/>
                    ]]
            end
            newShipWar = newShipWar - 1
        end
    end    
    content2 = content2..[[
        </svg>
        ]] 
    return content2
end
function getMinAmmo()
    local minCount = 99
    for _,w in ipairs(weapon) do
        local a = w.getAmmoCount()
        if a < minCount then
            minCount = a
        end
    end
    local minTime = weapon[1].getCycleTime() * minCount
    local minPercent = minCount / weapon[1].getMaxAmmo()
    if minTime < 10 and relaod_warning == false then
        system.playSound("HSC/ammo_relaod.mp3")
        relaod_warning = true
    elseif  minTime > 10 and relaod_warning == true then
        relaod_warning = false
    end
    return minPercent * 100, FormatTimeString(minTime)
end
function FormatTimeString(seconds) -- Format a time string for display
    local minutes = 0
    local hours = 0
    local days = 0
    if seconds < 60 then
        seconds = math.floor(seconds)
    elseif seconds < 3600 then
        minutes = math.floor(seconds / 60)
        seconds = math.floor(seconds % 60) 
    elseif seconds < 86400 then
        hours = math.floor(seconds / 3600)
        minutes = math.floor( (seconds % 3600) / 60)
    else
        days = math.floor ( seconds / 86400)
        hours = math.floor ( (seconds % 86400) / 3600)
    end
    if days > 0 then 
        return days .. "d " .. hours .."h "
    elseif hours > 0 then
        return hours .. "h " .. minutes .. "m "
    elseif minutes > 0 then
        return minutes .. "m " .. seconds .. "s"
    elseif seconds > 0 then 
        return seconds .. "s"
    else
        return "0s"
    end
end
function targetHud()
    local id = radar[1].getTargetId()           
    local hitchance = 0
    local targetspeed = 0
    local targetDist = 0
    local targetspeedUp = 0 
    local MaxV = 0
    local Died = false
    local ammo = "Precision"
    uiTarget = false

    local w_id = nil
    for i,wp_count in ipairs(weapon) do
        if wp_count.getHitPoints() > 0 then
            w_id = wp_count
            break
        end
    end

    if w_id ~= nil and id ~= 0 and radar[1].isConstructIdentified(id) == 1 then
        local S = w_id.getWidgetData()
        local _,n = string.find(S, [["hitProbability":]])
        local n2 = string.find(S, [[,]], n)
        hitchance = round(tonumber(string.sub(S, n +1, n2 -1))* 100) 
        targetspeed = round(radar[1].getConstructSpeed(id) * 3.6)
        targetspeedUp = targetspeed - oldTargetspeed
        oldTargetspeed = targetspeed
        targetDist = radar[1].getConstructDistance(id)
        MaxV = round(self:MasstoMaxV(radar[1].getConstructMass(id)) *3.6)
        local Stat = radar[1].isConstructAbandoned(id)
        if oldTarget == id then
            Died = Stat ~= oldTargetStatus
        end
        oldTargetStatus = Stat
        oldTarget = id
        uiTarget = true

        local _,n = string.find(S, [["optimalDistance":]])
        local n2 = string.find(S, [[,]], n)
        local a = tonumber(string.sub(S, n +1, n2 -1)) * 1.1
        if targetDist < a then ammo = "Heavy" end
    end
    return hitchance, targetspeed, targetspeedUp, targetDist, id, MaxV, Died, ammo
end
function self:MasstoMaxV(m)
    m = m / 1000
    local a = ((6*10^-9)*m^4) - ((3*10^-5)*m^3) + (0.0573 * m^2) - 59.933 * m + 50430
    if m > 2000 then a = 20000 end
    a = utils.clamp(a, 20000, 50000)
    return a / 3.6
end
return self
