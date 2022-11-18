local self = {}
self.viewTags = {"screen"}
self.loadPrio = 100
self.version = 0.9
local Offset = 0
local baseFly = nil
local screener = nil
local locked = false
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    return true
end
local menupoint = "Main"
local menus = {}
local Buttons = {}
function self:addMenu(name,func)
    menus[name] = func
end
local settingstab = "gunner"
function self:onMouseDown(x,y,button)
    --print("track: "..x.."_"..y)
end
function self:onMouseUp(screen)
    local x = screen.mouseX * 100
    local y = screen.mouseY * 100
    for _, value in pairs(Buttons) do
        if (value.top <= y and y <= value.top + value.height and value.left <= x and x <= value.left + value.width) then
            pcall(value.func)
            break
        end
    end
end

function self:addButton(left,top,width,height,func)
    table.insert(Buttons,{
        ["top"] = top,
        ["left"] = left,
        ["width"] = width,
        ["height"] = height,
        ["func"] = func
    })
end
function self:addFancyButton(left,top,width,height,func,name,mx,my,c)
    table.insert(Buttons,{
        ["top"] = top,
        ["left"] = left,
        ["width"] = width,
        ["height"] = height,
        ["func"] = func
    })
    local o = 0.2
    if (top <= my and my <= top +  height and  left <= mx and mx <=  left + width) then
        o = 0.5
    end
    c = c or "4682B4"
    local HTML = [[                        
        <rect x="]].. left ..[[%" y="]].. top ..[[%" rx="2" ry="2" width="]].. width ..[[%" height="]].. height ..[[%" style="fill:#]]..c..[[;fill-opacity:]]..o..[[" />
        <text x="]]..left + width * 0.1 ..[[%" y="]]..top + height * 0.7 ..[[%" style="fill:#FFFFFF;font-size:]]..height*1.5 ..[[">]]..name..[[</text>
    ]]
    return HTML
end

function self:register(env)
    _ENV = env
    if not self:valid(auth) then return end
    baseFly = getPlugin("baseflight",true)
    screener = getPlugin("screener",true)
    if screener == nil then return end
    screener:addScreen("centerfirst",{
        offsetx=0.3035,
        offsety=0.11,
        width=0.393,
        height=0.7,
        perspective="first",
        parent="mainScreenFirst"
    })
    screener:registerDefaultScreen("centerfirst","Menu")

    screener:addView("Menu",self)

    register:addAction("option6Start","Exit",function ()
        local mode = system.getCameraMode()
        if mode == 1 and not locked then
            system.lockView(1)
            locked = true
            screener:freeMouse(true)
        else
            system.lockView(0)
            locked = false
            screener:freeMouse(false)
            if baseFly ~= nil then baseFly:setUpdateState(true) end
        end
    end)
    if player.getId() == 23833 then
        register:addAction("systemOnCameraChanged","ViewLocker", function (mode)
            if mode == 1 then 
                system.lockView(1)
                locked = true
                screener:freeMouse(true)
            end
        end)
    end
    register:addAction("systemOnCameraChanged","ViewLockerStop", function (mode)
        if mode ~= 1 then
            system.lockView(0)
            locked = false
            screener:freeMouse(false)
            if baseFly ~= nil then baseFly:setUpdateState(true) end
        end
    end)
    self:addMenu("settings", function (mx,my,ms,mouseInWindow)
        self:addButton(3,10,20,3,function ()
            settingstab = "gunner"
            Offset = 0
        end)
        self:addButton(53,10,20,3,function ()
            settingstab = "remote"
            Offset = 0
        end)
        if mouseInWindow then
            if baseFly ~= nil then baseFly:setUpdateState(false) end
            Offset = Offset + system.getMouseWheel() * -1
        else
            if baseFly ~= nil then baseFly:setUpdateState(true) end
        end
        if Offset < 0 then Offset = 0 end
        local HTML = ""
        if unitType == "gunner" then
            local c1 = "4682B4"
            local c2 = "4682B4"
            if settingstab == "gunner" then c1 = "00ff00" else c2 = "00ff00" end
            HTML = [[           
            <rect x="2%" y="9%" rx="2" ry="2" width="96%" height="89%" style="fill:#4682B4;fill-opacity:0.35" />

            <rect x="3%" y="10%" rx="2" ry="2" width="20%" height="3%" style="fill:#]]..c1..[[;fill-opacity:0.8" />
            <text x="5%" y="12%" style="fill:#FFFFFF;font-size:6">Gunner</text>

            <rect x="53%" y="10%" rx="2" ry="2" width="20%" height="3%" style="fill:#]]..c2..[[;fill-opacity:0.8" />
            <text x="55%" y="12%" style="fill:#FFFFFF;font-size:6">Remote</text>
            ]]
        end
        if unitType == settingstab then
            HTML = HTML .. [[]]
            local lines = {}
            local set = getPlugin("settings")
            for k,group in pairs(set.Description) do
                table.insert(lines, {k,nil})
                for name, des in pairs (group) do
                    table.insert(lines, {k,name})
                end
            end
            local o = false
            for i = 1, 80, 1 do
                local c = i + Offset
                local opacity = 0
                o = not o
                if o then opacity = 0.3 end
                if lines[c] == nil then break end
                local g = lines[c][1]
                local n = lines[c][2]
                local col = "4682B4"
                if (i*3+13.2 <= my and my <= i*3+13 + 2.5 and  2.5 <= mx and mx <=  2.5 + 95) then
                    col = "244c9c"
                    opacity = 0.3
                end
                if n == nil then
                    HTML = HTML .. [[<rect x="2.5%" y="]]..i*3+13 ..[[%" rx="2" ry="2" width="95%" height="3%" style="fill:#]]..col..[[;fill-opacity:]]..opacity..[[" /><text x="5%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">]]..g..[[</text>]]
                else
                    HTML = HTML .. [[<rect x="2.5%" y="]]..i*3+13 ..[[%" rx="2" ry="2" width="95%" height="3%" style="fill:#]]..col..[[;fill-opacity:]]..opacity..[[" /><text x="5%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">]]..n..[[</text><text x="60%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">]]..set.Description[g][n]..[[</text>
                    <text x="25%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">]]..tostring(set:get(n,g))..[[</text>
                    ]]
                    local r = set.Range[g][n]
                    if r[1] == "boolean" then
                        HTML = HTML .. [[<text x="30%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">{]]..tostring(not set:get(n,g))..[[}</text>]]
                        self:addButton(30,i*3+13.2,5,2.5,function ()
                            set:set(n,not set:get(n,g),g)
                        end)
                    elseif r[1] == "string" then
                        local x = 0
                        for _,v in pairs(r[2]) do
                            HTML = HTML .. [[<text x="]].. 30+x ..[[%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">{]]..v..[[}</text>]]
                            self:addButton(30 + x,i*3+13.2,#v*1.5,2.5,function ()
                                set:set(n,v,g)
                            end)
                            x = x + (#v+2)
                        end
                    
                    elseif r[1] == "number" then
                        local x = 0
                        HTML = HTML .. [[<text x="]].. 30+x ..[[%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">{]]..r[2]..[[}</text>]]
                        self:addButton(29.25 + x,i*3+13.2,4.5,2.5,function ()
                            set:set(n,r[2],g)
                        end)
                        x = x + 4
                        HTML = HTML .. [[<text x="]].. 30+x ..[[%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">{-]]..r[4]..[[}</text>]]
                        self:addButton(29.25 + x,i*3+13.2,4.5,2.5,function ()
                            set:set(n,set:get(n,g) - r[4],g)
                        end)
                        x = x + 4
                        HTML = HTML .. [[<text x="]].. 30+x ..[[%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">{+]]..r[4]..[[}</text>]]
                        self:addButton(29.25 + x,i*3+13.2,4.5,2.5,function ()
                            set:set(n,set:get(n,g) + r[4],g)
                        end)
                        x = x + 4
                        HTML = HTML .. [[<text x="]].. 30+x ..[[%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">{]]..r[3]..[[}</text>]]
                        self:addButton(29.25 + x,i*3+13.2,4.5,2.5,function ()
                            set:set(n,r[3],g)
                        end)
                    else

                    end
                end
            end
        end
        return HTML
    end)
    if unitType ~= "gunner" then
        self:addMenu("Commander", function (mx,my,ms,mouseInWindow)
            if mouseInWindow and (9 <= my and my <= 98 and  2 <= mx and mx <=  68) then
                if baseFly ~= nil then baseFly:setUpdateState(false) end
                Offset = Offset + system.getMouseWheel() * -1
            else
                if baseFly ~= nil then baseFly:setUpdateState(true) end
            end
            return ""
        end)
        self:addMenu("Ship", function (mx,my,ms,mouseInWindow)
            if mouseInWindow and (9 <= my and my <= 98 and  2 <= mx and mx <=  68) then
                if baseFly ~= nil then baseFly:setUpdateState(false) end
                Offset = Offset + system.getMouseWheel() * -1
            else
                if baseFly ~= nil then baseFly:setUpdateState(true) end
            end
            return ""
        end)
        self:addMenu("Main", function (mx,my,ms,mouseInWindow)
            HTML = ""
            self:addFancyButton(3,93,15,4,function ()
                unit.exit()
            end,"AllExit",mx,my)
            HTML = HTML .. self:addFancyButton(35,93,15,4,function ()
                unit.exit()
            end,"RemoteExit",mx,my)
            return HTML
        end)
    end
end
--viewObj, screen, realScreen.getMouseX(),realScreen.getMouseY(),realScreen.getMouseState() == 1,"real"..totalViewName
function self:setScreen(screen)
    local mx = screen.mouseX
    local my = screen.mouseY
    local ms = screen.mouseDown
    local mouseInScreen = false
    local mouseInWindow = false
    mx = mx * 100
    my = my * 100
    if (0 <= my and my <= 100 and 0 <= mx and mx <= 100) then
        mouseInScreen = true
        if (9 <= my and my <= 98 and 2 <= mx and mx <= 98) then
            mouseInWindow = true
        end
    end
    if system.isViewLocked() ~= 1 and unitType ~= "remote" then return "" end
    if not locked then return end
    Buttons = {}
    self:addButton(2,2,17.6,5,function ()
        menupoint = "Main"
    end)
    self:addButton(21.6,2,17.6,5,function ()
        menupoint = "Commander"
    end)
    self:addButton(41.2,2,17.6,5,function ()
        menupoint = "Ship"
    end)
    self:addButton(60.8,2,17.6,5,function ()
        menupoint = "Pilot"
    end)
    self:addButton(80.4,2,17.6,5,function ()
        menupoint = "settings"
        Offset = 0
    end)
    self:addButton(92.5,92.5,5,5,function ()
        system.lockView(0)
        locked = false
        screener:freeMouse(false)
        if baseFly ~= nil then baseFly:setUpdateState(true) end
    end)
    local HTML = ""
    if unitType == "gunner" then 
        HTML = [[        
        <svg style="width:100%;height:100%" viewBox="0 0 300 300">
            <rect x="0%" y="0%" rx="2" ry="2" width="100%" height="100%" style="fill:#000000;fill-opacity:0.35" />

            <rect x="2%" y="2%" rx="2" ry="2" width="17.6%" height="5%" style="fill:#4682B4;fill-opacity:0.8" />
            <rect x="21.6%" y="2%" rx="2" ry="2" width="17.6%" height="5%" style="fill:#4682B4;fill-opacity:0.8" />
            <rect x="41.2%" y="2%" rx="2" ry="2" width="17.6%" height="5%" style="fill:#4682B4;fill-opacity:0.8" />
            <rect x="60.8%" y="2%" rx="2" ry="2" width="17.6%" height="5%" style="fill:#4682B4;fill-opacity:0.8" />
            <rect x="80.4%" y="2%" rx="2" ry="2" width="17.6%" height="5%" style="fill:#4682B4;fill-opacity:0.8" />

            <text x="8%" y="5.5%" style="fill:#FFFFFF;font-size:8">Main</text>
            <text x="22%" y="5.5%" style="fill:#FFFFFF;font-size:8">Commander</text>
            <text x="47%" y="5.5%" style="fill:#FFFFFF;font-size:8">Ship</text>
            <text x="66.5%" y="5.5%" style="fill:#FFFFFF;font-size:8">Pilot</text>
            <text x="83.8%" y="5.5%" style="fill:#FFFFFF;font-size:8">Settings</text>]]
    else
        HTML = [[        
            <svg style="width:100%;height:100%" viewBox="0 0 300 300">]]
    end
    local s,res = pcall(menus[menupoint],mx,my,ms,mouseInWindow)
    res = res or ""
    if s then
        HTML = HTML .. res
    else
        if devMode then 
            print(res)
        end
    end

    return HTML .. [[<text x="94%" y="97%" style="fill:#FFFFFF;font-size:14">X</text></svg>]]
end


return self
