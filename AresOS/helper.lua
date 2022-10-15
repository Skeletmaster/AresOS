self = {}
function self.TimetoString(seconds) -- Format a time string for display
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
return self