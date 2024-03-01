local FW = config.Core.framework

local INV = config.Core.inventory

local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
local vin = {}

local function GenerateVin()
    for i = 1, 10 do
        local index = math.random(1, #chars) -- Get a random index in the range of 1 to the length of chars
        vin[i] = chars:sub(index, index) -- Select a single character at the random index
    end
    return table.concat(vin) -- Concatenate the table into a string
end

Citizen.CreateThread(function()
    if FW == 'esx' then 
        if string.find(INV, 'qs') then 
            exports['qs-inventory']:CreateUsableItem('vehicle_reg', function(source, item)
                TriggerClientEvent('browns_registration:client:ShowPaperwork', source, item.info.regPlate, item.info.regVin, item.info.regName, item.info.regDate, item.info.regExpire, item.info.type)
            end)
            exports['qs-inventory']:CreateUsableItem('vehicle_ins', function(source, item)
                TriggerClientEvent('browns_registration:client:ShowPaperwork', source, item.info.regPlate, item.info.regVin, item.info.regName, item.info.regDate, item.info.regExpire, item.info.type)
            end)
        end
    elseif FW == 'qb-core' then 
        if not string.find(INV, 'ox') and not string.find(INV, 'qs') then 
            CORE.Functions.CreateUseableItem('vehicle_reg', function(source, item)
                TriggerClientEvent('browns_registration:client:ShowPaperwork', source, item.info.regPlate, item.info.regVin, item.info.regName, item.info.regDate, item.info.regExpire, item.info.type)
            end)

            CORE.Functions.CreateUseableItem('vehicle_ins', function(source, item)
                TriggerClientEvent('browns_registration:client:ShowPaperwork', source, item.info.regPlate, item.info.regVin, item.info.regName, item.info.regDate, item.info.regExpire, item.info.type)
            end)
        end

        if string.find(INV, 'qs') then 
            exports['qs-inventory']:CreateUsableItem('vehicle_reg', function(source, item)
                TriggerClientEvent('browns_registration:client:ShowPaperwork', source, item.info.regPlate, item.info.regVin, item.info.regName, item.info.regDate, item.info.regExpire, item.info.type)
            end)
            exports['qs-inventory']:CreateUsableItem('vehicle_ins', function(source, item)
                TriggerClientEvent('browns_registration:client:ShowPaperwork', source, item.info.regPlate, item.info.regVin, item.info.regName, item.info.regDate, item.info.regExpire, item.info.type)
            end)
        end
    end
end)

lib.callback.register('browns_registration:server:GetPlayerVehiclesFromDB', function(source)
    local player = exports.browns_registration:getPlayer(source)
    local id = exports.browns_registration:getId(player)

    local name = nil 

    local data = nil 

    if FW == 'esx' then 
        local vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ?', {
            id
        })

        data = vehicles 


    elseif  FW == 'qb-core' then 
        local vehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {
            id
        })

        data = vehicles 

        name = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    end

    return data, name
end)

lib.callback.register('browns_registration:server:CheckIfVehicleHasVin', function (source, plate)
    local returnData = nil
    if FW == 'esx' then
        -- add esx logic
    elseif FW == 'qb-core' then
        local vehicleFromDB = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', {plate})
        -- note: below we check for the 1st row of vehicleFromDB as it retruns a table array and not row (yea I know, stupid)
        if vehicleFromDB[1] and vehicleFromDB[1].vin then -- if vehicle is in DB and has a vin
            returnData = vehicleFromDB[1] -- return the vin
        elseif vehicleFromDB[1] and vehicleFromDB[1].vin == nil then -- if vehicle is in DB but has no vin
            returnData = ''
        end
    end

    return returnData
    -- returnData values:
    -- nil  = vehicle not player
    -- ''   = vehicle is player but has no vin
    -- else = vin number
end)

local function CheckIfVehicleHasVin(source, plate)
    local returnData = nil
    if FW == 'esx' then
        -- add esx logic
    elseif FW == 'qb-core' then
        local vehicleFromDB = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', {plate})
        -- note: below we check for the 1st row of vehicleFromDB as it retruns a table array and not row (yea I know, stupid)
        if vehicleFromDB[1] and vehicleFromDB[1].vin then -- if vehicle is in DB and has a vin
            returnData = vehicleFromDB[1] -- return the vin
        elseif vehicleFromDB[1] and vehicleFromDB[1].vin == nil then -- if vehicle is in DB but has no vin
            returnData = ''
        end
    end

    return returnData
    -- returnData values:
    -- nil  = vehicle not player
    -- ''   = vehicle is player but has no vin
    -- else = vin number
end

lib.callback.register('browns_registration:server:RegisterVinToDB', function (source, plate, generatedVin)
    if FW == 'esx' then
        -- add esx logic
    elseif FW == 'qb-core' then
        MySQL.update.await('UPDATE player_vehicles SET vin = ? WHERE plate = ?', {generatedVin, plate})
    end
end)

local function RegisterVinToDB(source, plate, generatedVin)
    if FW == 'esx' then
        -- add esx logic
    elseif FW == 'qb-core' then
        MySQL.update.await('UPDATE player_vehicles SET vin = ? WHERE plate = ?', {generatedVin, plate})
    end
end

lib.callback.register('browns_registration:server:DeliverPaperwork', function(source, plate, name, daysOfInsurance)
    local player = exports.browns_registration:getPlayer(source)
    local registrationCost = config.costs.registration
    local insuranceCost = 0
    local totalCost = registrationCost -- default totalCost in case buying a registration
    if daysOfInsurance then
        insuranceCost = tonumber(daysOfInsurance) / 30 * config.costs.insurance
        totalCost = insuranceCost -- nvm player is buying an insurance, replace the price
    end
    local playerMoney
    local canPurchase = false

    -- Check player's balance
    if FW == 'esx' then
        local bal = player.getAccounts()
        for _, v in ipairs(bal) do
            if v.name == 'money' then
                playerMoney = v.money
                break
            end
        end
    elseif FW == 'qb-core' then
        playerMoney = player.PlayerData.money.cash
    end

    -- Check if player can afford both registration and insurance
    if playerMoney >= totalCost then
        canPurchase = true
    end

    if canPurchase then
        -- Deduct the total cost from player's balance
        if FW == 'esx' then
            player.removeAccountMoney('money', totalCost)
        elseif FW == 'qb-core' then
            player.Functions.RemoveMoney('cash', totalCost, 'Vehicle Registration/Insurance')
        end
        --check if car has vin, if not create
        local vin = CheckIfVehicleHasVin(source, plate) -- false here is source, as source seems to be needed on the other side tho not used
        local vinAsString = tostring(vin.vin)
        if vinAsString == 'nil' then -- checking this way as 'nil' is now a string value (aka true value)
            local generatedVin = GenerateVin()
            RegisterVinToDB(source, plate, generatedVin)
            vinAsString = generatedVin
        end

        if daysOfInsurance and tonumber(daysOfInsurance) > 0 then -- Add insurance paperwork to player's inventory
            exports.browns_registration:AddPaperworkToPlayerInventory(source, 'vehicle_ins', plate, vinAsString, name, os.date(), tostring(daysOfInsurance), 'insurance')
        else
            exports.browns_registration:AddPaperworkToPlayerInventory(source, 'vehicle_reg', plate, vinAsString, name, os.date(), '', 'registration')
        end
    end

    return canPurchase
end)

lib.callback.register('browns_registration:server:esxdataName', function(source)
    local player = exports.browns_registration:getPlayer(source)
    local identifier = exports.browns_registration:getId(player)

    local data = MySQL.query.await('SELECT * FROM users WHERE identifier = ?', {
        identifier
    })

    name = data[1].firstname .. " " .. data[1].lastname

    return name

end)
