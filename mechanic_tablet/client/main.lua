local state = {
    framework = 'open',
    nuiReady = false,
    uiOpen = false
}

local frameworkCache = {
    esx = nil,
    qb = nil,
    ox = nil
}

local function notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

local function trimName(name)
    if not name or name == '' then return 'Unknown' end
    return name
end

local function getOpenPlayerName()
    if frameworkCache.ox and frameworkCache.ox.getName then
        local ok, name = pcall(frameworkCache.ox.getName)
        if ok and name then
            return trimName(name)
        end
    end

    local playerName = GetPlayerName(PlayerId())
    if playerName and playerName ~= '' then
        return trimName(playerName)
    end

    return nil
end

local function getPlayerDisplayName()
    local serverId = GetPlayerServerId(PlayerId())
    local fallback = ('Mechanic #%s'):format(serverId)

    if state.framework == 'esx' and frameworkCache.esx then
        local data = frameworkCache.esx.GetPlayerData()
        if data and data.firstName and data.lastName then
            return trimName((data.firstName .. ' ' .. data.lastName))
        end
        if data and data.name then
            return trimName(data.name)
        end
    end

    if state.framework == 'qbcore' and frameworkCache.qb then
        local data = frameworkCache.qb.Functions.GetPlayerData()
        if data and data.charinfo then
            local first = data.charinfo.firstname or ''
            local last = data.charinfo.lastname or ''
            return trimName((first .. ' ' .. last):gsub('^%s*(.-)%s*$', '%1'))
        end
        if data and data.name then
            return trimName(data.name)
        end
    end

    local openName = getOpenPlayerName()
    if openName then
        return openName
    end

    return fallback
end

local function getVehicleInFront(distance)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local target = GetOffsetFromEntityInWorldCoords(ped, 0.0, distance, 0.0)
    local ray = StartShapeTestCapsule(coords.x, coords.y, coords.z, target.x, target.y, target.z, 2.0, 10, ped, 7)
    local _, hit, _, _, entityHit = GetShapeTestResult(ray)

    if hit == 1 and entityHit and DoesEntityExist(entityHit) and IsEntityAVehicle(entityHit) then
        return entityHit
    end

    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 70)
    if vehicle ~= 0 and DoesEntityExist(vehicle) then
        return vehicle
    end

    return nil
end

local function getVehicleSnapshot(vehicle)
    if not vehicle then
        return nil
    end

    local body = math.floor(GetVehicleBodyHealth(vehicle))
    local engine = math.floor(GetVehicleEngineHealth(vehicle))
    local dirt = math.floor(GetVehicleDirtLevel(vehicle) * 10.0)
    local fuel = GetVehicleFuelLevel(vehicle)

    return {
        plate = GetVehicleNumberPlateText(vehicle),
        model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),
        body = body,
        engine = engine,
        dirt = dirt,
        fuel = math.floor(fuel + 0.5),
        netId = VehToNet(vehicle)
    }
end

local function isAllowedJob(jobName)
    local allowed = Config.AllowedJobs[state.framework] or Config.AllowedJobs.open
    for i = 1, #allowed do
        if allowed[i] == jobName then
            return true
        end
    end
    return false
end

local function detectFramework()
    local forced = Config.Framework
    if forced == 'basic' then
        forced = 'open'
    end

    if forced ~= 'auto' then
        state.framework = forced
        return
    end

    if GetResourceState('es_extended') == 'started' then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and obj then
            frameworkCache.esx = obj
            state.framework = 'esx'
            return
        end
    end

    if GetResourceState('qb-core') == 'started' then
        local ok, obj = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and obj then
            frameworkCache.qb = obj
            state.framework = 'qbcore'
            return
        end
    end

    if GetResourceState('ox_core') == 'started' then
        local ok, oxPlayer = pcall(function()
            return OxPlayer
        end)
        if ok then
            frameworkCache.ox = oxPlayer
        end
    end

    state.framework = 'open'
end

local function getCurrentJobName()
    if state.framework == 'esx' and frameworkCache.esx then
        local data = frameworkCache.esx.GetPlayerData()
        if data and data.job then
            return data.job.name
        end
    elseif state.framework == 'qbcore' and frameworkCache.qb then
        local data = frameworkCache.qb.Functions.GetPlayerData()
        if data and data.job then
            return data.job.name
        end
    elseif state.framework == 'open' then
        if LocalPlayer and LocalPlayer.state and LocalPlayer.state.job then
            local job = LocalPlayer.state.job
            if type(job) == 'table' then
                return job.name or job.id or 'mechanic'
            end
            return job
        end
    end

    return 'mechanic'
end

local function openTablet()
    if state.uiOpen then
        return
    end

    if not isAllowedJob(getCurrentJobName()) then
        notify(Config.Locale.noPermission)
        return
    end

    state.uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        payload = {
            framework = state.framework,
            mechanicName = getPlayerDisplayName(),
            locale = Config.Locale
        }
    })
end

local function closeTablet()
    state.uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('nuiReady', function(_, cb)
    state.nuiReady = true
    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    closeTablet()
    cb({ ok = true })
end)

RegisterNUICallback('inspectVehicle', function(_, cb)
    local vehicle = getVehicleInFront(6.0)
    if not vehicle then
        cb({ ok = false, message = Config.Locale.noVehicle })
        return
    end

    local snapshot = getVehicleSnapshot(vehicle)
    notify(Config.Locale.inspected)
    cb({ ok = true, data = snapshot })
end)

RegisterNUICallback('repairVehicle', function(_, cb)
    local vehicle = getVehicleInFront(6.0)
    if not vehicle then
        cb({ ok = false, message = Config.Locale.noVehicle })
        return
    end

    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    notify(Config.Locale.repaired)

    cb({ ok = true, data = getVehicleSnapshot(vehicle) })
end)

RegisterNUICallback('cleanVehicle', function(_, cb)
    local vehicle = getVehicleInFront(6.0)
    if not vehicle then
        cb({ ok = false, message = Config.Locale.noVehicle })
        return
    end

    local dirt = GetVehicleDirtLevel(vehicle)
    if dirt <= 0.01 then
        cb({ ok = false, message = Config.Locale.alreadyClean, data = getVehicleSnapshot(vehicle) })
        return
    end

    SetVehicleDirtLevel(vehicle, 0.0)
    WashDecalsFromVehicle(vehicle, 1.0)
    notify(Config.Locale.cleaned)
    cb({ ok = true, data = getVehicleSnapshot(vehicle) })
end)

CreateThread(function()
    detectFramework()

    RegisterCommand(Config.Command, function()
        if not state.nuiReady then
            notify('NUI is loading, try again in a moment.')
            return
        end
        openTablet()
    end, false)

    RegisterKeyMapping(Config.Command, 'Open mechanic tablet', 'keyboard', Config.DefaultKeybind)
end)
