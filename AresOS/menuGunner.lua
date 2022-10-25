local self = {}
self.loadPrio = 100
self.version = 0.9

function self:valid(key)
    return unitType == "gunner"
end

function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
    local mscreener = getPlugin("menuscreener",true)
    if mscreener == nil then return end

    mscreener:addMenu("Main", function (mx,my,ms,mouseInWindow)
        HTML = [[
        <rect x="66%" y="9%" rx="2" ry="2" width="32%" height="20%" style="fill:#4682B4;fill-opacity:0.35" />
        <text x="70%" y="13%" style="fill:#FFFFFF;font-size:8">Destinations</text>]]
        HTML = HTML .. mscreener:addFancyButton(68,15,28,5,function ()
            system.setWaypoint("::pos{0,0,-91264.7828,408204.8952,40057.4424}")
        end,"Base",mx,my)
        return HTML
    end)
end

local function setScreen()

end


return self