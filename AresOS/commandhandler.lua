local self = {}
local prefixList = {"/","!"}
function self:register(env)
    _ENV = env
    if unitType == "gunner" then
        self.prefix = "/"
    elseif unitType == "remote" then
        self.prefix = "!"
    else
        self.prefix = "/"
    end
    CommandList = {
        {
            [self.prefix] = {
                {
                    ["help"] = function (input)
                        local str = input[2]
                        if str == nil then 
                            for k,v in pairs(CommandList[1][self.prefix][2]) do
                                print(k .. ":  " .. v)
                            end
                        end
                    end,
                },
                {
                    ["help"] = "use this to list all commands",
                }
            },
        },
        {
            [self.prefix] = "basic commands from the" .. unitType or "",
        }
    }
    local function commandhandler(oritext)
        text = string.lower(oritext)
        local prefix = string.sub(text,1,1)
        if prefix == self.prefix then  
            local command = mysplit(string.sub(text,2,#text))
            local a,error = pcall(CommandList[1][prefix][1][command[1]], command,oritext)
            if not a then print(error) end
        elseif inTable(prefixList,prefix)  then
        
        elseif #text == 3 then
            commandhandler("/t " .. text)
        else
            if unitType == "gunner" then
                print(oritext)
            end
        end
    end
    register:addAction("systemOnInputText", "commandhandler", commandhandler)
end
self.version = 0.9
self.loadPrio = 5

function self:AddCommand(name,func,desc)
    CommandList[1][self.prefix][1][name] = func
    CommandList[1][self.prefix][2][name] = desc or ""
end
return self
