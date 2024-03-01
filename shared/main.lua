-- Determine the server's framework and inventory system from the configuration
local FW = config.Core.framework
local INV = config.Core.inventory

-- Function to get the core object of the server's framework
exports('getCore', function()
    if FW == 'esx' then 
        return exports['es_extended']:getSharedObject() 
    elseif FW == 'qb-core' then 
        return exports['qb-core']:GetCoreObject()
    end
end)

-- Function to get a player object
exports('getPlayer', function(source)
    local core = exports['browns_registration']:getCore()
    if FW == 'esx' then 
        return core.GetPlayerFromId(source)
    elseif FW == 'qb-core' then 
        return core.Functions.GetPlayer(source)
    end
end)

-- Function to get a player's identifier
exports('getId', function(player)
    if FW == 'esx' then 
        return player.getIdentifier()
    elseif FW == 'qb-core' then 
        return player.PlayerData.citizenid 
    end
end)

-- Function to add registration
exports('AddRegistrationExport', function(source, item, plate, name, date)
    if string.find(INV, 'qb') or string.find(INV, 'lj') or string.find(INV, 'ps') then 
        exports[INV]:AddItem(source, item, 1, nil, {regPlate = plate, regName = name, regDate = date})
    elseif string.find(INV, 'qs')  then
        exports['qs-inventory']:GiveItemToPlayer(source, item, 1)
    else
        exports.ox_inventory:AddItem(source, item, 1, {regPlate = plate, regName = name, regDate = date})
    end
end)

-- Function to add insurance
exports('AddInsuranceExport', function(source, item, plate, name, date, plan)
    if string.find(INV, 'qb') or string.find(INV, 'lj') or string.find(INV, 'ps') then 
        exports[INV]:AddItem(source, item, 1, nil, {regPlate = plate, regName = name, regDate = date, regExpire = plan})
    elseif string.find(INV, 'qs')  then
        exports['qs-inventory']:GiveItemToPlayer(source, item, 1)
    else
        exports.ox_inventory:AddItem(source, item, 1, {regPlate = plate, regName = name, regDate = date, regExpire = plan})
    end
end)


