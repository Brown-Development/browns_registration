local FW = config.Core.framework

local INV = config.Core.inventory

Citizen.CreateThread(function()
    if FW == 'esx' then 
        if string.find(INV, 'qs') then 
            exports['qs-inventory']:CreateUsableItem('vehicle_reg', function(source, item)
                TriggerClientEvent('reg:client:ShowRegistration', source, item.info.regPlate, item.info.regName, item.info.regDate)
            end)
            exports['qs-inventory']:CreateUsableItem('vehicle_ins', function(source, item)
                TriggerClientEvent('reg:client:ShowInsurance', source, item.info.regPlate, item.info.regName, item.info.regDate, item.info.regExpire)
            end)
        end
    elseif FW == 'qb-core' then 
        if not string.find(INV, 'ox') and not string.find(INV, 'qs') then 
            CORE.Functions.CreateUseableItem('vehicle_reg', function(source, item)
                TriggerClientEvent('reg:client:ShowRegistration', source, item.info.regPlate, item.info.regName, item.info.regDate)
            end)

            CORE.Functions.CreateUseableItem('vehicle_ins', function(source, item)
                TriggerClientEvent('reg:client:ShowInsurance', source, item.info.regPlate, item.info.regName, item.info.regDate, item.info.regExpire)
            end)
        end

        if string.find(INV, 'qs') then 
            exports['qs-inventory']:CreateUsableItem('vehicle_reg', function(source, item)
                TriggerClientEvent('reg:client:ShowRegistration', source, item.info.regPlate, item.info.regName, item.info.regDate)
            end)
            exports['qs-inventory']:CreateUsableItem('vehicle_ins', function(source, item)
                TriggerClientEvent('reg:client:ShowInsurance', source, item.info.regPlate, item.info.regName, item.info.regDate, item.info.regExpire)
            end)
        end
    end
end)

exports('UseRegistration', function(event, item, inventory, slot)

    item = exports.ox_inventory:GetSlot(inventory.id, slot)

    if event == 'usingItem' then
        TriggerClientEvent('reg:client:ShowRegistration', inventory.id, item.metadata.regPlate, item.metadata.regName, item.metadata.regDate)

        return false
    end

end)

exports('UseInsurance', function(event, item, inventory, slot)

    item = exports.ox_inventory:GetSlot(inventory.id, slot)

    if event == 'usingItem' then
        TriggerClientEvent('reg:client:ShowInsurance', inventory.id, item.metadata.regPlate, item.metadata.regName, item.metadata.regDate, item.metadata.regExpire)

        return false
    end

end)

lib.callback.register('reg:server:GetVehicles', function(source)
    local player = getPlayer(source)
    local id = getId(player)

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

lib.callback.register('reg:server:GetVin', function(source, plate, vin)

    local data = nil

    if FW == 'esx' then 
        local vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {
            plate
        })

        if not vehicles[1] then 
            data = vin 
        else
            if vehicles[1].vin ~= nil then 
                data = vehicles[1].vin
            else
                MySQL.update.await('UPDATE owned_vehicles SET vin = ? WHERE plate = ?', {
                    vin, plate
                })

                data = vin 
            end

        end

    elseif  FW == 'qb-core' then 
        local vehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', {
            plate
        })

        if not vehicles[1] then 
            data = vin 
        else
            if vehicles[1].vin ~= nil then 
                data = vehicles[1].vin
            else
                MySQL.update.await('UPDATE player_vehicles SET vin = ? WHERE plate = ?', {
                    vin, plate
                })
                
                data = vin 
            end

        end
    end

    return data

end)

lib.callback.register('reg:server:GetVINVEH', function(source, plate, vin)

    local data  

    local vehicle = false 

    for _, v in ipairs(GetAllVehicles()) do 
        if GetVehicleNumberPlateText(v) == plate then 
            vehicle = v 
            break 
        end
    end

    if FW == 'esx' then 
        local vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {
            plate
        })

        if vehicles[1].vin ~= nil then 
            data = vehicles[1].vin
        else
            MySQL.update.await('UPDATE owned_vehicles SET vin = ? WHERE plate = ?', {
                vin, plate
            })

            data = vin 
        end

    elseif  FW == 'qb-core' then 
        local vehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', {
            plate
        })

        if vehicles[1].vin ~= nil then 
            data = vehicles[1].vin
        else
            MySQL.update.await('UPDATE player_vehicles SET vin = ? WHERE plate = ?', {
                vin, plate
            })

            data = vin 
        end
    end

    return data, vehicle
end)

lib.callback.register('reg:server:AddRegistration', function(source, plate, name)

    local player = getPlayer(source)

    local amount

    local canPurchase = false

    if FW == 'esx' then 

        local bal = player.getAccounts()

        for _, v in ipairs(bal) do 
            if v.name == 'money' then 
                amount = v.money 
                break 
            end
        end

    elseif FW == 'qb-core' then 

        amount = player.PlayerData.money.cash
    end

    if amount >= config.costs.registration then 
        canPurchase = true 
    end

    if canPurchase then 
        AddRegistration(source, 'vehicle_reg', plate, name, os.date())
    end

    return canPurchase
end)

lib.callback.register('reg:server:AddInsurance', function(source, plate, plan, name)
    plan = tonumber(plan)

    local amount

    local canPurchase = false 

    local player = getPlayer(source)

    if FW == 'esx' then 


        local bal = player.getAccounts()

        for _, v in ipairs(bal) do 
            if v.name == 'money' then 
                amount = v.money 
                break 
            end
        end

    elseif FW == 'qb-core' then 

        amount = player.PlayerData.money.cash

    end

    local cost = plan / 30 * config.costs.insurance 

    if amount >= cost then 
        canPurchase = true 
    end

    if canPurchase then 
        if FW == 'esx' then 
            player.removeAccountMoney('money', cost)
        elseif FW == 'qb-core' then
            player.Functions.RemoveMoney('cash', cost, 'Vehicle Insurance')
        end

        AddInsurance(source, 'vehicle_ins', plate, name, os.date(), tostring(plan))
    end

    return canPurchase

end)

lib.callback.register('reg:server:esxdataName', function(source)
    local player = getPlayer(source)
    local identifier = getId(player)

    local data = MySQL.query.await('SELECT * FROM users WHERE identifier = ?', {
        identifier
    })

    name = data[1].firstname .. " " .. data[1].lastname

    return name

end)
