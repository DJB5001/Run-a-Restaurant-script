-- rr_debug.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function log(msg)
    warn("[RR] " .. tostring(msg))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "RR", Text = tostring(msg), Duration = 6,
        })
    end)
end

task.spawn(function()
    log("Start | " .. LocalPlayer.DisplayName)
    task.wait(3) -- laenger warten damit alles geladen ist

    local restaurants = workspace.__THINGS.Restaurants
    log("Restaurants: " .. #restaurants:GetChildren())
    task.wait(0.5)

    -- Alle Restaurants durchgehen
    local myRestaurant = nil
    for _, r in ipairs(restaurants:GetChildren()) do
        log("Pruefe: " .. r.Name)
        task.wait(0.2)

        -- Alle descendants nach PlayerName TextLabel suchen
        for _, desc in ipairs(r:GetDescendants()) do
            if desc.Name == "PlayerName" and desc.ClassName == "TextLabel" then
                warn("[FOUND] " .. r.Name .. " PlayerName='" .. tostring(desc.Text) .. "'")
                log(r.Name .. " PlayerName='" .. tostring(desc.Text) .. "'")
                if desc.Text == LocalPlayer.DisplayName then
                    myRestaurant = r
                    log("MATCH: " .. r.Name)
                end
                break
            end
        end
        task.wait(0.2)
    end

    if not myRestaurant then
        log("FEHLER: kein Restaurant gefunden!")
        return
    end
    task.wait(0.5)

    -- Entities
    local entities = myRestaurant:FindFirstChild("Entities")
    if not entities then log("FEHLER: kein Entities") return end
    log("Entities: " .. #entities:GetChildren())
    task.wait(0.5)

    -- Typen ausgeben
    local typeCounts = {}
    for _, e in ipairs(entities:GetChildren()) do
        local typ = e.Name:match("^(.-)_%x%x%x%x%x%x%x%x") or e.Name
        typeCounts[typ] = (typeCounts[typ] or 0) + 1
    end
    for typ, count in pairs(typeCounts) do
        warn("[ENTITY] " .. typ .. " x" .. tostring(count))
        task.wait(0.05)
    end
    log("Entity-Typen in warn ausgegeben")
    task.wait(1)

    -- Network [20]
    local net = ReplicatedStorage:FindFirstChild("Network")
    if not net then log("kein Network") return end
    local ch = net:GetChildren()
    log("Network: " .. #ch .. " remotes")
    task.wait(0.3)
    for i, c in ipairs(ch) do
        warn("[" .. tostring(i) .. "] " .. c.Name .. " | " .. c.ClassName)
        task.wait(0.02)
    end
    local r20 = ch[20]
    if r20 then
        log("[20]=" .. r20.Name .. " | " .. r20.ClassName)
    else
        log("FEHLER: [20] nil!")
        return
    end
    task.wait(1)

    -- Test TakeOrder
    local cust = nil
    for _, e in ipairs(entities:GetChildren()) do
        local typ = e.Name:match("^(.-)_%x%x%x%x%x%x%x%x") or e.Name
        if typ:match("^Customer%d+$") then cust = e break end
    end
    if not cust then
        log("Kein Customer")
    else
        local uuid = cust.Name:match("_([0-9a-f%-]+)$")
        log("TakeOrder test uuid=" .. tostring(uuid))
        task.wait(0.3)
        local ok, res = pcall(function()
            if r20.ClassName == "RemoteFunction" then
                return r20:InvokeServer(uuid, "TakeOrder")
            else
                r20:FireServer(uuid, "TakeOrder")
                return "fired"
            end
        end)
        log("TakeOrder ok=" .. tostring(ok) .. " res=" .. tostring(res))
    end
    task.wait(1)

    -- Test CashRegisterClaim
    local cash = nil
    for _, e in ipairs(entities:GetChildren()) do
        local typ = e.Name:match("^(.-)_%x%x%x%x%x%x%x%x") or e.Name
        if typ == "Cash Register" then cash = e break end
    end
    if not cash then
        log("Keine Cash Register")
    else
        local uuid = cash.Name:match("_([0-9a-f%-]+)$")
        log("CashReg uuid=" .. tostring(uuid))
        task.wait(0.3)
        local ok, res = pcall(function()
            if r20.ClassName == "RemoteFunction" then
                return r20:InvokeServer(uuid, "CashRegisterClaim")
            else
                r20:FireServer(uuid, "CashRegisterClaim")
                return "fired"
            end
        end)
        log("CashRegisterClaim ok=" .. tostring(ok) .. " res=" .. tostring(res))
    end
    task.wait(1)

    -- Test Stove
    local stoveTypes = {"Rusty Stove","Basic Stove","Retro Stove","Modern Stove","Professional Stove","Industrial Stove","Golden Stove","Carbon Industrial Stove"}
    local stove = nil
    for _, e in ipairs(entities:GetChildren()) do
        local typ = e.Name:match("^(.-)_%x%x%x%x%x%x%x%x") or e.Name
        for _, st in ipairs(stoveTypes) do
            if typ == st then stove = e break end
        end
        if stove then break end
    end
    if not stove then
        log("Kein Stove")
    else
        local uuid = stove.Name:match("_([0-9a-f%-]+)$")
        log("Stove=" .. stove.Name)
        task.wait(0.3)
        local ok, res = pcall(function()
            if r20.ClassName == "RemoteFunction" then
                return r20:InvokeServer(uuid, "ActivateStovePlayer")
            else
                r20:FireServer(uuid, "ActivateStovePlayer")
                return "fired"
            end
        end)
        log("ActivateStovePlayer ok=" .. tostring(ok) .. " res=" .. tostring(res))
    end

    task.wait(0.5)
    log("FERTIG!")
end)
