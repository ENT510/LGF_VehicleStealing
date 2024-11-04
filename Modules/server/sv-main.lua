Server = {}


LGF:RegisterServerCallback("LGF_VehicleStealing.AddItemsRandom", function(source, quantity, itemName)
    if not source or not quantity or not itemName then return end
    local success, response = exports.ox_inventory:AddItem(source, itemName, quantity)
    if success then
        return true
    else
        return false, response
    end
end)
