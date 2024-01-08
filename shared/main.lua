local FW = config.Core.framework

local INV = config.Core.inventory

function getCore()
    if FW == 'esx' then 
        return exports['es_extended']:getSharedObject() 
    elseif FW == 'qb-core' then 
        return exports['qb-core']:GetCoreObject()
    end
end

CORE = getCore()

function getPlayer(source)
    if FW == 'esx' then 
        return CORE.GetPlayerFromId(source)
    elseif FW == 'qb-core' then 
        return CORE.Functions.GetPlayer(source)
    end
end

function getId(player)
    if FW == 'esx' then 
        return player.getIdentifier()
    elseif FW == 'qb-core' then 
        return player.PlayerData.citizenid 
    end
end

function AddRegistration(source, item, plate, name, date)
    if string.find(INV, 'qs') or string.find(INV, 'qb') or string.find(INV, 'lj') or string.find(INV, 'ps') then 
        exports[INV]:AddItem(source, item, 1, nil, {regPlate = plate, regName = name, regDate = date})
    else
        exports.ox_inventory:AddItem(source, item, 1, {regPlate = plate, regName = name, regDate = date})
    end
end

function AddInsurance(source, item, plate, name, date, plan)
    if string.find(INV, 'qs') or string.find(INV, 'qb') or string.find(INV, 'lj') or string.find(INV, 'ps') then 
        exports[INV]:AddItem(source, item, 1, nil, {regPlate = plate, regName = name, regDate = date, regExpire = plan})
    else
        exports.ox_inventory:AddItem(source, item, 1, {regPlate = plate, regName = name, regDate = date, regExpire = plan})
    end
end


