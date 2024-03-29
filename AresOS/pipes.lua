local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "remote" or unitType == "command"
end
self.version = 0.91
self.loadPrio = 1000
self.viewTags = {"hud"}

local u = unit
local s = system
local listPipes,listNonePvP,nearestPipe,nearestSafeZone,distanceSafeZone,contactSafeZone,locationhandler,screener -- initializing empty local variable as storage space for values

function self:register(env)
	if not self:valid(auth) then return end
    locationhandler = getPlugin("locationhandler",false,auth)
    Atlas = getPlugin("atlas",false,"",true)
    listPipes = locationhandler:getPipes()
    listNonePvP = locationhandler:getSafeZones()
    nearestSafeZone(listNonePvP)

    local screener = getPlugin("screener",true)
    if screener ~= nil then
        screener:registerDefaultScreen("mainScreenThird","Pipes")
        screener:registerDefaultScreen("mainScreenFirst","Pipes")
        screener:addView("Pipes",self)
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
        svgOut = svgOut .. "<text x=\"" .. 1.65 + 0.5 .. "%\" y=\"" .. 65.65 + 2 .. "%\" style=\"fill:#FFFFFF;font-size:10px\">Pipe " .. np_name .. "</text>"
                    .. "<text x=\"" .. 1.65 + 8.5 .. "%\" y=\"" .. 65.65 + 2 .. "%\" style=\"fill:#FFFFFF;font-size:13px\">" .. np_dist .. "</text>"
    end
    local color
    if sz_dist >= 0 then color = "#00FF00" else color = "#FF0000" end
    if sz_dist < 100000 and sz_dist > -100000 then sz_dist = tostring(math.floor(sz_dist/10)/100) .. " km" else sz_dist = tostring(math.floor(sz_dist/1000/2)/100) .. " su" end
    svgOut = svgOut .. "<text x=\"" .. 1.65 + 0.5 .. "%\" y=\"" .. 65.65 + 4 .. "%\" style=\"fill:#FFFFFF;font-size:10px\">Safezone " .. string.sub(sz_name,0,16) .. "</text>"
            .. "<text x=\"" .. 1.65 + 8.5 .. "%\" y=\"" .. 65.65 + 4 .. "%\" style=\"fill:" .. color .. ";font-size:13px\">" .. sz_dist .. "</text>"
    
    return svgOut.."</svg>"
end

function nearestPipe(myPipes)
    local myPos = vec3(construct.getWorldPosition())
    local myNewD = 0
    local myOldD = 0
    local myIndex = 0
    self.pipePoint = nil
    local closestPoint = vec3()
    for i = 1,#myPipes,1 do
        local a = myPipes[i][2] - myPos
        local b = myPipes[i][3]
        local r = ((-1)*a.x*b.x-a.y*b.y-a.z*b.z)/(b.x*b.x+b.y*b.y+b.z*b.z)       
        local l = vec3(myPipes[i][2].x+r*b.x,myPipes[i][2].y+r*b.y,myPipes[i][2].z+r*b.z)
        local myNewD = (l - myPos):len()
        if (myOldD == 0 or myNewD < myOldD) and r >= 0 and r <= 1 then 
            myOldD = myNewD
            myIndex = i
            closestPoint = l
        end
    end
    if myIndex == 0 then return end
    self.pipePoint = closestPoint
    return myPipes[myIndex][1], myOldD
end
function nearestSafeZone(myNonePvP)
    local myPos = vec3(construct.getWorldPosition())
    local myOld = 0
    local myI = 0
    local tmp
    for i = 1,#myNonePvP,1 do
        tmp = math.abs((myPos - myNonePvP[i].pos):len()-myNonePvP[i].range)
        if myOld == 0 or tmp < myOld then
            myI = i
            myOld = tmp
        end
    end
    return myNonePvP[myI]
end

function distanceSafeZone(myZone)        
    return myZone.name, construct.getDistanceToSafeZone() * -1
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