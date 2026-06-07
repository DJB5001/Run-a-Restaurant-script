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
    task.wait(1)

    local things = workspace:FindFirstChild("__THINGS")
    local restaurants = things and things:FindFirstChild("Restaurants")
    if not restaurants then log("FEHLER: kein Restaurants") return end

    -- Restaurant finden via Children-Loop (FindFirstChild schlaegt auf Part fehl)
    local myRestaurant = nil
    for _, r in ipairs(restaurants:GetChildren()) do
        local host = nil
        for _, child in ipairs(r:GetChildren()) do
            if child.Name == "RestaurantBillboardHost" then
                host = child
                break
            end
        end
        if host then
            local ok, name = pcall(function()
                return host.RestaurantBillboard.Frame.PlayerName.Text
            end)
            if ok then
                log(r.Name .. " = '" .. tostring(name) .. "'")
                if name == LocalPlayer.DisplayName then
                    myRestaurant = r
                    log("MATCH: " .. r.Name)
                end
            else
                log(r.Name .. " Billboard FEHLER: " .. tostring(name))
            end
        else
            log(r.Name .. " kein Host")
        end
        task.wait(0.3)
    end

    if not myRestaurant then log("FEHLER: kein Restaurant!") return end
    task.wait(0.5)

    local entities = myRestaurant:FindFirstChild("Entities")
    if not entities then log("FEHLER: kein Entities") return end
    log("Entities: " .. #entities:GetChildren())
    task.wait(0.5)

    -- Network Remote [20]
    local network = ReplicatedStorage:FindFirstChild("Network")
    if not network then log("FEHLER: kein Network") return end
    local children = network:GetChildren()
    log("Network remotes: " .. #children)
    task.wait(0.3)

    for i, child in ipairs(children) do
        warn("[" .. tostring(i) .. "] " .. child.Name .. " | " .. child.ClassName)
        task.wait(0.03)
    end

    local r20 = children[20]
    if r20 then
        log("[20] = " .. r20.Name .. " | " .. r20.ClassName)
    else
        log("FEHLER: [20] ist nil!")
        return
    end
    task.wait(1)

    -- Test Customer TakeOrder
    local cust = nil
    for _, e in ipairs(entities:GetChildren()) do
        local typ = e.Name:match("^(.-)_%x%x%x%x%x%x%x%x") or e.Name
        if typ:match("^Customer%d+$") then cust = e break end
    end
    if not cust then
        log("Kein Customer da")
    else
        local uuid = cust.Name:match("_([0-9a-f%-]+)$")
        log("Customer uuid: " .. tostring(uuid))
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
        log("CashReg uuid: " .. tostring(uuid))
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

    -- Test ActivateStovePlayer
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
        log("Kein Stove gefunden")
    else
        local uuid = stove.Name:match("_([0-9a-f%-]+)$")
        log("Stove: " .. stove.Name)
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
