local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "remote" and unitType == "command"
end
self.version = 0.9
self.loadPrio = 1000
self.viewTags = {"hud"}

local u = unit
local s = system
local Atlas -- initialize empty
local listPipes,listNonePvP -- initializing empty local variable as storage space for values

function self:register(env)
	if not self:valid(auth) then return end

    Atlas = getPlugin("atlas",false,"",true)
    listPlanets = {}
    for id,data in pairs(Atlas[0]) do
        if id >= 400 then break end 
        table.insert(listPlanets,{data.name[1], vec3(data.center)})
    end
    listNonePvP = {}
    for id,data in pairs(Atlas[0]) do 
        if id >= 400 then break end 
        table.insert(listNonePvP,{data.name[1], vec3(data.center),500000})
    end
    table.insert(listNonePvP,{"Central Zone", vec3(13771471,7435803,-128971),18000000})
    listPipes = initPipes(listPlanets,false)
    nearestSafeZone(listNonePvP)
    local screener = getPlugin("screener",true)
    if screener ~= nil then
        screener:registerDefaultScreen("mainScreenThird","Pipe")
        screener:registerDefaultScreen("mainScreenFirst","Pipe")
        screener:addView("Pipe",self)
    end
end
function self:setScreen()
    local svgOut = [[
		<style>
			#pipeMain, #pipeMain svg {display:block; position:absolute; top:0; left:0}
			#pipeMain .text {fill:aqua;font-family:Montserrat;font-weight:bold}
		</style>

        <svg id="pipeMain" height="94.5%" width="100%" viewBox=\"0 0 1920 1080\">]]
    -- pipe & safezone
    svgOut = svgOut .. "<g font-family=\"Super Sans\" font-size=\"13px\">"
    .. "<rect x=\"" .. 1.65 .. "%\" y=\"" .. 65.65 .. "%\" rx=\"2\" ry=\"2\" width=\"12%\" height=\"5.2%\" style=\"fill:#4682B4;fill-opacity:0.35\" />"


    local np_name,np_dist = nearestPipe(listPipes)
    local sz_name, sz_dist = distanceSafeZone(nearestSafeZone(listNonePvP))
    if np_name ~= nil then
        if np_dist < 100000 then np_dist = tostring(math.floor(np_dist/10)/100) .. " km" else np_dist = tostring(math.floor(np_dist/1000/2)/100) .. " su" end
        svgOut = svgOut .. "<text x=\"" .. 1.65 + 0.5 .. "%\" y=\"" .. 65.65 + 2 .. "%\" style=\"fill:#FFFFFF\">Pipe " .. string.sub(np_name,0,16) .. "</text>"
                    .. "<text x=\"" .. 1.65 + 8.5 .. "%\" y=\"" .. 65.65 + 2 .. "%\" style=\"fill:#FFFFFF\">" .. np_dist .. "</text>"
    end
    local color
    if sz_dist >= 0 then color = "#00FF00" else color = "#FF0000" end
    if sz_dist < 100000 and sz_dist > -100000 then sz_dist = tostring(math.floor(sz_dist/10)/100) .. " km" else sz_dist = tostring(math.floor(sz_dist/1000/2)/100) .. " su" end
    svgOut = svgOut .. "<text x=\"" .. 1.65 + 0.5 .. "%\" y=\"" .. 65.65 + 4 .. "%\" style=\"fill:#FFFFFF\">Safezone " .. string.sub(sz_name,0,16) .. "</text>"
            .. "<text x=\"" .. 1.65 + 8.5 .. "%\" y=\"" .. 65.65 + 4 .. "%\" style=\"fill:" .. color .. "\">" .. sz_dist .. "</text>"
    
    return svgOut.."</svg>"
end
function initPipes(myPlanets,myChoice)
    local myPipes = {}
    if myChoice then    
        for i = 2,#myPlanets,1 do
            table.insert(myPipes,{myPlanets[1][1] .. " - " .. myPlanets[i][1],myPlanets[1][2],vec3(myPlanets[i][2])-vec3(myPlanets[1][2])})
        end
    else
        for j = 1,#myPlanets-1,1 do
            for i = j+1,#myPlanets,1 do
                table.insert(myPipes,{myPlanets[j][1] .. " - " .. myPlanets[i][1],myPlanets[j][2],vec3(myPlanets[i][2])-vec3(myPlanets[j][2])})			
            end
        end
    end
    return myPipes
end
function nearestPipe(myPipes)
    local myPos = vec3(construct.getWorldPosition())
    local myNewD = 0
    local myOldD = 0
    local myIndex = 0
    for i = 1,#myPipes,1 do
        a = myPipes[i][2] - myPos
        b = myPipes[i][3]
        r = ((-1)*a.x*b.x-a.y*b.y-a.z*b.z)/(b.x*b.x+b.y*b.y+b.z*b.z)       
        l = vec3(myPipes[i][2].x+r*b.x,myPipes[i][2].y+r*b.y,myPipes[i][2].z+r*b.z)
        myNewD = (l - myPos):len()
        if (myOldD == 0 or myNewD < myOldD) and r >= 0 and r <= 1 then 
            myOldD = myNewD
            myIndex = i
        end
    end
    if myIndex == 0 then return end
    return myPipes[myIndex][1], myOldD
end
function nearestSafeZone(myNonePvP)
    local myPos = vec3(construct.getWorldPosition())
    local myOld = 0
    local myI = 0
    local tmp
    
    for i = 1,#myNonePvP,1 do
        tmp = math.abs(vec3(myPos - myNonePvP[i][2]):len()-myNonePvP[i][3])
        if myOld == 0 or tmp < myOld then
            myI = i
            myOld = tmp
        end
    end
    return myNonePvP[myI]
end

function distanceSafeZone(myZone)
    local myPos = vec3(construct.getWorldPosition())
    local myDist = vec3(myPos - myZone[2]):len()
        
    return myZone[1], construct.getDistanceToSafeZone() * -1
end
function self:getSafeZone()
    return contactSafeZone(nearestSafeZone(listNonePvP))
end
function contactSafeZone(myZone)
    local myPos = vec3(construct.getWorldPosition())

    local l = vec3(myPos - myZone[2]):len()
    local r = myZone[3]/l
    local p = myZone[2] + r * vec3(myPos-myZone[2])
    self.nearestSafeZone = p
    return p
end
return self