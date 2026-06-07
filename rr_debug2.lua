-- rr_debug2.lua  – findet den echten Billboard-Pfad
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

    -- Alle direkten Children listen
    log("=== Direct Children ===")
    for _, child in ipairs(r1:GetChildren()) do
        warn("[CHILD] " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    task.wait(1)

    -- BillboardHost suchen
    local host = r1:FindFirstChild("RestaurantBillboardHost")
    if not host then
        log("kein RestaurantBillboardHost!")
        -- Alle descendants mit Billboard im Namen suchen
        log("Suche Billboard in descendants...")
        for _, desc in ipairs(r1:GetDescendants()) do
            if desc.Name:lower():find("billboard") or desc.Name:lower():find("player") then
                warn("[DESC] " .. desc:GetFullName() .. " (" .. desc.ClassName .. ")")
            end
        end
        return
    end
    log("Host gefunden!")
    task.wait(0.5)

    -- Alle descendants vom Host listen
    log("=== Host Descendants ===")
    for _, desc in ipairs(host:GetDescendants()) do
        warn("[DESC] " .. desc:GetFullName() .. " (" .. desc.ClassName .. ")" .. (desc.ClassName == "TextLabel" and (" TEXT='" .. tostring(desc.Text) .. "'") or ""))
        task.wait(0.02)
    end

    log("FERTIG - schau in warn!")
end)
