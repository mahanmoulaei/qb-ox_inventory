local qbInventoryExports = {}

local function LoadInventory(source, citizenid)
	local inventory = {}
	return inventory
end

qbInventoryExports["LoadInventory"] = LoadInventory

local function SaveInventory()
end

qbInventoryExports["SaveInventory"] = SaveInventory

---Gets the totalweight of the items provided
---@param items { [number]: { count: number, weight: number } } Table of items, usually the inventory table of the player
---@return number weight Total weight of param items
local function GetTotalWeight(items)
	local weight = 0
    if not items then return 0 end
    for _, item in pairs(items) do
        weight += item.weight * item.count
    end
    return tonumber(weight)
end

qbInventoryExports["GetTotalWeight"] = GetTotalWeight

---Gets the slots that the provided item is in
---@param items { [number]: { name: string, count: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } } Table of items, usually the inventory table of the player
---@param itemName string Name of the item to the get the slots from
---@return number[] slotsFound Array of slots that were found for the item
local function GetSlotsByItem(items, itemName)
    local slotsFound = {}
    if not items then return slotsFound end
    for slot, item in pairs(items) do
        if item.name:lower() == itemName:lower() then
            slotsFound[#slotsFound+1] = slot
        end
    end
    return slotsFound
end

exports("GetSlotsByItem", GetSlotsByItem)

---Get the first slot where the item is located
---@param items { [number]: { name: string, count: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } } Table of items, usually the inventory table of the player
---@param itemName string Name of the item to the get the slot from
---@return number | nil slot If found it returns a number representing the slot, otherwise it sends nil
local function GetFirstSlotByItem(items, itemName)
    if not items then return nil end
    for slot, item in pairs(items) do
        if item.name:lower() == itemName:lower() then
            return tonumber(slot)
        end
    end
    return nil
end

exports("GetFirstSlotByItem", GetFirstSlotByItem)

---Add an item to the inventory of the player
---@param source number The source of the player
---@param item string The item to add to the inventory
---@param count? number The count of the item to add
---@param slot? number The slot to add the item to
---@param info? table Extra info to add onto the item to use whenever you get the item
---@return boolean success Returns true if the item was added, false it the item couldn't be added
local function AddItem(source, item, count, slot, info)
	local Player = QBCore.Functions.GetPlayer(source)
	
	if not Player then return false end
	count = tonumber(count) or 1
	slot = tonumber(slot) or nil
	info = info or {}
	ox_inventory:AddItem(source, item, count, slot, info, function(success, reason)
		if success then
			return true
		else
			if not Player.Offline then
				QBCore.Functions.Notify(source, reason, 'error')
			end
			return false
		end
	end)
	
end

exports("AddItem", AddItem)

---Remove an item from the inventory of the player
---@param source number The source of the player
---@param item string The item to remove from the inventory
---@param count? number The count of the item to remove
---@param slot? number The slot to remove the item from
---@return boolean success Returns true if the item was remove, false it the item couldn't be removed
local function RemoveItem(source, item, count, slot, metadata)
	local Player = QBCore.Functions.GetPlayer(source)

	if not Player then return false end

	count = tonumber(count) or 1
	slot = tonumber(slot)

	ox_inventory:RemoveItem(source, item, count, metadata, slot, function(success, reason)
		if success then
			return true
		else
			if not Player.Offline then
				QBCore.Functions.Notify(source, reason, 'error')
			end
			return false
		end
	end)
	
end

exports("RemoveItem", RemoveItem)

---Get the item with the slot
---@param source number The source of the player to get the item from the slot
---@param slot number The slot to get the item from
---@return { name: string, count: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } | nil item Returns the item table, if there is no item in the slot, it will return nil
local function GetItemBySlot(source, slot)
	local Player = QBCore.Functions.GetPlayer(source)
	slot = tonumber(slot)
	return Player.PlayerData.items[slot]
end

exports("GetItemBySlot", GetItemBySlot)

---Get the item from the inventory of the player with the provided source by the name of the item
---@param source number The source of the player
---@param item string The name of the item to get
---@return { name: string, count: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } | nil item Returns the item table, if the item wasn't found, it will return nil
local function GetItemByName(source, item)
	local Player = QBCore.Functions.GetPlayer(source)
	item = tostring(item):lower()
	local slot = GetFirstSlotByItem(Player.PlayerData.items, item)
	return Player.PlayerData.items[slot]
end

exports("GetItemByName", GetItemByName)

---Get the item from the inventory of the player with the provided source by the name of the item in an array for all slots that the item is in
---@param source number The source of the player
---@param item string The name of the item to get
---@return { name: string, count: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table }[] item Returns an array of the item tables found, if the item wasn't found, it will return an empty table
local function GetItemsByName(source, item)
	local Player = QBCore.Functions.GetPlayer(source)
	item = tostring(item):lower()
	local items = {}
	local slots = GetSlotsByItem(Player.PlayerData.items, item)
	for _, slot in pairs(slots) do
		if slot then
			items[#items+1] = Player.PlayerData.items[slot]
		end
	end
	return items
end

exports("GetItemsByName", GetItemsByName)

---Clear the inventory of the player with the provided source and filter any items out of the clearing of the inventory to keep (optional)
---@param source number Source of the player to clear the inventory from
---@param filterItems? string | string[] Array of item names to keep
local function ClearInventory(source, filterItems)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then return end
	exports.ox_inventory:ClearInventory(source, filterItems)
end

exports("ClearInventory", ClearInventory)

---Sets the items playerdata to the provided items param
---@param source number The source of player to set it for
---@param items { [number]: { name: string, count: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } } Table of items, the inventory table of the player
local function SetInventory(source, items)
	local Player = QBCore.Functions.GetPlayer(source)

	if not Player or Player?.Offline then return end

	exports.ox_inventory:setPlayerInventory(source, items)
end

exports("SetInventory", SetInventory)

---Set the data of a specific item
---@param source number The source of the player to set it for
---@param itemName string Name of the item to set the data for
---@param key string Name of the data index to change
---@param val any Value to set the data to
---@return boolean success Returns true if it worked
local function SetItemData(source, itemName, key, val)
	if not itemName or not key then return false end

	local Player = QBCore.Functions.GetPlayer(source)

	if not Player then return end

	local item = GetItemByName(source, itemName)

	if not item then return false end

	item[key] = val
	Player.PlayerData.items[item.slot] = item
	Player.Functions.SetPlayerData("items", Player.PlayerData.items)

	return true
end

exports("SetItemData", SetItemData)

---Checks if you have an item or not
---@param source number The source of the player to check it for
---@param items string | string[] | table<string, number> The items to check, either a string, array of strings or a key-value table of a string and number with the string representing the name of the item and the number representing the count
---@param count? number The count of the item to check for, this will only have effect when items is a string or an array of strings
---@return boolean success Returns true if the player has the item
local function HasItem(source, items, count)
    if not source or not item then return false end
	count = count ~= nil and count or 1
	local count = ox_inventory:Search(source, 'count', item)
	return count ~= nil and count >= count or false
end

exports("HasItem", HasItem)

---Create a usable item with a callback on use
---@param itemName string The name of the item to make usable
---@param data any
local function CreateUsableItem(itemName, data)
	QBCore.Functions.CreateUseableItem(itemName, data)
end

exports("CreateUsableItem", CreateUsableItem)

---Get the usable item data for the specified item
---@param itemName string The item to get the data for
---@return any usable_item
local function GetUsableItem(itemName)
	return QBCore.Functions.CanUseItem(itemName)
end

exports("GetUsableItem", GetUsableItem)

---Use an item from the QBCore.UsableItems table if a callback is present
---@param itemName string The name of the item to use
---@param ... any Arguments for the callback, this will be sent to the callback and can be used to get certain values
local function UseItem(itemName, ...)
	local itemData = GetUsableItem(itemName)
	local callback = type(itemData) == 'table' and (rawget(itemData, '__cfx_functionReference') and itemData or itemData.cb or itemData.callback) or type(itemData) == 'function' and itemData
	if not callback then return end
	callback(...)
end

exports("UseItem", UseItem)

--#region Events

RegisterNetEvent('QBCore:Server:UpdateObject', function()
    if source ~= '' then return end -- Safety check if the event was not called from the server.
    QBCore = exports['qb-core']:GetCoreObject()
end)



RegisterNetEvent('inventory:server:UseItemSlot', function(slot)
	local src = source
	local itemData = GetItemBySlot(src, slot)
	if not itemData then return end
	local itemInfo = QBCore.Shared.Items[itemData.name]
	if itemData.useable then
		UseItem(itemData.name, src, itemData)
		TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
	end
end)

RegisterNetEvent('inventory:server:UseItem', function(inventory, item)
	local src = source
	if inventory ~= "player" and inventory ~= "hotbar" then return end
	local itemData = GetItemBySlot(src, item.slot)
	if not itemData then return end
	local itemInfo = QBCore.Shared.Items[itemData.name]
	if itemData.useable then
		UseItem(itemData.name, src, itemData)
		TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
	end
end)

RegisterNetEvent('inventory:server:snowball', function(action)
	if action == "add" then
		AddItem(source, "weapon_snowball")
	elseif action == "remove" then
		RemoveItem(source, "weapon_snowball")
	end
end)

QBCore.Functions.CreateCallback('QBCore:HasItem', function(source, cb, items, count)
	local retval = false
	retval = HasItem(source, items, count)
    cb(retval)
end)

QBCore.Commands.Add("rob", "Rob Player", {}, false, function(source, _)
	TriggerClientEvent("police:client:RobPlayer", source)
end)

--#region Items
--[[
CreateUsableItem("driver_license", function(source, item)
	local playerPed = GetPlayerPed(source)
	local playerCoords = GetEntityCoords(playerPed)
	local players = QBCore.Functions.GetPlayers()
	for _, v in pairs(players) do
		local targetPed = GetPlayerPed(v)
		local dist = #(playerCoords - GetEntityCoords(targetPed))
		if dist < 3.0 then
			TriggerClientEvent('chat:addMessage', v,  {
					template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>First Name:</strong> {1} <br><strong>Last Name:</strong> {2} <br><strong>Birth Date:</strong> {3} <br><strong>Licenses:</strong> {4}</div></div>',
					args = {
						"Drivers License",
						item.info.firstname,
						item.info.lastname,
						item.info.birthdate,
						item.info.type
					}
				}
			)
		end
	end
end)

CreateUsableItem("id_card", function(source, item)
	local playerPed = GetPlayerPed(source)
	local playerCoords = GetEntityCoords(playerPed)
	local players = QBCore.Functions.GetPlayers()
	for _, v in pairs(players) do
		local targetPed = GetPlayerPed(v)
		local dist = #(playerCoords - GetEntityCoords(targetPed))
		if dist < 3.0 then
			local gender = "Man"
			if item.info.gender == 1 then
				gender = "Woman"
			end
			TriggerClientEvent('chat:addMessage', v,  {
					template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>Civ ID:</strong> {1} <br><strong>First Name:</strong> {2} <br><strong>Last Name:</strong> {3} <br><strong>Birthdate:</strong> {4} <br><strong>Gender:</strong> {5} <br><strong>Nationality:</strong> {6}</div></div>',
					args = {
						"ID Card",
						item.info.citizenid,
						item.info.firstname,
						item.info.lastname,
						item.info.birthdate,
						gender,
						item.info.nationality
					}
				}
			)
		end
	end
end)

--#endregion Items


]]

local function RegisterStash(name, label, slots, maxWeight, owner, groups, coords)
	ox_inventory:RegisterStash(name, label or 'Stash', slots or 50, maxWeight or 1000000, owner, groups, coords)
end

RegisterNetEvent(CurrentResourceName..'server:RegisterStash', function(name, label, slots, maxWeight, owner, groups, coords)
	if source then
		RegisterStash(name, label, slots, maxWeight, owner, groups, coords)
	end
end)

-- backward compatibility event for qb-inventory
-- param label: optional label for stashes
RegisterNetEvent('inventory:server:OpenInventory', function(type, name, other, label)
	local playerStateBag = Player(source).state
	if playerStateBag.invBusy then return print('You cannot open any inventory at the moment!') end
	if type == 'shop' then
		-- TODO : update to ox_inventory once shop module inside of it is renewed
		local data = { shoptable = { products = other.items, label = other.label, }, custom = true }
		if GetResourceState('qb-shops') == 'started' then
			TriggerClientEvent('qb-shops:ShopMenu', source, data, true) --needs testing
		elseif GetResourceState('jim-shops') == 'started' then
			TriggerClientEvent('jim-shops:ShopMenu', source, data, true)
		else
			print('You need to start either qb-shops or jim-shops if you want compatibility with qb-inventory\'s event of \'inventory:server:OpenInventory\'')
		end
	elseif type == 'stash' then
		if label then RegisterStash(name, label) end
		TriggerClientEvent(CurrentResourceName..'client:OpenStash', source, name)
	elseif type == 'otherplayer' then
		if name then
			name = tonumber(name)
			local target = QBCore.Functions.GetPlayer(name)
			TriggerClientEvent(CurrentResourceName..'client:OpenOtherInventory', source, target ~= nil and name or nil)
		end
	end
end)

local function setupQbInventoryExports()
	Wait(5000)
	
end

for exportName, func in pairs(qbInventoryExports) do
		AddEventHandler(('__cfx_export_qb-inventory_%s'):format(exportName), function(cb)
			cb(func)
		end)
	end