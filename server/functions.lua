local InvFunctions = GetInventoryFunctions()

GenerateDropID = function()
    local id = 'Drop-'..math.random(10000,60000)
    while IDs[id] do 
        Wait(0)
        id = 'Drop-'..math.random(10000,60000)
    end
    IDs[id] = true
    return id
end

AddItemToStash = function(id,item,amount,slot,info)
    local iteminfo = Shared.Items[item:lower()]
    if Stashes[id] then 
        if slot then 
            if Stashes[id].items[slot] and Stashes[id].items[slot].name == item then 
                if string.find(string.lower(item),'weapon') or info.quality ~= Stashes[id].items[slot].info.quality or iteminfo.unique then 
                    local freeslot = GetFreeSlot(id)
                    Stashes[id].items[freeslot] = {
                        name = item,
                        slot = freeslot,
                        amount = tonumber(amount),
                        info = info,
                        label = iteminfo.label
                    }
                else
                    Stashes[id].items[slot].amount = Stashes[id].items[slot].amount + amount 
                end
            else
                Stashes[id].items[slot] = {
                    name = item,
                    slot = slot,
                    amount = tonumber(amount),
                    info = info,
                    label = iteminfo.label
                }
            end
        else 
            table.insert(Stashes[id].items,{
                name = item,
                slot = slot,
                amount = tonumber(amount),
                info = info,
                label = iteminfo.label
            })
        end
        SaveStash(id,Stashes[id].items)
    end
end

RemoveItemFromStash = function(id,item,amount,slot)
    if Stashes[id] then 
        if slot then 
            if Stashes[id].items[slot] and Stashes[id].items[slot].name == item then 
                Stashes[id].items[slot].amount = Stashes[id].items[slot].amount - amount 
                if Stashes[id].items[slot].amount <= 0 then 
                    Stashes[id].items[slot] = nil 
                end
            else
                Stashes[id].items[slot] = nil
            end
        end
        SaveStash(id,Stashes[id].items)
    end
end

SaveStash = function(id,items)
    if items and id then 
        if Stashes[id] then
            InvFunctions.DBQuery("SELECT * FROM `inventories` WHERE `id` = '"..id.."'", function(result)
                if result[1] ~= nil then
                    InvFunctions.DBQuery("UPDATE `inventories` SET `data` = '"..json.encode(items).."' WHERE `id` = '"..id.."'")
                else
                    InvFunctions.DBQuery("INSERT INTO `inventories` (`id`, `data`) VALUES ('"..id.."', '"..json.encode(items).."')")
                end
            end)
        end
    end
end

GetStashItems = function(id) 
    local items = {}
    InvFunctions.DBQuery("SELECT * FROM `inventories` WHERE `id` = '"..id.."'", function(result)
        if result[1] then 
            result[1] = json.decode(result[1].data)
            if result[1] then 
                for k,v in pairs(result[1]) do 
                    items[v.slot] = v 
                end
            end
        end
    end)
    return items 
end

GetFreeSlot = function(id)
    if Stashes[id] then
        for i=1,Stashes[id].slots do
            if Stashes[id].items[i] == nil then 
                return i 
            end
        end
    end
end

GetNumberFromString = function(string)
    return tonumber(string.match(string, "%d+"))
end