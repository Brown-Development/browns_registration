-- Determine the server's framework and inventory system from the configuration
local framework = config.Core.framework
local INV = config.Core.inventory

-- Function to get the core object of the server's framework
exports('getCore', function()
    if framework == 'esx' then 
        return exports['es_extended']:getSharedObject() 
    elseif framework == 'qb-core' then 
        return exports['qb-core']:GetCoreObject()
    end
end)

-- Function to get a player object
exports('getPlayer', function(source)
    local core = exports['browns_registration']:getCore()
    if framework == 'esx' then 
        return core.GetPlayerFromId(source)
    elseif framework == 'qb-core' then 
        return core.Functions.GetPlayer(source)
    end
end)

-- Function to get a player's identifier
exports('getId', function(player)
    if framework == 'esx' then 
        return player.getIdentifier()
    elseif framework == 'qb-core' then 
        return player.PlayerData.citizenid 
    end
end)

-- Function to add paperwork
exports('AddPaperworkToPlayerInventory', function(source, item, plate, vin, name, date, daysOfInsurance, type)
    if string.find(INV, 'qb') or string.find(INV, 'lj') or string.find(INV, 'ps') then 
        exports[INV]:AddItem(source, item, 1, nil, {regPlate = plate, regVin = vin, regName = name, regDate = date, regExpire = daysOfInsurance, regType = type})
    elseif string.find(INV, 'qs')  then
        print(daysOfInsurance)
        exports['qs-inventory']:AddItem(source, item, 1, nil , {regPlate = plate, regVin = vin, regName = name, regDate = date, regExpire = daysOfInsurance, regType = type})
    else
        exports.ox_inventory:AddItem(source, item, 1, {regPlate = plate, regVin = vin, regName = name, regDate = date, regExpire = daysOfInsurance, regType = type})
    end
end)