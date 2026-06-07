-- rr_debug2.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function log(msg)
    warn("[RR2] " .. tostring(msg))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "RR2", Text = tostring(msg), Duration = 8,
        })
    end)
end

task.spawn(function()
    local things = workspace:FindFirstChild("__THINGS")
    local restaurants = things and things:FindFirstChild("Restaurants")
    if not restaurants then log("kein Restaurants") return end

    local r1 = restaurants:GetChildren()[1]
    if not r1 then log("kein Restaurant") return end
    log("Restaurant: " .. r1.Name)
    task.wait(0.5)

    -- Alle TextLabels in descendants finden und Text ausgeben
    log("Suche alle TextLabels...")
    for _, desc in ipairs(r1:GetDescendants()) do
        if desc.ClassName == "TextLabel" then
            warn("[TL] " .. desc:GetFullName() .. " = '" .. tostring(desc.Text) .. "'")
        end
    end
    task.wait(1)

    -- Direkter Zugriff testen
    log("Teste direkten Zugriff...")
    local ok1, v1 = pcall(function()
        return r1.RestaurantBillboardHost.RestaurantBillboard.Frame.PlayerName.Text
    end)
    log("Dot-Access: ok=" .. tostring(ok1) .. " val=" .. tostring(v1))
    task.wait(0.5)

    -- Mit WaitForChild testen
    local ok2, v2 = pcall(function()
        local host = r1:WaitForChild("RestaurantBillboardHost", 3)
        local billboard = host:WaitForChild("RestaurantBillboard", 3)
        local frame = billboard:WaitForChild("Frame", 3)
        local playerName = frame:WaitForChild("PlayerName", 3)
        return playerName.Text
    end)
    log("WaitForChild: ok=" .. tostring(ok2) .. " val=" .. tostring(v2))
    task.wait(0.5)

    log("DisplayName ist: '" .. LocalPlayer.DisplayName .. "'")
    log("FERTIG")
end)
