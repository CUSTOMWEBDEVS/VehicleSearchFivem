local searches = {}
local spawned = {}
local markedSupply = {}
local driven = {}
local blips = {}

local carryingBag = false
local carryingEvidence = false
local storedEvidence = 0
local activeCarry = nil
local carryObj = nil

local busy = false
local promptText = nil
local promptExpire = 0

local function notify(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(tostring(msg or ""))
    DrawNotification(false, false)
end

local function cleanText(text)
    text = tostring(text or "")
    text = text:gsub("~INPUT_CONTEXT~", "E")
    text = text:gsub("~.-~", "")
    return text
end

local function prompt(msg)
    promptText = cleanText(msg)
    promptExpire = GetGameTimer() + 250
end

local function drawPrompt()
    if not promptText or GetGameTimer() > promptExpire then return end

    local text = promptText

    local x, y = 0.5, 0.915

    SetTextFont(4)
    SetTextScale(0.36, 0.36)
    SetTextColour(255, 255, 255, 230)
    SetTextCentre(true)
    SetTextDropShadow(1, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function loadModel(model)
    if type(model) == "string" then model = joaat(model) end
    if not IsModelInCdimage(model) then return false end

    RequestModel(model)
    local timeout = GetGameTimer() + 4000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end

    return HasModelLoaded(model)
end

local function doProgress(ms, text)
    if busy then return false end
    busy = true

    local ped = PlayerPedId()
    local dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
    local anim = "machinic_loop_mechandplayer"

    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 1500
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        Wait(10)
    end

    if HasAnimDictLoaded(dict) then
        TaskPlayAnim(ped, dict, anim, 2.0, 2.0, -1, 49, 0.0, false, false, false)
    end

    local start = GetGameTimer()
    while GetGameTimer() - start < ms do
        Wait(0)
        if IsEntityDead(ped) or IsPedRagdoll(ped) or IsPedInAnyVehicle(ped, false) then
            break
        end
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 22, true)
        DisableControlAction(0, 23, true)
        DisableControlAction(0, 75, true)
        prompt(text)
        drawPrompt()
    end

    StopAnimTask(ped, dict, anim, 1.0)
    ClearPedSecondaryTask(ped)
    ClearPedTasks(ped)

    busy = false
    return true
end

local function plate(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return "" end
    return (GetVehicleNumberPlateText(vehicle) or ""):gsub("%s+", ""):upper()
end

local function key(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
    local net = VehToNet(vehicle)
    if net and net ~= 0 then return "net:" .. tostring(net) end
    return "plate:" .. plate(vehicle)
end

local function nearestVehicle(radius)
    local ped = PlayerPedId()
    local pc = GetEntityCoords(ped)
    local best, bestDist = 0, radius or Config.VehicleScanRadius

    for _, vehicle in ipairs(GetGamePool("CVehicle")) do
        if DoesEntityExist(vehicle) then
            local d = #(pc - GetEntityCoords(vehicle))
            if d < bestDist then
                best = vehicle
                bestDist = d
            end
        end
    end

    return best, bestDist
end

local function hasPlayerInside(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    -- Safer than GetVehicleModelNumberOfSeats, which is missing on some FiveM builds.
    -- Checks common GTA vehicle seats: driver, passenger, rear seats, plus a few extras.
    for seat = -1, 7 do
        local ped = GetPedInVehicleSeat(vehicle, seat)
        if ped ~= 0 and DoesEntityExist(ped) and IsPedAPlayer(ped) then
            return true
        end
    end

    return false
end

local function isSupplyVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    local k = key(vehicle)
    if k and markedSupply[k] then return true end
    if Config.EmergencyVehiclesAreSupply and GetVehicleClass(vehicle) == 18 then return true end
    if Config.PlayerDrivenVehiclesAreSupply and k and driven[k] then return true end

    local p = plate(vehicle)
    for _, prefix in ipairs(Config.PlatePrefixesAreSupply) do
        prefix = prefix:upper()
        if p:sub(1, #prefix) == prefix then return true end
    end

    return false
end

local function canSearchVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false, "No vehicle close enough." end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return false, "Get out first." end
    if hasPlayerInside(vehicle) then return false, "Cannot search player occupied vehicle." end
    if isSupplyVehicle(vehicle) then return false, "Cannot search your supply vehicle." end
    if Config.BlockedSearchClasses[GetVehicleClass(vehicle)] then return false, "Cannot search that vehicle type." end
    return true, nil
end

local function trunkPos(vehicle)
    local minDim = GetModelDimensions(GetEntityModel(vehicle))
    local pos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, minDim.y - 0.45, 0.0)
    return vector3(pos.x, pos.y, pos.z + 0.35)
end

local function openDoors(vehicle)
    if vehicle == 0 then return end
    SetVehicleDoorOpen(vehicle, 0, false, false)
    SetVehicleDoorOpen(vehicle, 1, false, false)
    SetVehicleDoorOpen(vehicle, 2, false, false)
    SetVehicleDoorOpen(vehicle, 3, false, false)
    SetVehicleDoorOpen(vehicle, 5, false, false)
end

local function closeDoors(vehicle)
    if vehicle == 0 then return end
    for i = 0, 5 do SetVehicleDoorShut(vehicle, i, false) end
end

local function removeCarryProp()
    if carryObj and DoesEntityExist(carryObj) then DeleteObject(carryObj) end
    carryObj = nil
end

local function refreshCarryProp()
    removeCarryProp()

    if not carryingBag and not carryingEvidence then return end
    if not loadModel(`prop_evidence_bag_01`) then return end

    local ped = PlayerPedId()
    carryObj = CreateObject(`prop_evidence_bag_01`, 0.0, 0.0, 0.0, true, true, false)
    SetEntityAsMissionEntity(carryObj, true, true)
    AttachEntityToEntity(
        carryObj,
        ped,
        GetPedBoneIndex(ped, 57005),
        0.14, 0.02, -0.02,
        -90.0, 180.0, 80.0,
        true, true, false, true, 1, true
    )
end

local function itemOffset(i)
    local offsets = {
        vector3(0.70, -1.00, -0.75),
        vector3(-0.70, -1.00, -0.75),
        vector3(0.45, -0.20, -0.75),
        vector3(-0.45, -0.20, -0.75)
    }
    return offsets[i] or vector3(0.25 * i, -0.80, -0.75)
end

local function deleteSpawn(searchKey, itemId)
    if spawned[searchKey] and spawned[searchKey][itemId] then
        local obj = spawned[searchKey][itemId]
        if DoesEntityExist(obj) then DeleteObject(obj) end
        spawned[searchKey][itemId] = nil
    end
end

local function spawnItem(searchKey, data, item, index)
    spawned[searchKey] = spawned[searchKey] or {}
    deleteSpawn(searchKey, item.id)

    if not item.visible then return end
    if not loadModel(item.prop) then return end

    local vehicle = NetToVeh(data.netId)
    local coords
    if vehicle ~= 0 and DoesEntityExist(vehicle) then
        local off = itemOffset(index)
        coords = GetOffsetFromEntityInWorldCoords(vehicle, off.x, off.y, off.z)
    else
        coords = vector3(data.coords.x + (index * 0.35), data.coords.y, data.coords.z)
    end

    local obj = CreateObject(item.prop, coords.x, coords.y, coords.z, false, false, false)
    SetEntityAsMissionEntity(obj, true, true)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    spawned[searchKey][item.id] = obj
end

local function syncSearch(searchKey, data)
    searches[searchKey] = data
    spawned[searchKey] = spawned[searchKey] or {}

    for itemId, obj in pairs(spawned[searchKey]) do
        if DoesEntityExist(obj) then DeleteObject(obj) end
        spawned[searchKey][itemId] = nil
    end

    for i, item in ipairs(data.items or {}) do
        spawnItem(searchKey, data, item, i)
    end
end

local function searchVehicle()
    local vehicle = nearestVehicle(Config.VehicleScanRadius)
    local ok, err = canSearchVehicle(vehicle)
    if not ok then notify(err) return end

    local ped = PlayerPedId()
    if #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) > Config.SearchDistance then
        notify("Move closer to the vehicle.")
        return
    end

    openDoors(vehicle)
    local complete = doProgress(Config.SearchTime, "Searching vehicle...")
    SetTimeout(1200, function() closeDoors(vehicle) end)

    if complete then
        TriggerServerEvent("vehsrch:search", VehToNet(vehicle), GetEntityCoords(vehicle), plate(vehicle))
    end
end

local function markVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then vehicle = nearestVehicle(3.0) end
    if vehicle == 0 or not DoesEntityExist(vehicle) then notify("No vehicle to mark.") return end

    local k = key(vehicle)
    if not k then notify("Could not identify vehicle.") return end

    markedSupply[k] = not markedSupply[k]
    if markedSupply[k] then
        notify("Evidence vehicle marked.")
    else
        notify("Evidence vehicle unmarked.")
    end
end

local function createBlips()
    for _, b in ipairs(blips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end

    blips = {}
    for i, station in ipairs(Config.Stations) do
        local c = station.coords
        local b = AddBlipForCoord(c.x, c.y, c.z)
        SetBlipSprite(b, 478)
        SetBlipScale(b, 0.75)
        SetBlipColour(b, 3)
        SetBlipAsShortRange(b, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(station.name)
        EndTextCommandSetBlipName(b)
        blips[i] = b
    end
end

local function nearStation()
    local pc = GetEntityCoords(PlayerPedId())
    for _, station in ipairs(Config.Stations) do
        local c = station.coords
        local d = #(pc - c)

        if d < 22.0 then
            DrawMarker(1, c.x, c.y, c.z - 0.95, 0,0,0, 0,0,0, 1.6,1.6,0.55, 0,120,255,125, false,false,2,false,nil,nil,false)
        end

        if d < Config.StationDistance then return true, c end
    end

    return false, nil
end


RegisterCommand("vs_stationcoords", function(_, args)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local name = table.concat(args or {}, " ")
    if name == nil or name == "" then
        name = "Evidence Drop-Off"
    end

    local line = ('{ name = "%s", coords = vector3(%.2f, %.2f, %.2f) },'):format(
        name,
        coords.x,
        coords.y,
        coords.z
    )

    print("^2[vehsrch] Copy this into Config.Stations:^7")
    print(line)
    notify("Station coordinate printed to F8 console.")
end, false)

RegisterCommand("vs_showstations", function()
    notify("Evidence station markers are enabled. Check map blips and blue ground markers.")
end, false)

RegisterCommand(Config.SearchCommand, searchVehicle, false)
RegisterCommand(Config.MarkCommand, markVehicle, false)
RegisterKeyMapping(Config.SearchCommand, "Search NPC vehicle", "keyboard", Config.DefaultSearchKey)
RegisterKeyMapping(Config.MarkCommand, "Mark evidence vehicle", "keyboard", Config.DefaultMarkKey)

RegisterCommand("vs_clear", function()
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)
    busy = false
    notify("Cleared.")
end, false)

RegisterNetEvent("vehsrch:notify", notify)

RegisterNetEvent("vehsrch:fullSync", function(all, state)
    searches = all or {}

    for _, items in pairs(spawned) do
        for _, obj in pairs(items) do
            if DoesEntityExist(obj) then DeleteObject(obj) end
        end
    end
    spawned = {}

    for searchKey, data in pairs(searches) do
        syncSearch(searchKey, data)
    end

    carryingBag = state and state.carryingBag or false
    carryingEvidence = state and state.carryingEvidence or false
    storedEvidence = state and state.storedEvidence or 0
    if not carryingEvidence then activeCarry = nil end
    refreshCarryProp()
end)

RegisterNetEvent("vehsrch:sync", function(searchKey, data)
    syncSearch(searchKey, data)
end)

RegisterNetEvent("vehsrch:state", function(state)
    carryingBag = state.carryingBag
    carryingEvidence = state.carryingEvidence
    storedEvidence = state.storedEvidence
    if not carryingEvidence then activeCarry = nil end
    refreshCarryProp()
end)

CreateThread(function()
    Wait(1000)
    createBlips()
    TriggerServerEvent("vehsrch:requestSync")
end)

CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local k = key(vehicle)
            if k then driven[k] = true end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        drawPrompt()

        local ped = PlayerPedId()
        local pc = GetEntityCoords(ped)
        local vehicle = nearestVehicle(Config.VehicleScanRadius)

        -- Supply vehicle trunk actions
        if vehicle ~= 0 and DoesEntityExist(vehicle) and isSupplyVehicle(vehicle) then
            local tp = trunkPos(vehicle)
            local d = #(pc - tp)

            if d < Config.TrunkDistance then
                if not carryingBag and not carryingEvidence then
                    prompt("E - Grab evidence bag")
                    if IsControlJustReleased(0, Config.InteractControl) then
                        if doProgress(Config.GrabBagTime, "Grabbing bag...") then
                            TriggerServerEvent("vehsrch:grabBag")
                        end
                    end
                elseif carryingEvidence and activeCarry then
                    prompt("E - Store evidence")
                    if IsControlJustReleased(0, Config.InteractControl) then
                        if doProgress(Config.StoreBagTime, "Storing evidence...") then
                            TriggerServerEvent("vehsrch:storeEvidence", activeCarry.searchKey, activeCarry.itemId)
                        end
                    end
                end
            end
        end

        -- Evidence item actions
        for searchKey, data in pairs(searches) do
            if not data.completed then
                for _, item in ipairs(data.items or {}) do
                    local obj = spawned[searchKey] and spawned[searchKey][item.id]
                    if item.visible and obj and DoesEntityExist(obj) then
                        local oc = GetEntityCoords(obj)
                        local d = #(pc - oc)

                        if d < 8.0 then
                            local r, g, b = 240, 240, 240
                            if item.illegal then r, g, b = 255, 60, 60 end
                            DrawMarker(2, oc.x, oc.y, oc.z + 0.25, 0,0,0, 0,0,0, 0.16,0.16,0.16, r,g,b,155, false,true,2,false,nil,nil,false)
                        end

                        if d < Config.ItemDistance then
                            if carryingBag then
                                prompt("E - Bag " .. item.label)
                                if IsControlJustReleased(0, Config.InteractControl) then
                                    if doProgress(Config.BagItemTime, "Bagging evidence...") then
                                        activeCarry = { searchKey = searchKey, itemId = item.id }
                                        TriggerServerEvent("vehsrch:bagItem", searchKey, item.id)
                                    end
                                end
                            elseif not carryingEvidence then
                                prompt(item.label .. (item.illegal and " - Illegal" or ""))
                            else
                                prompt("Store current evidence first")
                            end
                        end
                    end
                end
            end
        end

        local isNearStation, stationCoords = nearStation()
        if isNearStation and storedEvidence > 0 then
            prompt("E - Turn in evidence")
            if IsControlJustReleased(0, Config.InteractControl) then
                if doProgress(Config.TurnInTime, "Turning in evidence...") then
                    TriggerServerEvent("vehsrch:turnIn")
                end
            end
        end
    end
end)

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    removeCarryProp()

    for _, items in pairs(spawned) do
        for _, obj in pairs(items) do
            if DoesEntityExist(obj) then DeleteObject(obj) end
        end
    end

    for _, b in ipairs(blips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end
end)
