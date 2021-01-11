ESX = nil
CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Wait(0)
	end
end)

RegisterCommand('steal', function(source, args) robPlayer() end)
function robPlayer()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 1.5 then
        local target, distance = ESX.Game.GetClosestPlayer()
        playerheading = GetEntityHeading(GetPlayerPed(-1))
        playerlocation = GetEntityForwardVector(PlayerPedId())
        playerCoords = GetEntityCoords(GetPlayerPed(-1))
        local target_id = GetPlayerServerId(target)
        local searchPlayerPed = GetPlayerPed(target)
        if distance <= 1.5 then
            if IsEntityPlayingAnim(searchPlayerPed, 'random@mugging3', 'handsup_standing_base', 3) then
                TriggerServerEvent('esx_steal:SyncServerSide', target_id, playerheading, playerCoords, playerlocation)
                Wait(4500)
            elseif CheckIsPedDead() then
                TriggerServerEvent('esx_steal:SyncServerSide', target_id, playerheading, playerCoords, playerlocation)
            else
                exports['mythic_notify']:SendAlert('error', 'Victim needs their hands up.')
            end
        end
    else
        exports['mythic_notify']:SendAlert('error', 'Who are you trying to rob exactly?')
    end
end

function CheckIsPedDead()
    local target = ESX.Game.GetClosestPlayer()
    local searchPlayerPed = GetPlayerPed(target)
    if IsPedDeadOrDying(searchPlayerPed) then return true end
    return false
end

local isBeingRobbed = false
RegisterNetEvent('esx_steal:playerIsBeingRobbed')
AddEventHandler('esx_steal:playerIsBeingRobbed', function(playerheading, playercoords, playerlocation)
	playerPed = GetPlayerPed(-1)
	isBeingRobbed = true
	SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
	local x, y, z = table.unpack(playercoords + playerlocation * 0.85)
	SetEntityCoords(GetPlayerPed(-1), x, y, z-0.50)
	SetEntityHeading(GetPlayerPed(-1), playerheading)
	Wait(250)
	loadanimdict('random@mugging3')
	TaskPlayAnim(GetPlayerPed(-1), 'random@mugging3', 'handsup_standing_base', 8.0, -8, -1, 49, 0.0, false, false, false)
	Wait(12500)
	isBeingRobbed = false
	ClearPedSecondaryTask(GetPlayerPed(-1))
end)

RegisterNetEvent('esx_steal:playerIsRobbingSomeone')
AddEventHandler('esx_steal:playerIsRobbingSomeone', function()
	local target = ESX.Game.GetClosestPlayer()
	Wait(250)
	loadanimdict('combat@aim_variations@arrest')
	TaskPlayAnim(GetPlayerPed(-1), 'combat@aim_variations@arrest', 'cop_med_arrest_01', 8.0, -8,3750, 2, 0, 0, 0, 0)
	exports['mythic_progbar']:Progress({name = "robmebitch", duration = 3000, label = "Searching Person", useWhileDead = true, canCancel = false, controlDisables = {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}})
	Wait(3000)
	OpenBodySearchMenu(target)
 end)

function loadanimdict(dictname)
	if not HasAnimDictLoaded(dictname) then
		RequestAnimDict(dictname)
		while not HasAnimDictLoaded(dictname) do Wait(1) end
	end
end

function OpenBodySearchMenu(player)
	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
        local elements = {}
        for i=1, #data.accounts, 1 do
            if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
                table.insert(elements, {label = 'Dirty Money: $'..ESX.Math.Round(data.accounts[i].money), value = 'black_money', itemType = 'item_account', amount = data.accounts[i].money})
                break
            end
        end
        table.insert(elements, {label = '[[ Weapons on Player ]]'})
        for i=1, #data.weapons, 1 do
            table.insert(elements, {label = 'Take '..ESX.GetWeaponLabel(data.weapons[i].name)..' with '..data.weapons[i].ammo..' bullets', value = data.weapons[i].name, itemType = 'item_weapon', amount = data.weapons[i].ammo})
        end
        table.insert(elements, {label = '[[ Inventory ]]'})
        for i=1, #data.inventory, 1 do
            if data.inventory[i].count > 0 then
                table.insert(elements, {label = 'Take '..data.inventory[i].count..'x '..data.inventory[i].label, value = data.inventory[i].name, itemType = 'item_standard', amount = data.inventory[i].count})
            end
        end
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
            title = 'Search',
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            if data.current.value then
                TriggerServerEvent('esx_steal:stealPlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
				OpenBodySearchMenu(player)
            end
        end, function(data, menu)
            menu.close()
        end)
    end, GetPlayerServerId(player))
end

CreateThread(function()
	while true do
		Wait(0)
		local playerPed = PlayerPedId()
		if isBeingRobbed then
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 32, true) -- W
			DisableControlAction(0, 34, true) -- A
			DisableControlAction(0, 31, true) -- S
			DisableControlAction(0, 30, true) -- D
			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 217, true) -- Also 'enter'?
			DisableControlAction(0, 137, true) -- Also 'enter'?
			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job
			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen
			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle
			DisableControlAction(2, 36, true) -- Disable going stealth
			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		    if IsEntityPlayingAnim(playerPed, 'random@mugging3', 'handsup_standing_base', 3) ~= 1 then
		        ESX.Streaming.RequestAnimDict('random@mugging3', function()
			    	TaskPlayAnim(playerPed, 'random@mugging3', 'handsup_standing_base', 8.0, -8, -1, 49, 0.0, false, false, false)
			    end)
		    end
		else
			Wait(500)
		end
	end
end)