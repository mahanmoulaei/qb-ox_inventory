local qbInventoryExports = {}

local function HasItem(item, amount)
	if not item then return false end
	amount = amount ~= nil and amount or 1
	local count = ox_inventory:Search('count', item)
    return count ~= nil and count >= amount or false
end

qbInventoryExports["HasItem"] = HasItem

RegisterNetEvent(CurrentResourceName..'client:OpenStash', function(name)
	-- print(GetInvokingResource())
    -- if GetInvokingResource() ~= CurrentResourceName then return end
    if not ox_inventory:openInventory('stash', name) then
        TriggerServerEvent(CurrentResourceName..'server:RegisterStash', name)
        ox_inventory:openInventory('stash', name)
    end
end)

RegisterNetEvent(CurrentResourceName..'client:OpenOtherInventory', function(name)
    -- if GetInvokingResource() ~= CurrentResourceName then return end
    if not name then
        if not ox_inventory:openNearbyInventory() then
            QBCore.Functions.Notify('You are not able to open nearby player\'s inventory now!', 'error')
        end
    else
        if not ox_inventory:openInventory('player', name) then
            QBCore.Functions.Notify('You are not able to open player '..tostring(name)..'\'s inventory now!', 'error')
        end
    end
end)

for exportName, func in pairs(qbInventoryExports) do
	AddEventHandler(('__cfx_export_qb-inventory_%s'):format(exportName), function(cb)
		cb(func)
	end)
end