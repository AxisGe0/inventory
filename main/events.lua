if IsDuplicityVersion() then 
    local Functions = GetInventoryFunctions()
    AddEventHandler('playerDropped', function(reason) 
        local src = source
        local name = GetPlayerName(src)
        local Player = Functions.GetPlayer(src)
        if not Player then return end
        Player.Functions.Save()
        print("AXFW-INVENTORY: "..name.." Inventory Saved!")
    end)
    RegisterCommand('giveitem',function(source,args)
        local Player = Functions.GetPlayer(source)
        Player.Functions.AddItem(args[1],1)
    end)
else
    local Functions = GetInventoryFunctions()
    RegisterNetEvent('AXFW:Inventory:UseItem',function(slot)
        local slot = tonumber(slot)
        local Player = Functions.GetPlayer()
        if Player then 
            local item = Player.inventory[slot]
            if item and Shared.Items[item.name].Use then 
                Shared.Items[item.name].Use(item)
            end
        end
    end)
end
