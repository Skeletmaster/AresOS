local self = {}
--three letter ship code----------------
local kSkipCharSet = {["O"] = true, ["Q"] = true, ["0"] = true}
local kCharSet = {}
self.version = 0.9
self.loadPrio = 20

local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "gunner"
end

function addRangeToCharSet(a, b)
    for i=a,b do
        local c = string.char(i)
        if not kSkipCharSet[c] then
            kCharSet[#kCharSet+1] = c
        end
    end
end

-- 0 - 9
addRangeToCharSet(48, 57)
-- A - Z
addRangeToCharSet(65, 90)

local kCharSetSize = #kCharSet

function getHash(x)
    x = ((x >> 16) ~ x) * 0x45d9f3b
    x = ((x >> 16) ~ x) * 0x45d9f3b
    x = (x >> 16) ~ x
    if x < 0 then x = ~x end
    return x
end

function self:getShortName(id)
    local id = tonumber(id)
    if id == nil then return "" end
    local seed = getHash(id)%8388593
    local a = (seed*653276)%8388593
    local b = (a*653276)%8388593
    local c = (b*653276)%8388593
    return kCharSet[a%kCharSetSize+1] .. kCharSet[b%kCharSetSize+1] .. kCharSet[c%kCharSetSize+1]
end

return self
