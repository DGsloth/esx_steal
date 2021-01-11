ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_steal:SyncServerSide')
AddEventHandler('esx_steal:SyncServerSide', function(targetid, playerheading, playerCoords,  playerlocation)
	_source = source
    TriggerClientEvent('esx_steal:playerIsBeingRobbed', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('esx_steal:playerIsRobbingSomeone', _source)
end)

--[[
    Code taken from esx_policejob
]]
RegisterNetEvent('esx_steal:stealPlayerItem')
AddEventHandler('esx_steal:stealPlayerItem', function(target, itemType, itemName, amount)
    local _source = source
    local sourceXPlayer = ESX.GetPlayerFromId(_source)
    local targetXPlayer = ESX.GetPlayerFromId(target)
    if itemType == 'item_standard' then
        local targetItem = targetXPlayer.getInventoryItem(itemName)
        local sourceItem = sourceXPlayer.getInventoryItem(itemName)
        if targetItem.count > 0 and targetItem.count <= amount then
            if sourceXPlayer.canCarryItem(itemName, sourceItem.count) then
                targetXPlayer.removeInventoryItem(itemName, amount)
                sourceXPlayer.addInventoryItem(itemName, amount)
            else
                sourceXPlayer.showNotification('Quantity is invalid')
            end
        else
            sourceXPlayer.showNotification('Quantity is invalid')
        end
    elseif itemType == 'item_account' then
        targetXPlayer.removeAccountMoney(itemName, amount)
        sourceXPlayer.addAccountMoney(itemName, amount)
    elseif itemType == 'item_weapon' then
        if amount == nil then amount = 0 end
        targetXPlayer.removeWeapon(itemName, amount)
        sourceXPlayer.addWeapon(itemName, amount)
    end
end)