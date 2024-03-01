local FW = config.Core.framework 

local Notify = config.Core.notify

local Targ = config.Core.target

local inZone = false

local IsCurrentlyViewing = false

local dict = 'missfam4'
local clip = 'base'
local clipboard = 'p_amb_clipboard_01'
local bone = 36029
local offset = vector3(0.16, 0.08, 0.1)
local rot = vector3(-170.0, 50.0, 20.0)

local function ShowVin(vin)
    lib.alertDialog({
        header = 'VIN Number:',
        content = vin,
        centered = true,
        cancel = false,
        labels = {
            confirm = 'Okay'
        }
    })
end

local function createBlip(blipSettings, location)
    local x, y, z = table.unpack(location)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, blipSettings.sprite)
    SetBlipColour(blip, blipSettings.color)
    SetBlipDisplay(blip, 4)
    SetBlipAlpha(blip, 250)
    SetBlipScale(blip, blipSettings.scale)
    SetBlipAsShortRange(blip, true)
    PulseBlip(blip)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipSettings.label)
    EndTextCommandSetBlipName(blip)
end

local function GenerateVin()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    local vin = {}
    for i = 1, 10 do
        local index = math.random(1, #chars) -- Get a random index in the range of 1 to the length of chars
        vin[i] = chars:sub(index, index) -- Select a single character at the random index
    end
    return table.concat(vin) -- Concatenate the table into a string
end

local function DetachAnim(entity)
    Citizen.CreateThread(function()
        Citizen.Wait(250)
        DetachEntity(entity, true, false)
        DeleteEntity(entity)
    end)
end

local function DoAnimation(dict, clip, bone, offset, rot, model, isCurrentlyViewing)
    Citizen.CreateThread(function()

        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do 
            Citizen.Wait(0)
        end

        local model = GetHashKey(clipboard)
        RequestModel(model)
        while not HasModelLoaded(model) do 
            Citizen.Wait(0)
        end

        local prop = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
        local boneIndex = GetPedBoneIndex(PlayerPedId(), bone)
        AttachEntityToEntity(prop, PlayerPedId(), boneIndex, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, true, false, false, false, 2, true)
        SetModelAsNoLongerNeeded(prop)
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(0)
                if IsCurrentlyViewing then 
                    if not IsEntityPlayingAnim(PlayerPedId(), dict, clip, 3) then
                        TaskPlayAnim(PlayerPedId(), dict, clip, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
                    end
                else
                    ClearPedSecondaryTask(PlayerPedId())
                    DetachAnim(prop)
                    break 
                end
            end
        end)
    end)
end

local function ApplyVINtoVeh(vehicle, plate)
    if not plate then
        plate = GetVehicleNumberPlateText(vehicle)
    end
    local checkReturnFromDB = lib.callback.await('browns_registration:server:CheckIfVehicleHasVin', false, plate) -- false here is source, as source seems to be needed on the other side tho not used
    if checkReturnFromDB == nil or checkReturnFromDB == '' then
        local generatedVin = GenerateVin()
        if checkReturnFromDB == '' then
            lib.callback.await('browns_registration:server:RegisterVinToDB', false, plate, generatedVin)
        end
        if not vehicle then
            checkReturnFromDB = generatedVin
            return checkReturnFromDB
        end
        Entity(vehicle).state:set('vin', generatedVin)
    end
end

local function CheckVehicleVin(plate)
    local vin = lib.callback.await('browns_registration:server:CheckIfVehicleHasVin', false, plate) -- false here is source, as source seems to be needed on the other side tho not used
    return vin
end

-- Main loop to check player zone and manage UI
Citizen.CreateThread(function()
    -- add a if statement here and add other target systems. I just did qb-target
    exports['qb-target']:AddCircleZone("registration", config.locations.registration, 1.5, { -- 1.5 = radius
    name = "registration",
    debugPoly = false, }, {
    options = {{
        action = function(entity)
        if IsPedAPlayer(entity) then return false end
            TriggerEvent("browns_registration:client:OpenMenu", 'registration')
        end,
        icon = 'fa-solid fa-hashtag', -- This is the icon that will display next to this trigger option
        label = '[E] - Car Registration',
        }
    },
    })
    exports['qb-target']:AddCircleZone("insurance", config.locations.insurance, 1.5, { -- 1.5 = radius
    name = "insurance",
    debugPoly = false, }, {
    options = {{
        action = function(entity)
        if IsPedAPlayer(entity) then return false end
            TriggerEvent("browns_registration:client:OpenMenu", 'insurance')
        end,
        icon = 'fa-solid fa-hashtag', -- This is the icon that will display next to this trigger option
        label = '[E] - Car Insurance',
        }
    },
    })

    if config.blip.registration.enable then 
        createBlip(config.blip.registration, config.locations.registration)
    end

    if config.blip.insurance.enable then 
        createBlip(config.blip.insurance, config.locations.insurance)
    end
    if string.find(Targ, 'ox') then
        exports.ox_target:addGlobalVehicle({
            label = 'Look at VIN',
            icon = 'fa-solid fa-hashtag',
            distance = 2.5,
            onSelect = function(data)
                local vehicle = data.entity 
                if not Entity(vehicle).state.vin then 
                    ApplyVINtoVeh(vehicle, nil)
                end
                ShowVin(Entity(vehicle).state.vin)
            end
        })
    else
        exports[Targ]:AddGlobalVehicle({
            options = { 
                { 
                    icon = 'fa-solid fa-hashtag', 
                    label = 'Look at VIN', 
                    action = function(entity) 
                        local vehicle = entity
                        if not Entity(vehicle).state.vin then 
                            ApplyVINtoVeh(vehicle, nil)
                        end
                        ShowVin(Entity(vehicle).state.vin)
                    end,
                }
            },
            distance = 2.5,
        })
    end
end)

RegisterNetEvent('browns_registration:client:ShowPaperwork', function (source, plate, name, date, expire) -- once again source is here caus' why not
    if not IsCurrentlyViewing then
        local vin = CheckVehicleVin(plate)
        local paperworkType 
        print('Expire: ' .. tostring(expire))
        if not expire then
            paperworkType = 'registration'
        else 
            paperworkType = 'insurance'
        end
        print(paperworkType)
        if not vin then
            vin = ApplyVINtoVeh(nil, plate)
        end
        SendNUIMessage({
            SendNUIMessage({
                show = 'reg',
                plate = 'Plate:' .. " " .. plate, 
                name = 'Owner:' .. " " .. name,
                vin = 'VIN:' .. " " .. vin,
                date = 'REGISTRATION DATE:' .. " " .. date,
                msg = 'REGISTRATION SHALL EXPIRE' .. " " .. tostring(config.expire) .. " " .. 'DAYS AFTER ABOVE DATE'
            })
        })
        
        if paperworkType == 'registration' then
            SendNUIMessage({
                show = 'reg',
                plate = 'Plate:' .. " " .. plate, 
                name = 'Owner:' .. " " .. name,
                vin = 'VIN:' .. " " .. vin,
                date = 'REGISTRATION DATE:' .. " " .. date,
                msg = 'REGISTRATION SHALL EXPIRE' .. " " .. tostring(config.expire) .. " " .. 'DAYS AFTER ABOVE DATE'
            })
            print('registration')
        elseif paperworkType == 'insurance' then
            SendNUIMessage({
                show = 'ins',
                plate = 'Plate:' .. " " .. plate, 
                name = 'Owner:' .. " " .. name,
                vin = 'VIN:' .. " " .. vin,
                date = 'PAYMENT DATE:' .. " " .. date,
                msg = 'INSURANCE SHALL EXPIRE' .. " " .. expire .. " " .. 'DAYS AFTER ABOVE DATE'
            })
            print('insurance')
        else
            print('lol')
        end
        DoAnimation(dict, clip, bone, offset, rot, clipboard, true)
        IsCurrentlyViewing = true
        Citizen.CreateThread(function()
            while true do 
                Citizen.Wait(0)
                if IsControlJustPressed(0, 202) then -- esc
                    SendNUIMessage({
                        show = 'hide'
                    })  
                    IsCurrentlyViewing = false
                    break 
                end
            end
        end)
    end
end)

RegisterNetEvent('browns_registration:client:OpenMenu', function (type)
    if type == 'registration' then
        local plates = {}

        local vehicles, playerName = lib.callback.await('browns_registration:server:GetPlayerVehiclesFromDB', false)
    
        if FW == 'esx' then 
            local pdata = CORE.GetPlayerData() 
            
            if pdata and pdata.firstName and pdata.lastName then 
                playerName = pdata.firstName .. " " .. pdata.lastName
            else
                playerName = lib.callback.await('browns_registration:server:esxdataName', false)
            end
            
        end
    
        if vehicles[1] then 
            for i = 1, #vehicles do 
                local data = vehicles[i]
                table.insert(plates, {
                    title = data.plate,
                    description = 'Click to Purchase Registration for vehicle with plate:' .. " " .. data.plate,
                    onSelect = function()
                        local bool = lib.callback.await('browns_registration:server:DeliverPaperwork', false, data.plate, playerName, nil)
                        
                        if not bool then 
                            Notify('Vehicle Registration', 'You dont have enough money', 'error', 5000)
                        end
                    end
                })
            end
    
            lib.registerContext({
                id = 'browns_registration',
                title = 'Vehicle Registration',
                options = plates
            })
    
            lib.showContext('browns_registration')
    
        else
    
            Notify('Vehicle Registration', 'You dont own any vehicles', 'error', 5000)
    
        end
    elseif type == 'insurance' then
        local plates = {}
        local vehicles, playerName = lib.callback.await('browns_registration:server:GetPlayerVehiclesFromDB', false)
    
        if FW == 'esx' then 
            local pdata = CORE.GetPlayerData() 
            if pdata and pdata.firstName and pdata.lastName then 
                playerName = pdata.firstName .. " " .. pdata.lastName
            else
                playerName = lib.callback.await('browns_registration:server:esxdataName', false)
            end
        end
    
        if vehicles[1] then 
            for i = 1, #vehicles do
                local data = vehicles[i]
                table.insert(plates, {
                    label = 'Plate:' .. " " .. data.plate,
                    value = data.plate
                })
            end
    
            local input = lib.inputDialog('Purchase Insurance - ($' .. tostring(config.costs.insurance) .. " Per Month)", {
                {type = 'select', label = 'Choose Vehicle', options = plates, description = 'Choose Vehicle By Plate'},
                {type = 'select', label = 'Choose Plan', options = {
                    {label = '1 Month', value = '30'},
                    {label = '2 Month', value = '60'},
                    {label = '3 Month', value = '90'},
                    {label = '4 Month', value = '120'},
                    {label = '5 Month', value = '150'},
                    {label = '6 Month', value = '180'},
                    {label = '7 Month', value = '210'},
                    {label = '8 Month', value = '240'},
                    {label = '9 Month', value = '270'},
                    {label = '10 Month', value = '300'},
                    {label = '11 Month', value = '330'},
                    {label = '12 Month', value = '360'},
                }},
            })
        
            if input then 
                local _, playerName = lib.callback.await('browns_registration:server:GetPlayerVehiclesFromDB', false)
        
                if FW == 'esx' then 
                    local pdata = CORE.GetPlayerData()
                    if pdata and pdata.firstName and pdata.lastName then 
                        playerName = pdata.firstName .. " " .. pdata.lastName
                    else
                        playerName = lib.callback.await('browns_registration:server:esxdataName', false)
                    end
                end
        
                local bool = lib.callback.await('browns_registration:server:DeliverPaperwork', false, input[1], playerName, input[2])
        
                if not bool then 
                    Notify('Vehicle Insurance', 'You Dont have enough money', 'error', 5000)
                end
            end
    
        else
            Notify('Vehicle Insurance', 'You dont own any vehicles', 'error', 5000)
    
        end
    end
end)