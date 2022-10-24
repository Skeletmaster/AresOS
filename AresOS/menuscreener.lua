local self = {}
self.viewTags = {"screen"}
self.loadPrio = 100
self.version = 0.9

function self:valid(key)
    return true
end
local menupoint = "Settings"
local menus = {}
local Buttons = {}
function self:addMenu(name,func)
    menus[name] = func
end
local settingstab = "gunner"

function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
    local screener = getPlugin("screener",true)
    if screener == nil then return end


    screener:addScreen("centerfirst",{
        offsetx=0.3,
        offsety=0.11,
        width=0.4,
        height=0.7,
        perspective="first",
        parent="mainScreenFirst"
    })
    screener:registerDefaultScreen("centerfirst","Menu")

    screener:addView("Menu",self)

    register:addAction("systemOnCameraChanged","ViewLocker", function (mode)
        if mode == 1 then 
            system.lockView(1)
        else
            system.lockView(0)
        end
    end)
    self:addMenu("Settings", function ()
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
            HTML = HTML .. [[

            ]]
            local lines = {}
            local set = getPlugin("Settings")
            for k,group in pairs(set.Description) do
                table.insert(lines, {k,nil})
                for name, des in pairs (group) do
                    table.insert(lines, {k,name})
                end
            end
            local Offset = 0
            for i = 1, 80, 1 do
                local c = i + Offset
                if lines[c] == nil then break end
                local g = lines[c][1]
                local n = lines[c][2]
                if n == nil then
                    HTML = HTML .. [[<text x="5%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">]]..g..[[</text>]]
                else
                    HTML = HTML .. [[<text x="5%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">]]..n..[[</text><text x="60%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">]]..set.Description[g][n]..[[</text>
                    <text x="25%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">]]..tostring(set:get(n,g))..[[</text>
                    ]]
                    local r = set.Range[g][n]
                    if r[1] == "boolean" then
                        HTML = HTML .. [[<text x="30%" y="]]..i*3+15 ..[[%" style="fill:#FFFFFF;font-size:5">{]]..tostring(not set:get(n,g))..[[}</text>
                        ]]
                        --add Button for this word to switch the statement
                    else

                    end
                end
            end
        end
        return HTML
    end)
end

function self:setScreen()
    if system.isViewLocked() ~= 1 then return "" end
    Buttons = {}
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
            <text x="83.8%" y="5.5%" style="fill:#FFFFFF;font-size:8">Settings</text>
        ]]
    else
    end
    local s,res = pcall(menus[menupoint])
    if s then
        HTML = HTML .. res
    end

    return HTML .. "</svg>"
end


return self