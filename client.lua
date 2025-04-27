if not lib then return end
if not Config then Config = {} end


Config.Debug = Config.Debug or false
Config.HUD = Config.HUD or {Visible = true, Command = 'togglehud'}
Config.Framework = Config.Framework or 'auto'
Config.JobFormat = Config.JobFormat or "%s / %s"
Config.UI = Config.UI or {ShowInfo = true, ShowSpeedometer = true}


local Locales = {}
local function LoadLocale(lang)
    print("[oxc-hud] Attempting to load locale: " .. lang)
    local localeFile = LoadResourceFile(GetCurrentResourceName(), "locales/" .. lang .. ".json")
    if localeFile then
        print("[oxc-hud] Locale file found: " .. lang .. ".json")
        local success, data = pcall(json.decode, localeFile)
        if success and data then
            Locales = data
            print("[oxc-hud] Locale successfully loaded and decoded: " .. lang)
            return true
        else
            print("[oxc-hud] Failed to decode locale file: " .. lang .. ".json")
        end
    else
        print("[oxc-hud] Failed to load locale file: " .. lang .. ".json")
    end
    return false
end


local selectedLang = Config.Language or 'tr'
print("[oxc-hud] Language selected from config: " .. selectedLang)
if not LoadLocale(selectedLang) then
    print("[oxc-hud] Falling back to default locale: en")
    LoadLocale('en')
end


local function debugPrint(message, data)
    if not Config.Debug then return end
    if data then
        lib.print.info('[OXC-HUD]', message, json.encode(data, {indent = true}))
    else
        lib.print.info('[OXC-HUD]', message)
    end
end


local Framework = {
    resource = nil,
    object = nil
}


CreateThread(function()
    if Config.Framework == 'esx' or Config.Framework == 'auto' then
    if GetResourceState('es_extended') == 'started' then
        Framework.resource = 'es_extended'
        Framework.object = exports['es_extended']:getSharedObject()
        debugPrint('ESX Framework detected')
        end
    end
    
    if (Framework.resource == nil and Config.Framework == 'auto') or Config.Framework == 'qbcore' then
        if GetResourceState('qb-core') == 'started' then
        Framework.resource = 'qb-core'
        Framework.object = exports['qb-core']:GetCoreObject()
        debugPrint('QBCore Framework detected')
        end
    end
end)


local State = {
    visible = Config.HUD.Visible,
    inVehicle = false
}


CreateThread(function()
    Wait(500) 
    while true do
        Wait(0) 

        local playerPed = PlayerPedId()
        local isInVehicle = IsPedInAnyVehicle(playerPed, false) 

        
        for i = 0, 22 do
            HideHudComponentThisFrame(i)
        end


        DisplayRadar(isInVehicle)


        SetHudComponentPosition(6, 999999.0, 999999.0) -- Health
        SetHudComponentPosition(7, 999999.0, 999999.0) -- Armor
        SetHudComponentPosition(8, 999999.0, 999999.0) -- Oxygen

        
        State.inVehicle = isInVehicle
    end
end)

-- HUD görünürlük komutu
RegisterCommand(Config.HUD.Command, function()
    State.visible = not State.visible
    lib.notify({
        title = 'HUD',
        description = State.visible and Locales.hud_on or Locales.hud_off,
        type = 'inform'
    })
    
    -- NUI güncellemesi
    SendNUIMessage({
        action = 'setVisible',
        value = State.visible
    })
end, false)


local seatbeltKey = Config.Seatbelt and Config.Seatbelt.Key or 'B'
local seatbeltCooldown = false 

if seatbeltKey ~= 'None' and seatbeltKey ~= '' then
    RegisterKeyMapping('toggleSeatbelt', 'Emniyet Kemerini Tak/Çıkar', 'keyboard', seatbeltKey)
    RegisterCommand('toggleSeatbelt', function()
        if seatbeltCooldown then return end 
        DebugPrint("Toggle Seatbelt Command Triggered") 
        
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            seatbeltCooldown = true 
            SetTimeout(500, function() seatbeltCooldown = false end) 
            
            local currentStatus = GetPedConfigFlag(playerPed, 32, true)
            DebugPrint("Seatbelt status BEFORE toggle:", currentStatus) 
            SetPedConfigFlag(playerPed, 32, not currentStatus) 
            
            
            Wait(10) 
            local newStatus = GetPedConfigFlag(playerPed, 32, true)
            DebugPrint("Seatbelt status AFTER toggle:", newStatus)  
            
            
            if not currentStatus then 
                PlaySoundFrontend(-1, "Seatbelt_On", "DLC_Apt_Biker_Safety_Sounds", true)
                 lib.notify({ title = Locales.seatbelt_indicator_tooltip or 'Emniyet Kemeri', description = Locales.seatbelt_fastened, type = 'success', duration = 1500 })
            else
                PlaySoundFrontend(-1, "Seatbelt_Off", "DLC_Apt_Biker_Safety_Sounds", true)
                 lib.notify({ title = Locales.seatbelt_indicator_tooltip or 'Emniyet Kemeri', description = Locales.seatbelt_unfastened, type = 'error', duration = 1500 })
            end
        end
    end, false)
end


AddEventHandler('entityRemoved', function(entity)
    local playerPed = PlayerPedId()
    if GetVehiclePedIsIn(playerPed, false) == entity then
        if GetPedConfigFlag(playerPed, 32, true) then
             SetPedConfigFlag(playerPed, 32, false)
        end
    end
end)


CreateThread(function()
    Wait(2000)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        value = State.visible
    })
end)


if Framework.resource == 'es_extended' then
    RegisterNetEvent('esx:setAccountMoney', function(account)
        if account.name == 'money' or account.name == 'bank' then
            debugPrint('Money updated:', account)
        end
    end)
elseif Framework.resource == 'qb-core' then
    RegisterNetEvent('QBCore:Client:OnMoneyChange', function(type, amount)
        debugPrint('Money updated:', {type = type, amount = amount})
    end)
end



exports('getHUDState', function()
    return State
end)

exports('setHUDVisible', function(visible)
    State.visible = visible
    SendNUIMessage({
        action = 'setVisible',
        value = visible
    })
    return true
end)


local DEBUG_MODE = Config.Debug
local DEBUG_LEVEL = 3


function DebugPrint(message, vardump, level)
    level = level or 3
    if not DEBUG_MODE or level > DEBUG_LEVEL then return end
    
    local prefix = "[OXC-HUD DEBUG]"
    
    if vardump then
        print(prefix .. " " .. message .. ":")
        for k, v in pairs(vardump) do
            if type(v) == "table" then
                print("  └─ " .. k .. ": [TABLO]")
                for k2, v2 in pairs(v) do
                    print("     └─ " .. k2 .. ": " .. tostring(v2))
                end
            else
                print("  └─ " .. k .. ": " .. tostring(v))
            end
        end
    else
        print(prefix .. " " .. message)
    end
end

-- Framework Detection
local ESX = nil
local QBCore = nil

Citizen.CreateThread(function()
    if Config.Framework == 'esx' or Config.Framework == 'auto' then
        local esxResourceName = Config.Framework.CustomESX or 'es_extended'
        if GetResourceState(esxResourceName) == 'started' then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            DebugPrint("ESX Framework detected for HUD", nil, 1)
        end
    end
    
    if (ESX == nil and Config.Framework == 'auto') or Config.Framework == 'qbcore' then
        local qbResourceName = Config.Framework.CustomQBCore or 'qb-core'
        if GetResourceState(qbResourceName) == 'started' then
            QBCore = exports[qbResourceName]:GetCoreObject()
            DebugPrint("QBCore Framework detected for HUD", nil, 1)
        end
    end
    
    if ESX == nil and QBCore == nil and Config.Framework ~= 'none' then
        DebugPrint("No supported framework detected for HUD. Using standalone mode.", nil, 2)
    end
end)


local playerData = {}


function SendHudUpdates()
    if not State.visible then return end
    local playerPed = PlayerPedId() 

    local playerId = GetPlayerServerId(PlayerId())
    
    -- Bottom-Left HUD Data
    local health = GetEntityHealth(playerPed) - 100
    local armor = GetPedArmour(playerPed)
    local stamina = GetPlayerStamina(PlayerId()) 
    local hunger = playerData.hunger or 100 
    local thirst = playerData.thirst or 100 
    local coords = GetEntityCoords(playerPed)
    local streetName, crossingRoad = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    local locationString = GetStreetNameFromHashKey(streetName)
    
    if crossingRoad and crossingRoad ~= 0 then
        locationString = locationString .. ", " .. GetStreetNameFromHashKey(crossingRoad)
    end
    
    if not locationString or locationString == "" or locationString == "UNK" then 
        locationString = GetLabelText(zone) 
    end
    
    
    local isTalking = NetworkIsPlayerTalking(PlayerId()) 

    -- Top-Right HUD Data
    local playerCount = #GetActivePlayers()
    local maxPlayers = GetConvarInt("sv_maxclients", 64)
    local hours = GetClockHours()
    local minutes = GetClockMinutes()
    local timeString = string.format("%02d:%02d", hours, minutes)
    
    -- Weather değişkeni
    local weatherHash = GetPrevWeatherTypeHashName()
    local weather = "CLEAR" -- Default değer
    

    if weatherHash == -1750463879 then
        weather = "CLEAR"
    elseif weatherHash == 916995460 then
        weather = "CLOUDY"
    elseif weatherHash == -1530260698 then
        weather = "RAIN"
    elseif weatherHash == 282916021 then
        weather = "SMOG"
    elseif weatherHash == -1368164796 then
        weather = "FOGGY"
    elseif weatherHash == -1233681761 then
        weather = "THUNDER"
    elseif weatherHash == 669657108 then
        weather = "SNOW"
    elseif weatherHash == -273223690 then
        weather = "BLIZZARD"
    elseif weatherHash == 603685163 then
        weather = "XMAS"
    elseif weatherHash == -1429616491 then
        weather = "HALLOWEEN"
    else
        weather = tostring(weatherHash) 
    end
    
    local cash = playerData.cash or 0
    local bank = playerData.bank or 0
    local jobLabel = playerData.jobLabel or "İşsiz"
    local jobGradeLabel = playerData.jobGradeLabel or "-"

    -- Para önündeki sembol ekle
    local cashText = '₺' .. cash
    local bankText = '₺' .. bank

    -- Send combined update message
    SendNUIMessage({
        action = 'updateAll',
        
        -- Bottom-Left Data
        health = health < 0 and 0 or health,
        armor = armor,
        stamina = stamina,
        hunger = hunger,
        thirst = thirst,
        location = locationString or "Unknown Area",
        isTalking = isTalking,
        showOxygen = false,        
        oxygen = 100.0,         

        -- Top-Right Data
        playerId = playerId,
        playerCount = playerCount,
        maxPlayers = maxPlayers, 
        time = timeString,
        weather = weather,
        cash = cash,
        bank = bank,
        jobLabel = jobLabel,
        jobGradeLabel = jobGradeLabel,
        
        -- Config Settings
        showInfo = Config.UI.ShowInfo,
        jobFormat = Config.JobFormat
    })
end


function UpdatePlayerDataCache()
    DebugPrint("Updating player data cache")
    
    if ESX then
        local esxPlayer = ESX.GetPlayerData()
        DebugPrint("ESX player data retrieved", esxPlayer)
        playerData.cash = esxPlayer.getAccount('money').money or 0
        playerData.bank = esxPlayer.getAccount('bank').money or 0
        playerData.jobLabel = esxPlayer.job.label or "İşsiz"
        playerData.jobGradeLabel = esxPlayer.job.grade_label or "-"

    elseif QBCore then
        local qbPlayer = QBCore.Functions.GetPlayerData()
        DebugPrint("QBCore player data retrieved", qbPlayer)
        
        if qbPlayer then
            
            if qbPlayer.money then 
                playerData.cash = qbPlayer.money['cash'] or 0
                playerData.bank = qbPlayer.money['bank'] or 0
            else
                DebugPrint("QBCore money data is nil")
                playerData.cash = 0 
                playerData.bank = 0 
            end
            
            
            if qbPlayer.job then
                DebugPrint("QBCore job data found", qbPlayer.job)
                print(json.encode(qbPlayer.job)) -- Debug: Gelen job verisini yazdır
                playerData.jobLabel = qbPlayer.job.label or "İşsiz"
                
                
                if qbPlayer.job.grade then
                   
                    playerData.jobGradeLabel = qbPlayer.job.grade.label or qbPlayer.job.grade.name or "-" 
                else
                    DebugPrint("QBCore job.grade data is nil")
                    playerData.jobGradeLabel = "-"
                end
            else
                DebugPrint("QBCore job data is nil")
                playerData.jobLabel = "İşsiz"
                playerData.jobGradeLabel = "-" 
            end
            
            
            if qbPlayer and qbPlayer.metadata then
                playerData.hunger = qbPlayer.metadata['hunger'] or 100
                playerData.thirst = qbPlayer.metadata['thirst'] or 100
            else
                DebugPrint("QBCore player or metadata is nil, using default hunger/thirst")
                playerData.hunger = 100
                playerData.thirst = 100
            end
        else
            DebugPrint("QBCore player data is nil")
        end
    else
        DebugPrint("No framework detected, using default values")
        
        playerData.cash = 0
        playerData.bank = 0
        playerData.jobLabel = "İşsiz"
        playerData.jobGradeLabel = "-"
        playerData.hunger = 100
        playerData.thirst = 100
    end
    
    DebugPrint("Updated player data", playerData)
   
    SetTimeout(5000, UpdatePlayerDataCache) 
end

-- Initial cache update
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    UpdatePlayerDataCache()
end)




RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    playerData.jobLabel = job.label or "İşsiz"
    playerData.jobGradeLabel = job.grade_label or "-"
    SendHudUpdates()
end)


RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    DebugPrint("QBCore job update received", job)
    print(json.encode(job)) -- Debug: Gelen job verisini yazdır
    
    if job then
        playerData.jobLabel = job.label or "İşsiz"
        
        if job.grade then
          
           playerData.jobGradeLabel = job.grade.label or job.grade.name or "-"
        else
           DebugPrint("QBCore job update: job.grade is nil")
           playerData.jobGradeLabel = "-"
        end
    else
        DebugPrint("QBCore job update: job is nil")
        playerData.jobLabel = "İşsiz"
        playerData.jobGradeLabel = "-"
    end
    
    SendHudUpdates()
end)


Citizen.CreateThread(function()
    local lastVehicleState = false 
    
    while true do
        Wait(150) 
        local playerPed = PlayerPedId() 
        local isInVeh = IsPedInAnyVehicle(playerPed, false)
        
        
        if isInVeh ~= lastVehicleState then
            
            lastVehicleState = isInVeh
            State.inVehicle = isInVeh 
            
           
            local showSpeedo = State.visible and isInVeh and Config.UI.ShowSpeedometer
            SendNUIMessage({ 
                action = 'updateVehicle', 
                show = showSpeedo
            })
            
            DebugPrint("Araç durumu değişti: " .. (isInVeh and "Araçta" or "Araç dışında"), nil, 3)
        end
        
        
        if isInVeh then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local showSpeedo = State.visible and isInVeh and Config.UI.ShowSpeedometer
            local vehicleData = { action = 'updateVehicle', show = showSpeedo }

            if showSpeedo then
              
                local speedMultiplier = Config.Speedometer.Unit == 'kmh' 
                    and Config.Speedometer.KmhConversion 
                    or Config.Speedometer.MphConversion
                    
                local speed = GetEntitySpeed(vehicle) * speedMultiplier
                local rpm = GetVehicleCurrentRpm(vehicle)
                
                
                local fuel = 0
                if Config.Fuel and Config.Fuel.Enabled then
                    
                    fuel = Config.GetFuel(vehicle)
                else
                    
                    fuel = GetVehicleFuelLevel(vehicle)
                end
                
                
                local gear = GetVehicleCurrentGear(vehicle)
                local _, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
                local engineHealth = GetVehicleEngineHealth(vehicle)
                
               
                if gear == 0 then 
                    gear = 'R'
                elseif gear == 1 then 
                    gear = 'N'
                else 
                    gear = gear - 1
                end

                -- Verileri gönder
                vehicleData.speed = math.floor(speed)
                vehicleData.rpm = rpm
                vehicleData.fuel = fuel
                vehicleData.gear = tostring(gear)
                vehicleData.seatbelt = GetPedConfigFlag(playerPed, 32, true) -- Emniyet kemeri durumu
                vehicleData.lights = lightsOn or highbeamsOn -- 
                vehicleData.engineHealth = engineHealth -- 
                vehicleData.speedUnit = Config.Speedometer.Unit:upper()
                
                
                
                vehicleData.handbrake = GetVehicleHandbrake(vehicle) -- 
                vehicleData.abs = GetControlNormal(0, 72) > 0.1 --
                vehicleData.seatbelt = GetPedConfigFlag(playerPed, 32, true) -- 
                
                DebugPrint("Vehicle Data Sent:", vehicleData) -- DEBUG: Gönderilen araç verisini yazdır
            end
            
            SendNUIMessage(vehicleData)
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        if State.visible then
            SendHudUpdates()
        end
        Citizen.Wait(1000) 
    end
end)


Citizen.CreateThread(function()
    Citizen.Wait(2000) 
    SetNuiFocus(false, false)
   
    SendNUIMessage({ action = 'setVisible', value = State.visible })
   
    SendNUIMessage({ action = 'updateVehicle', show = State.visible and IsPedInAnyVehicle(PlayerPedId(), false) })

end)


Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        Wait(50) 
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3) 
        EndScaleformMovieMethod()
    end
end)

-- Oksijen Yönetimi Thread'i
CreateThread(function()
    while true do
        Wait(250) 
        local playerPed = PlayerPedId() 

       
        local isDiving = IsPedHeadUnderwater and IsPedHeadUnderwater(playerPed) or IsPedSwimmingUnderWater(playerPed)

        if isDiving then

        else

        end
    end
end)


CreateThread(function()
    if not Config.Seatbelt or not Config.Seatbelt.EnableNotifications then return end -- Ayar kapalıysa thread'i başlatma

    while true do
        Wait(Config.Seatbelt.NotificationInterval or 5000) -- Config'den alınan sıklıkla bekle

        local playerPed = PlayerPedId()
        if State.inVehicle then 
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle and vehicle ~= 0 then
                local speed = GetEntitySpeed(vehicle) * (Config.Speedometer.Unit == 'kmh' and Config.Speedometer.KmhConversion or Config.Speedometer.MphConversion)
                local isSeatbeltOn = GetPedConfigFlag(playerPed, 32, true)


                if speed > 10 and not isSeatbeltOn then
                    lib.notify({
                        title = 'Uyarı',
                        description = 'Lütfen emniyet kemerinizi takın!',
                        type = 'warning',
                        duration = 3000 -- Bildirim süresi
                    })
                end
            end
        end
    end
end)


CreateThread(function()
    while true do
        Wait(50) 
        local playerPed = PlayerPedId() 
        
        if IsPedInAnyVehicle(playerPed, false) then
            local isSeatbeltOn = GetPedConfigFlag(playerPed, 32, true)
            if isSeatbeltOn then
              
                DisableControlAction(0, 75, true) 
            end
        end
    end
end)


RegisterNUICallback('requestLocale', function(data, cb)
    SendNUIMessage({
        action = 'setLocale',
        locale = Locales
    })
    cb('ok')
end)
 