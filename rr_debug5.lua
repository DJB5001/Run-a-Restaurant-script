-- rr_debug.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function log(msg)
    warn("[RR] " .. tostring(msg))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "RR DEBUG", Text = tostring(msg), Duration = 6,
        })
    end)
end

task.spawn(function()
    log("Start | " .. LocalPlayer.DisplayName)
    task.wait(2)

    local things = workspace:WaitForChild("__THINGS", 10)
    if not things then log("FEHLER: kein __THINGS") return end

    local restaurants = things:WaitForChild("Restaurants", 10)
    if not restaurants then log("FEHLER: kein Restaurants") return end

    log("Restaurants: " .. #restaurants:GetChildren())
    task.wait(0.5)

    local r1 = restaurants:WaitForChild("Restaurant_1", 10)
    if not r1 then log("FEHLER: kein Restaurant_1") return end
    log("Restaurant_1 gefunden")
    task.wait(0.5)

    -- Children zaehlen und Namen ausgeben
    local childNames = ""
    for _, c in ipairs(r1:GetChildren()) do
        childNames = childNames .. c.Name .. " "
        warn("[C] " .. c.Name .. " | " .. c.ClassName)
    end
    log("Children: " .. childNames)
    task.wait(1)

    -- Mit WaitForChild auf Host warten
    local host = r1:WaitForChild("RestaurantBillboardHost", 10)
    if not host then
        log("FEHLER: Host nicht gefunden nach 10s!")
        return
    end
    log("Host gefunden: " .. host.ClassName)
    task.wait(0.5)

    -- TextLabels im Host
    for _, desc in ipairs(host:GetDescendants()) do
        if desc.ClassName == "TextLabel" then
            warn("[TL] " .. desc.Name .. " = '" .. tostring(desc.Text) .. "'")
            log(desc.Name .. "='" .. tostring(desc.Text) .. "'")
            task.wait(0.2)
        end
    end

    log("DisplayName='" .. LocalPlayer.DisplayName .. "'")
    task.wait(0.5)

    -- Network
    local network = ReplicatedStorage:WaitForChild("Network", 10)
    if not network then log("FEHLER: kein Network") return end
    local ch = network:GetChildren()
    log("Network: " .. #ch .. " remotes")
    task.wait(0.3)
    for i, c in ipairs(ch) do
        warn("[" .. tostring(i) .. "] " .. c.Name .. " | " .. c.ClassName)
        task.wait(0.02)
    end
    local r20 = ch[20]
    if r20 then
        log("[20]=" .. r20.Name .. " " .. r20.ClassName)
    else
        log("FEHLER: [20] nil")
    end

    log("FERTIG")
end)
