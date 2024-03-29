local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then
        nginx.log(ngx.ERR, "auth failed: ", key)
        return ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end
    return unitType == "gunner"
end
local radar = radar[1]
self.version = 0.91
self.viewTags = {"hud"}
local Scroll = 0
local Scrolling = false
local showingConstructs,Widgets,shortname,commandhandler,setData,RadarData,showingConstructsf
local conf = getPlugin("configuration")
local friOrgs = conf.friOrgs
local friPlayer = conf.friPlayer
self.ConstructSort = {
    [0] = {
        [0] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [1] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [2] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [3] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [4] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [5] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [6] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [7] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
    },
    [1] = {
        [0] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [1] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [2] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [3] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [4] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [5] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [6] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        [7] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
    },
    ["dead"] = {}
}
local settings = getPlugin("settings",true)

function self:register(env)
    _ENV = env                    
    if shield ~= nil then
        if shield.getStressRatioRaw() == {0,0,0,0} then
            shield.setResistances(0.3,0.3,0,0)
        end
    end
	if not self:valid(auth) then return end

	Widgets = getPlugin("widgetcreator",true,"AQN5B4-@7gSt1W?;")
	shortname = getPlugin("shortname",true,"AQN5B4-@7gSt1W?;")

    settings:add("SpecialSort",true,"","Sort Core Size first then distance","Radar_Widget")
    settings:add("IdentifiedonTop",true,"","Puts the Identified on Top of the screens","Radar_Widget")

    commandhandler = getPlugin("commandhandler")
    commandhandler:AddCommand("hide",function (input)
        local str = input[2]
        for _,v in pairs(mysplit(str, ",")) do
            v = string.sub(v,0,3)
            if v == "spa" then v = 6 elseif v == "sta" then v = 4 elseif v == "dyn" then v = 5 else v = string.upper(v) end
            settings:set(v, false,"Radar_Widget")
        end
    end,"hides core sizes: /hide XS,S,M,L,space,dynamic,static")
    commandhandler:AddCommand("show",function (input)
        local str = input[2]
        for _,v in pairs(mysplit(str, ",")) do
            v = string.sub(v,0,3)
            if v == "spa" then v = 6 elseif v == "sta" then v = 4 elseif v == "dyn" then v = 5 else v = string.upper(v) settings:set(v, true,"Radar_Widget_Size") return end
            settings:set(v, true,"Radar_Widget_Type")
        end
    end,"shows core sizes: /show XS,S,M,L,space,dynamic,static")

    --if v == "spa" then v = 6 elseif v == "sta" then v = 4 elseif v == "dyn" then v = 5 end 
    commandhandler:AddCommand("t",function(input) self.tosearch = string.upper(input[2]) self.SpecialRadarMode = "Search" end,"show the target: /t TW4")
    commandhandler:AddCommand("togdead",function(input)
        settings:set("ShowDead", not settings:get("ShowDead","Radar_Widget"),"Radar_Widget")
    end,"toggles if dead cores are shown")

    commandhandler:AddCommand("settags",function(_,input)
        local input = mysplit(string.sub(input,2,#input))
        local str = input[2]
        local tabletag = {}
        for _,tag in pairs(mysplit(str, ",")) do 
            table.insert(tabletag,tag)
        end
        if transponder ~= nil then
            transponder.activate()
            transponder.setTags(tabletag)
        end
    end,"sets the transponder Tags")

    commandhandler:AddCommand("gettags",function()
        if transponder ~= nil then
            for _,tag in pairs(transponder.getTags()) do
                print(tag)
            end
        end
    end,"gets the transponder Tags")

    coRadar = coroutine.create(function() self:radarwidget() end)
    --toShowConstructs
    self.RadarMode = "Hostile" --"Friendly"; External; Verified; Hostile
    settings:add("ShowDead",true,"","if dead are to be shown","Radar_Widget")

    settings:add("XS",true,"","if XS are to be shown","Radar_Widget_Size")
    settings:add("S",true,"","if S are to be shown","Radar_Widget_Size")
    settings:add("M",true,"","if M are to be shown","Radar_Widget_Size")
    settings:add("L",true,"","if L are to be shown","Radar_Widget_Size")
    settings:add("XL",true,"","if XL are to be shown","Radar_Widget_Size")

    settings:add(1,true,"","if Universes are to be shown","Radar_Widget_Type")
    settings:add(2,true,"","if Planets are to be shown","Radar_Widget_Type")
    settings:add(3,true,"","if Asteroids are to be shown","Radar_Widget_Type")
    settings:add(4,true,"","if Statics are to be shown","Radar_Widget_Type")
    settings:add(5,true,"","if Dynamics are to be shown","Radar_Widget_Type")
    settings:add(6,true,"","if Spaces are to be shown","Radar_Widget_Type")
    settings:add(7,true,"","if Aliens are to be shown","Radar_Widget_Type")

    settings:add("2LevelAuth",false,"","Owner based identification","Radar_Widget")

    register:addAction("laltStart", "RadarScroll", function() Scrolling = true end)
    register:addAction("laltStop", "RadarScroll", function() Scrolling = false end)
    register:addAction("systemOnUpdate", "radarScroll", function()
            if Scrolling then
                Scroll = Scroll + system.getMouseWheel() * -3
            end
            setData()
        end)
    register:addAction("systemOnUpdate", "radarwidget", function()
            if coroutine.status(coRadar) == "dead" then coRadar = coroutine.create(function() self:radarwidget() end) else coroutine.resume(coRadar) end
        end)

    addTimer("Trans", 0.4, self.AutoTrans)

    register:addAction("option3Start", "RadarSwitch", function() self:switchRadar() end)
    local screener = getPlugin("screener",true)

    if screener ~= nil then
        screener:registerDefaultScreen("mainScreenThird","Radar")
        screener:registerDefaultScreen("mainScreenFirst","Radar")
        screener:addView("Radar",self)
    end
end

local s = system
local u = unit
function self:switchRadar()
    if self.SpecialRadarMode ~= nil then
        self.SpecialRadarMode = nil
    elseif self.RadarMode == "Hostile" then
        self.RadarMode = "Friendly"
    elseif self.RadarMode == "Friendly" then
        self.RadarMode = "Verified"
    elseif self.RadarMode == "Verified" then
        self.RadarMode = "External"
		local targets = getPlugin("Targets",true,"",true)
        if targets == nil then self.RadarMode = "Hostile" end
    elseif self.RadarMode == "External" then
        self.RadarMode = "Hostile"
    else
        self.RadarMode = "Hostile"
    end
end
function self:AddShip(id, RadarData, extra, k)
    k = k or 3
    extra = extra or ""
    local Ship,v = getSubJson(RadarData, tostring(id))
    if Ship ~= nil then
        Ship = AddUnique(Ship, id, extra)

        v = math.floor(v / 150)
        if Ship == nil then return end
        showingConstructs[k][v] = Ship
    end
end
function AddUnique(data, id, extra)
    local split = string.find(data, [["name":"]]) + #[["name":"]]
    return string.sub(data, 0, split -1) .. tostring(shortname:getShortName(id)) .. " - " .. extra .. string.sub(data, split, #data)
end
--checks which to choose
function getSubJson(data,id)
    if radar.hasMatchingTransponder(id) then
        return getSubJF(data,id)
    else
        return getSubJH(data,id)
    end
end
--only for hostile possible
function getSubJH(data,id)
    local min = string.find(data,id .. [[","]])
    if(min == nil) then return end
    local m = string.find(data, [["targetThreatState"]], min + 100)
    local max = string.find(data, [[}]], m)
    return string.sub(data, min - 16, max), min
end
--this is possible for Friendly
function getSubJF(data,id)
    local min = string.find(data,id ..  [[","]])
    if(min == nil) then return end
    local _,max = string.find(data, [[)"}]], min +100) --"
    return string.sub(data, min - 16, max), min
end

function self:radarwidget()
    local ConstructSort = {
        [0] = {
            [0] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [1] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [2] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [3] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [4] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [5] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [6] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [7] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        },
        [1] = {
            [0] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [1] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [2] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [3] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [4] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [5] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [6] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
            [7] = {["XS"] = {},["S"] = {},["M"] = {},["L"] = {},["XL"] = {}},
        },
        ["dead"] = {}
    }

    
    local cList = radar.getConstructIds()
    local Data = radar.getWidgetData()
    RadarData = Data
    showingConstructs = {[1] = {},[2] = {},[3] = {},[4] = {},[5] = {},[6] = {}}
    local AlienCore = -1

    for _,ID in pairs(cList) do
        local fri = not radar.hasMatchingTransponder(ID)
        local dead = radar.isConstructAbandoned(ID)
        if settings:get("2LevelAuth","Radar_Widget") then
            local id,o = radar.getConstructOwnerEntity(ID)
            o = id.isOrganization
            id = id.id
            if o then
                if not inTable(friOrgs,id) then
                    fri = true
                end
            else
                if not inTable(friPlayer,id) then
                    fri = true
                end
            end
        end
        local size = radar.getConstructCoreSize(ID)
        local kind = radar.getConstructKind(ID)
        if kind == -1 then goto skip end --toCheck
        if kind == 7 then AlienCore = ID end

        if dead then
            table.insert(ConstructSort["dead"], ID)
        else
            if fri then n = 0 else n = 1 end
            table.insert(ConstructSort[n][kind][size], ID)
        end

        --Sort for Widget
        if (self.RadarMode == "Hostile" or self.RadarMode == "Friendly") and self.SpecialRadarMode == nil then
            if self.RadarMode == "Friendly" then fri = not fri end

            if fri and settings:get(size,"Radar_Widget_Size") and settings:get(kind,"Radar_Widget_Type") then
                if not settings:get("ShowDead","Radar_Widget") and dead then goto skip end
                local extra = ""
                if settings:get("SpecialSort","Radar_Widget") then
                    if size == "XL" then k = 2 elseif size == "L" then k = 3 elseif size == "M" then k = 4 elseif size == "S" then k = 5 elseif size == "XS" then k = 6 end
                end
                if settings:get("IdentifiedonTop","Radar_Widget") then if radar.isConstructIdentified(ID) then k = 1 end end
                if dead then extra = "dead - " end
                self:AddShip(ID,Data,extra,k)
            end
        end
        ::skip::

        if system.getInstructionCount() > 1000000 then coroutine.yield() end
    end
    if self.SpecialRadarMode == nil then 
        local a,b = pcall(self.RadarModes[self.RadarMode],Data)
    else
        pcall(self.RadarModes[self.SpecialRadarMode],Data)
    end
    self.AlienCore = AlienCore
    self.ConstructSort = ConstructSort
    showingConstructsf = showingConstructs
end

function setData()
    local Data = RadarData
    if showingConstructsf == nil then return end
    local SortedConstructs = {[1] = {},[2] = {},[3] = {},[4] = {},[5] = {},[6] = {}}
    local p = 0 
    for k,t in pairs(showingConstructsf) do
        for c = 0,math.ceil(#Data / 150),1 do
            p = p + 1
            if t[c] ~= nil then 
                SortedConstructs[k][#SortedConstructs[k] + 1] = t[c] 
            end
            if p > 5000 then p = 0 coroutine.yield() end
        end
    end
    --creates the new widget
    local ConsCount = 0
    for _,t in pairs(SortedConstructs) do
        ConsCount = ConsCount + #t
    end
    self.ConsCount = ConsCount
    local newList = {}
    for k,t in pairs(SortedConstructs) do
        for _,l in pairs(t) do
            table.insert(newList,l)
        end
    end
    local max = #newList
    if Scroll > max -4 then Scroll = max -4 end
    if Scroll < 0 then Scroll = 0 end
    for c = 1, Scroll, 1 do
        table.remove(newList,1)
    end
    local list = {}
    for _, value in ipairs(newList) do
        table.insert(list,value)
        if #list >= 4 then break end
    end
    local Ships = table.concat(list, ",") .. ","

    local Num = string.find(Data,[[],]])
    local EndString = string.sub(Data,Num,#Data)
    local _,Num2 = string.find(EndString,[["errorMessage":"",]])
    local _,n = string.find(EndString,[["worksInSpace":]])
    local n2 = string.find(EndString,[[e]], n) +1
    local _,n3 = string.find(EndString,[["worksInAtmosphere":]])
    local n4 = string.find(EndString,[[e]], n3) +1
    local m = self.SpecialRadarMode or self.RadarMode
    
    if Num2 ~= nil then EndString = string.sub(EndString,0,Num2 - 2) .. m .. " Scroll: " .. Scroll .. " / " .. max .. string.sub(EndString, Num2 - 1, n3) .. "false" ..  string.sub(EndString, n4, n) .. "false" .. string.sub(EndString, n2, #EndString) end

    Output = [[{"constructsList":[]] .. string.sub(Ships,0,#Ships -1) .. EndString

    s.updateData(Widgets.RadarDataID, Output)
end

self.RadarModes = {
    ["External"] = function(Data)
		local targets = getPlugin("Targets",true)
        if targets ~= nil then
            for _,v in pairs(targets) do 
                local id = shortname:getId(v.shortid[1])
                self:AddShip(id,Data)
            end
			unloadPlugin("Targets")
        end
    end,
    ["Verified"] = function(Data)
        local targets = radar.getIdentifiedConstructIds()
        for _,id in pairs(targets) do 
            self:AddShip(id,Data, "searched - ",3)
        end
    end,
    ["Search"] = function(Data)
        local primary = 0
        if database.hasKey ~= nil then
            if database.hasKey("Primary") then
                primary = database.getIntValue("Primary")
                self:AddShip(primary, Data, "primary - ",1)
            end
        end

        local SelTarget = radar.getTargetId()
        if SelTarget ~= 0 then
            self:AddShip(SelTarget, Data, "selected - ",2)
        end

        local searchID = 0
        if self.tosearch ~= nil then
            searchID = shortname:getId(self.tosearch)
            if searchID ~= SelTarget then 
                self:AddShip(searchID,Data, "searched - ",3)
            end
        end

        for _,id in pairs(radar.getIdentifiedConstructIds()) do
            if id == primary or id == SelTarget or id == searchID then goto skip end
            self:AddShip(id, Data, "",5)
            ::skip::
        end
    end,
}

function self:AddRadarMode(name,func)
    self.RadarModes[name] = func
end
settings:add("autoTrans","off",{"string",{"auto","Hyp","off"}},"if Transponder should auto Update","Transponder")
function self:AutoTrans()
	local fname = "Transponder"
    if settings:get("autoTrans",fname) == "auto" then
		local transponders = getPlugin(fname,true,"",true)
        if transponders ~= nil then
			local tablea = {}
			local i = 1
			for _,v in pairs(transponders) do
				tablea[i] = v.transponder[1]
				i = i + 1
			end
			transponder.setTags(tablea)
			unloadPlugin(fname)
        end
    end
end


function self:setScreen()
    local HTML
    local w = weapon[1]
    local wmp,wop
    if w ~= nil then 
        wmp = w.getMaxDistance() / 400000
        wop = w.getOptimalDistance() / 400000
    end
    local rr = radar.getIdentifyRanges()[4] or 100000
    local rmp = rr / 400000

    if rmp > 1 then rmp = 1 end
    HTML = [[
        <head>
            <style>
                body {margin: 0}
                svg {display:block; position:absolute; top:0; left:0} 
            </style>
        </head>
        <body>
        <svg height="100%" width="100%" viewBox="0 0 1920 1080">
        <rect x="1898" y="333" rx="3" ry="3" width="26" height="670" style="fill:#4682B4;fill-opacity:0.35" />

        <rect x="1901" y="337" rx="3" ry="3" width="3" height="662" style="fill:#ffffff;fill-opacity:0.5" />
    ]]
    if wop ~= nil then
        HTML = HTML .. [[
            <rect x="1903" y="]] .. round(337 + (1-wmp)*662)  .. [[" width="2" height="]] .. round((wmp-wop)*662) .. [[" style="fill:#ff0000;fill-opacity:0.8" />
            <rect x="1903" y="]] .. round(337 + (1-wop)*662) .. [[" width="2" height="]] .. round(wop*662) .. [[" style="fill:#00ff00;fill-opacity:0.8" />
            <rect x="1899" y="]] .. round(337 + (1-rmp)*662) .. [[" width="8" height="3" style="fill:#000000;fill-opacity:1" />]]
        for _,id in pairs(radar.getIdentifiedConstructIds()) do 
            local d = radar.getConstructDistance(id) / 400000
            HTML = HTML .. [[<text x="1904" y="]] .. round(337 + (1-d)*662) + 3 .. [[" font-family="Super Sans" text-anchor="start" style="fill:#000000;font-size:10px;stroke:#000000;stroke-width:1px">]].. shortname:getShortName(id) .. [[</text>]]
        end
        local id = radar.getTargetId() 
        if id > 0 then 
            local d = radar.getConstructDistance(id) / 400000
            HTML = HTML .. [[<text x="1904" y="]] .. round(337 + (1-d)*662) + 3 .. [[" font-family="Super Sans" text-anchor="start" style="fill:#ff00ff;font-size:10px;stroke:#000000;stroke-width:1px">]].. shortname:getShortName(id) .. [[</text>]]
        end
    end
    local o = -35
    if #weapon < 4 then
        o = 250
    end
    local function c(b) if b then return "00ff00" else return "ff0000" end end
    HTML = HTML .. [[
        <rect x="1530" y="]].. 567 + o ..[[" rx="3" ry="3" width="145" height="125" style="fill:#4682B4;fill-opacity:0.35" />
        <text x="1540" y="]].. 585 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#ffffff;font-size:18px;stroke:#000000;stroke-width:1px">Type</text>
        <text x="1540" y="]].. 605 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#]] .. c(settings:get(4,"Radar_Widget_Type")) .. [[;font-size:15px;stroke:#000000;stroke-width:1px">Static</text>
        <text x="1540" y="]].. 625 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#]] .. c(settings:get(5,"Radar_Widget_Type")) .. [[;font-size:15px;stroke:#000000;stroke-width:1px">Dynamic</text>
        <text x="1540" y="]].. 645 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#]] .. c(settings:get(6,"Radar_Widget_Type")) .. [[;font-size:15px;stroke:#000000;stroke-width:1px">Space</text>
        <text x="1540" y="]].. 665 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#]] .. c(settings:get(7,"Radar_Widget_Type")) .. [[;font-size:15px;stroke:#000000;stroke-width:1px">Alien</text>
        <text x="1540" y="]].. 685 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#]] .. c(settings:get("ShowDead","Radar_Widget")) .. [[;font-size:15px;stroke:#000000;stroke-width:1px">Dead</text>
        
        <text x="1620" y="]].. 585 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#ffffff;font-size:18px;stroke:#000000;stroke-width:1px">Size</text>
        <text x="1620" y="]].. 605 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#]] .. c(settings:get("XL","Radar_Widget_Size")) .. [[;font-size:15px;stroke:#000000;stroke-width:1px">XL</text>
        <text x="1620" y="]].. 625 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#]] .. c(settings:get("L","Radar_Widget_Size")) .. [[;font-size:15px;stroke:#000000;stroke-width:1px">L</text>
        <text x="1620" y="]].. 645 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#]] .. c(settings:get("M","Radar_Widget_Size")) .. [[;font-size:15px;stroke:#000000;stroke-width:1px">M</text>
        <text x="1620" y="]].. 665 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#]] .. c(settings:get("S","Radar_Widget_Size")) .. [[;font-size:15px;stroke:#000000;stroke-width:1px">S</text>
        <text x="1620" y="]].. 685 + o ..[[" font-family="Super Sans" text-anchor="start" style="fill:#]] .. c(settings:get("XS","Radar_Widget_Size")) .. [[;font-size:15px;stroke:#000000;stroke-width:1px">XS</text>]]
    return HTML .. "</svg>"
end
return self
