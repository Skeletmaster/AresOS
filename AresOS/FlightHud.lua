local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "remote" or unitType == "command"
end

self.version = 0.9
self.loadPrio = 1000
self.viewTags = {"hud"}
local u = unit
local s = system
local uiBlinkCounter = 0
local Flight
function self:register(env)
	if not self:valid(auth) then return end
	
    register:addAction("option7Start","Waypoint", function ()
        system.setWaypoint("::pos{0,0,-91264.7828,408204.8952,40057.4424}")
    end)
	Flight = getPlugin("BaseFlight",true,"AQN5B4-@7gSt1W?;") -- parameter 2 "true" prevents error message
	if Flight == nil then return end
	if core == nil then return end

    self.SpaceTanks,self.RocketTanks = getTankId()
    local screener = getPlugin("screener",true)
    if screener ~= nil then
        screener:registerDefaultScreen("mainScreenThird","FlightHud")
        screener:registerDefaultScreen("mainScreenFirst","FlightHud")

        screener:addView("FlightHud",self)
    end
end


function CalculateFuelLevel(id)
    return (core.getElementMassById(id[1]) - id["me"]) / id["mv"]
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

function self:setScreen()
    if construct.getMaxSpeed() < 700000 then maxSpeed = construct.getMaxSpeed() end

    local throttleBar = math.floor(unit.getAxisCommandValue(axisCommandId.longitudinal)*100)
    local minfuel = 100 
    for k,v in pairs(self.SpaceTanks) do
        local fl = CalculateFuelLevel(v)*100
        if fl < minfuel then minfuel = fl end
    end
    minfuel = round(minfuel)
    local blinkFuelRange = 20
    local color
    local svgOut = [[
			<style>
				#FlightHudMain, #FlightHudMain svg {display:block; position:absolute; top:0; left:0} 
				#FlightHudMain .majorLine {stroke:aqua;opacity:0.7;stroke-width:3;fill-opacity:0;}
				#FlightHudMain .minorLine {stroke:aqua;opacity:0.3;stroke-width:3;fill-opacity:0;}
				#FlightHudMain .text {fill:aqua;font-family:Montserrat;font-weight:bold}
			</style>
            <svg id="FlightHudMain" height="94.5%" width="100%" viewBox="0 0 1920 1080">
				<rect x="36.525%" y="93.95%" rx="2" ry="2" width="15.40%" height="4.8%" style="fill:#4682B4;fill-opacity:0.35" />
				<rect x="36.75%" y="96.4%" width="7.25%" height="1.9%" style="fill:none;stroke:#FFFFFF;stroke-width:1px" />
				<rect x="44.5%" y="96.4%" width="7.25%" height="1.9%" style="fill:none;stroke:#FFFFFF;stroke-width:1px" />
				<text x="36.75%" y="95.8%" font-family="Super Sans" text-anchor="start" style="fill:#FFFFFF;font-size:15px">Throttle (]] .. throttleBar .. [[%)</text>
        ]]

    -- throttle
    if engine[1] ~= nil then if engine[1].getThrust ~= nil then throttleBar = (engine[1].getThrust()/ engine[1].getMaxThrust())*100 end end
    for i = 0,19,1 do
        if throttleBar > 0 then svgOut = svgOut .. "<rect width=\"0.25%\" height=\"1.225%\" x=\"" .. 36.9 + (0.35*i) .. "%\" y=\"96.7%\" style=\"fill:#AFEEEE\" />" end
        if throttleBar <= 0 then svgOut = svgOut .. "<rect width=\"0.25%\" height=\"1.225%\" x=\"" .. 36.9 + (0.35*i) .. "%\" y=\"96.7%\" style=\"fill:#2C3539\" />" end
        throttleBar = throttleBar - 5
    end    

    -- fuel
    svgOut = svgOut .. "<text x=\"44.5%\" y=\"95.8%\" font-family=\"Super Sans\" text-anchor=\"start\" style=\"fill:#FFFFFF;font-size:15px\">Fuel (" .. minfuel .. "%)</text>"
    if minfuel < blinkFuelRange and blink then color = "#FF0000" else color = "#FFD801" end    
    for i = 0,19,1 do
        if minfuel > 0 then svgOut = svgOut .. "<rect width=\"0.25%\" height=\"1.225%\" x=\"" .. 44.65 + (0.35*i) .. "%\" y=\"96.7%\" style=\"fill:" .. color .. "\" />" end
        if minfuel <= 0 then svgOut = svgOut .. "<rect width=\"0.25%\" height=\"1.225%\" x=\"" .. 44.65 + (0.35*i) .. "%\" y=\"96.7%\" style=\"fill:#2C3539\" />" end    
        minfuel = minfuel - 5
    end    
    
    -- brake dist
    local BrakeDis, BrakeTime = Flight:getBrakeTime()
    svgOut = svgOut .. "<rect x=\"" .. 36.525 .. "%\" y=\"" .. 91 .. "%\" rx=\"2\" ry=\"2\" width=\"15.4%\" height=\"2.8%\" style=\"fill:#4682B4;fill-opacity:0.35\"/>"
    svgOut = svgOut .. "<text x=\"" .. 36.75 .. "%\" y=\"" .. 91 + 2 .. "%\" style=\"fill:#FFFFFF;font-size:11px\">" .. "Break:" .. "</text>"
                    .. "<text x=\"" .. 36.525 + 2.3 .. "%\" y=\"" .. 91 + 2 .. "%\" style=\"fill:#FFFFFF;font-size:11px\">" .. getDistanceDisplayString(BrakeDis,2) .. " (" .. FormatTimeString(BrakeTime) .. ")" .."</text>"
    
    svgOut = svgOut .. "<text x=\"" .. 44 + 0.5 .. "%\" y=\"" .. 91 + 2 .. "%\" style=\"fill:#FFFFFF;font-size:11px\">" .. "MaxSpeed:" .. "</text>"
                    .. "<text x=\"" .. 44 + 4 .. "%\" y=\"" .. 91 + 2 .. "%\" style=\"fill:#FFFFFF;font-size:11px\">" .. round(maxSpeed *3.6)  .." km/h</text>"
    
    svgOut = svgOut .. "</g>"

    -------------------------
    svgOut = svgOut .. "<rect x=\"28.25%\" y=\"89.2%\" rx=\"2\" ry=\"2\" width=\"8.2%\" height=\"2.6%\" style=\"fill:#4682B4;fill-opacity:0.35\" />"
    -- Handbreak

    if Flight.brake == 0 then color = "#FFFFFF" else color = "#FF0000" end 
    svgOut = svgOut .. "<text x=\"28.5%\" y=\"91.2%\" font-family=\"Super Sans\" text-anchor=\"start\" style=\"fill:" .. color ..";font-size:15px\">" ..
                    "Handbreak (G) </text>"
    
    svgOut = svgOut .. "</svg>"
    -- control ui elements
    uiBlinkCounter = uiBlinkCounter + 1
    if uiBlinkCounter == 15 then 
        if blink then blink = false else blink = true end
        uiBlinkCounter = 0
    end
    return svgOut
end

function getDistanceDisplayString(distance, places) -- Turn a distance into a string to a number of places
    local su = distance > 100000
    if places == nil then places = 1 end
    if su then
          -- Convert to SU
        return round(distance / 1000 / 200, places).." SU"
    elseif distance < 1000 then
        return round(distance, places).." M"
    else
        -- Convert to KM
        return round(distance / 1000, places).." KM"
    end
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
       return days .. "d " .. hours .."h"
    elseif hours > 0 then
       return hours .. "h " .. minutes .. "m"
    elseif minutes > 0 then
       return minutes .. "m " .. seconds .. "s"
    elseif seconds > 0 then 
       return seconds .. "s"
    else
       return "0s"
    end
 end
return self