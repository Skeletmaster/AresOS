local self = {}
local auth = "AQN5B4-@7gSt1W?;"
function self:valid(key)
    if key ~= auth then return false end
    return unitType == "gunner"
end
function self:register(env)
    _ENV = env
	if not self:valid(auth) then return end
    register:addAction("unitOnStart", "WidgetCreate", function() self:CreateWidgets() end)
end

self.version = 0.9
self.loadPrio = 20
local u = unit
local s = system
function self:CreateWidgets()
    self:DestroyWidgets()
    self.DataIDs = {}
    self.Panels = {}
    if #weapon > 0 then
        if #weapon <= 3 then
            local pan = s.createWidgetPanel("")
            self.Panels[#self.Panels + 1] = pan
            for n = 1,#weapon,1 do
                if #self.DataIDs >= #weapon then break end
                local wid = s.createWidget(pan, "weapon")
                local data = weapon[n].getWidgetData()
                table.insert(self.DataIDs, s.createData(data))
                s.addDataToWidget(self.DataIDs[#self.DataIDs], wid)
            end
        else
            local num = math.ceil(#weapon / 2)
            for k = 1,2,1 do
                local pan = s.createWidgetPanel("")
                self.Panels[#self.Panels + 1] = pan
                for n = 1,num,1 do
                    local wid = s.createWidget(pan, "weapon")
                    local data = weapon[#self.DataIDs + 1].getWidgetData()
                    table.insert(self.DataIDs, s.createData(data))
                    s.addDataToWidget(self.DataIDs[#self.DataIDs], wid)
                    if #self.DataIDs >= #weapon then break end
                end
            end
        end
    end

    local radar = radar[1]
    if radar ~= nil then
        local pan = s.createWidgetPanel("")
        self.Panels[#self.Panels + 1] = pan
        local wid = s.createWidget(pan, "radar")
        local data = radar.getWidgetData()
        self.RadarDataID = s.createData(data)
        s.addDataToWidget(self.RadarDataID, wid)
    end
end
function self:DestroyWidgets()
    if self.Panels ~= nil then
        for _,pan in pairs(self.Panels) do
            s.destroyWidgetPanel(pan)
        end
    end
end
return self