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

    -- Exakten Namen + Byte-Werte des BillboardHost ausgeben
    for _, child in ipairs(r1:GetChildren()) do
        if child.Name:find("Billboard") or child.Name:find("billboard") then
            local bytes = ""
            for i = 1, #child.Name do
                bytes = bytes .. tostring(string.byte(child.Name, i)) .. " "
            end
            warn("[BYTES] '" .. child.Name .. "' = " .. bytes)
            log("Host Name Bytes: " .. bytes)
        end
    end
    task.wait(1)

    -- Direkt per Index auf Children zugreifen
    local host = nil
    for _, child in ipairs(r1:GetChildren()) do
        if child.Name:sub(1, 10) == "Restaurant" and child.ClassName == "Part" then
            host = child
            log("Host via loop: " .. child.Name)
            break
        end
    end

    if not host then
        log("Host immer noch nicht gefunden")
        return
    end
    task.wait(0.5)

    -- Alle TextLabels im Host
    log("Alle TextLabels im Host:")
    for _, desc in ipairs(host:GetDescendants()) do
        if desc.ClassName == "TextLabel" then
            warn("[TL] " .. desc.Name .. " = '" .. tostring(desc.Text) .. "'")
            log(desc.Name .. " = '" .. tostring(desc.Text) .. "'")
            task.wait(0.3)
        end
    end

    log("DisplayName = '" .. LocalPlayer.DisplayName .. "'")
    log("FERTIG")
end)
