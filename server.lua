local searches = {}
local states   = {}

math.randomseed(os.time())

-- ============================================================
-- Name of your economy resource (the one with server.lua that
-- has the AddPlayerMoney export).  Change this if needed.
-- ============================================================
local ECONOMY_RESOURCE = "economy"   -- <-- set to your resource folder name

-- Wrapper so a missing/not-started economy resource never hard-crashes vehsrch
local function addMoney(player, amount)
    local ok, err = pcall(function()
        exports[ECONOMY_RESOURCE]:AddPlayerMoney(player, amount)
    end)
    if not ok then
        print("[vehsrch] WARNING: could not award money – is '" .. ECONOMY_RESOURCE .. "' running? Error: " .. tostring(err))
    end
end

-- ============================================================
-- Helpers
-- ============================================================
local function notify(src, msg)
    TriggerClientEvent("vehsrch:notify", src, msg)
end

local function state(src)
    if not states[src] then
        states[src] = {
            carryingBag      = false,
            carryingEvidence = false,
            storedEvidence   = 0
        }
    end
    return states[src]
end

local function searchKey(netId, plate)
    if netId and netId ~= 0 then return "net:" .. tostring(netId) end
    return "plate:" .. tostring(plate or "UNKNOWN")
end

local function randomItems()
    local count  = math.random(2, 4)
    local result = {}
    local used   = {}

    while #result < count do
        local idx = math.random(1, #Config.Items)
        if not used[idx] then
            used[idx] = true
            local item = Config.Items[idx]
            result[#result + 1] = {
                id      = #result + 1,
                label   = item.label,
                illegal = item.illegal,
                prop    = item.prop,
                visible = true,
                bagged  = false,
                stored  = false
            }
        end
    end

    return result
end

local function sync(searchId)
    TriggerClientEvent("vehsrch:sync", -1, searchId, searches[searchId])
end

-- ============================================================
-- Events
-- ============================================================
AddEventHandler("playerDropped", function()
    states[source] = nil
end)

RegisterNetEvent("vehsrch:requestSync", function()
    local src = source
    TriggerClientEvent("vehsrch:fullSync", src, searches, state(src))
end)

RegisterNetEvent("vehsrch:search", function(netId, coords, plate)
    local src = source
    if type(netId) ~= "number" then return end
    if type(coords) ~= "vector3" then return end

    local id = searchKey(netId, plate)

    if searches[id] and not searches[id].completed then
        notify(src, "Already searched.")
        sync(id)
        return
    end

    searches[id] = {
        netId     = netId,
        coords    = coords,
        plate     = plate or "UNKNOWN",
        completed = false,
        items     = randomItems()
    }

    sync(id)

    local labels = {}
    for _, item in ipairs(searches[id].items) do
        labels[#labels + 1] = item.label .. (item.illegal and " (Illegal)" or "")
    end

    notify(src, "Found: " .. table.concat(labels, ", "))
end)

RegisterNetEvent("vehsrch:grabBag", function()
    local src = source
    local s   = state(src)

    if s.carryingBag or s.carryingEvidence then
        notify(src, "Already carrying something.")
        return
    end

    s.carryingBag = true
    TriggerClientEvent("vehsrch:state", src, s)
end)

RegisterNetEvent("vehsrch:bagItem", function(searchId, itemId)
    local src = source
    local s   = state(src)

    if not s.carryingBag then
        notify(src, "Need an evidence bag.")
        return
    end

    local entry = searches[searchId]
    if not entry or entry.completed then return end

    for _, item in ipairs(entry.items) do
        if item.id == itemId then
            if not item.visible or item.bagged or item.stored then return end

            item.visible         = false
            item.bagged          = true
            s.carryingBag        = false
            s.carryingEvidence   = true

            sync(searchId)
            TriggerClientEvent("vehsrch:state", src, s)
            notify(src, "Bagged " .. item.label .. ".")
            return
        end
    end
end)

RegisterNetEvent("vehsrch:storeEvidence", function(searchId, itemId)
    local src = source
    local s   = state(src)

    if not s.carryingEvidence then return end

    local entry = searches[searchId]
    if not entry or entry.completed then return end

    for _, item in ipairs(entry.items) do
        if item.id == itemId then
            if not item.bagged or item.stored then return end

            item.stored          = true
            s.carryingEvidence   = false
            s.storedEvidence     = s.storedEvidence + 1

            local done = true
            for _, check in ipairs(entry.items) do
                if check.visible or (check.bagged and not check.stored) then
                    done = false
                    break
                end
            end

            if done then entry.completed = true end

            sync(searchId)
            TriggerClientEvent("vehsrch:state", src, s)
            notify(src, "Evidence stored.")
            return
        end
    end
end)

-- ============================================================
-- Turn-in: calculate reward, award money via economy export,
-- notify the player with the breakdown.
-- ============================================================
RegisterNetEvent("vehsrch:turnIn", function()
    local src = source
    local s   = state(src)

    if s.storedEvidence <= 0 then return end

    local count  = s.storedEvidence
    local reward = 0
    for _ = 1, count do
        reward = reward + math.random(Config.RewardMin, Config.RewardMax)
    end

    -- Award the money through the economy resource
    addMoney(src, reward)

    s.storedEvidence = 0
    TriggerClientEvent("vehsrch:state", src, s)

    notify(src, ("Turned in %d evidence bag(s). +$%d added to your balance."):format(count, reward))
end)
