local Functions,Players = {},{}
if IsDuplicityVersion() then 
    Functions.DBQuery = function(query,cb)
        local data = exports.oxmysql:fetchSync(query)
        if cb then
            cb(data)
        end
        return data
    end
    Functions.GetPlayer = function(src)
        local identifier = GetPlayerIdentifier(src)
        if not Players[src] then 
            Players[src] = {Functions={},inventory={}}
            local self = Players[src]
            Functions.DBQuery("SELECT * FROM `player-inventory` WHERE `identifier`='"..identifier.."'",function(result)
                if result and result[1] then
                    for k,v in pairs(json.decode(result[1].inventory)) do 
                        v.slot = tonumber(v.slot)
                        self.inventory[v.slot] = v
                    end 
                end
            end)
            self.Functions.Set = function(items)
                self.inventory = items 
                return true
            end
            self.Functions.CanCarryItem = function(item,amount)
                local weight = 0
                for k,v in pairs(self.inventory) do
                    local iteminfo = Shared.Items[v.name] 
                    if iteminfo then 
                        weight = weight + (iteminfo.weight*v.amount)
                    end
                end
                if (weight+(Shared.Items[item].weight)*amount) <= Shared.PlayerWeight then
                    return true
                end
                return false
            end
            self.Functions.GetFreeSlot = function()
                local inventory = self.inventory
                for i=1,Shared.Slots do 
                    if inventory[i] == nil then 
                        return i 
                    end
                end
                return nil
            end
            self.Functions.GetItem = function(item,slot)
                local slot = tonumber(slot)
                if slot then 
                    return self.inventory[slot] and table.clone(self.inventory[slot])
                else
                    for k,v in pairs(self.inventory) do 
                        if v.name == item then 
                            return self.inventory[v.slot] and table.clone(self.inventory[v.slot])
                        end
                    end
                end
                return nil
            end
            self.Functions.AddItem = function(item,amount,slot,info)
                local info = info or {quality=100}
                if not info.startdate then info.startdate = os.time() end 
                local amount = tonumber(amount)
                local slot = tonumber(slot) or nil
                if not Shared.Items[item] then print('Item Not Found') return false end
                if not self.Functions.CanCarryItem(item,amount) then return false end
                if slot then 
                    if self.inventory[slot] and self.inventory[slot].name == item then 
                        if string.find(string.lower(item),'weapon') or info.quality ~= self.inventory[slot].info.quality or Shared.Items[item].unique then 
                            local freeslot = self.Functions.GetFreeSlot()
                            if freeslot then 
                                self.inventory[freeslot] = {
                                    name = item,
                                    amount = amount,
                                    slot = freeslot,
                                    info = info,
                                    label = Shared.Items[item].label
                                }
                                return true
                            end
                        else
                            self.inventory[slot].amount = self.inventory[slot].amount + amount 
                            return true
                        end
                    else
                        self.inventory[slot] = {
                            name = item,
                            amount = amount,
                            slot = slot,
                            info = info,
                            label = Shared.Items[item].label
                        }
                        return true
                    end
                else 
                    local existingitem = self.Functions.GetItem(item)
                    if existingitem then 
                        if string.find(string.lower(item),'weapon') or info.quality ~= existingitem.info.quality or Shared.Items[item].unique then 
                            local freeslot = self.Functions.GetFreeSlot()
                            if freeslot then 
                                self.Functions.AddItem(item,amount,freeslot,info)
                                return true
                            end
                        else
                            existingitem.amount = existingitem.amount + amount
                            return true
                        end
                    else
                        local nextslot = self.Functions.GetFreeSlot()
                        if nextslot then 
                            self.inventory[nextslot] = {
                                name = item,
                                amount = amount,
                                slot = nextslot,
                                info = info,
                                label = Shared.Items[item].label
                            }
                            return true
                        end
                    end
                end
                return false
            end
            self.Functions.RemoveItem = function(item,amount,slot)
                local amount = tonumber(amount)
                local slot = tonumber(slot) or nil
                if slot then 
                    if self.inventory[slot] and self.inventory[slot].name == item then 
                        self.inventory[slot].amount = self.inventory[slot].amount - amount 
                        if self.inventory[slot].amount <= 0 then 
                            self.inventory[slot] = nil
                        end
                        return true
                    end
                else 
                    for k,v in pairs(self.inventory) do 
                        if v.name == item and v.amount >= amount then 
                            self.inventory[v.slot].amount = self.inventory[v.slot].amount - amount 
                            if self.inventory[v.slot].amount <= 0 then 
                                self.inventory[v.slot] = nil
                            end 
                            return true
                        end
                    end
                end
                return false
            end
            self.Functions.Save = function()
                Functions.DBQuery("UPDATE `player-inventory` SET `inventory`='"..json.encode(self.inventory).."' WHERE `identifier`='"..identifier.."' ")
                return true
            end
        end
        for k,v in pairs(Players[src].inventory) do
            v.info.quality = GetQualityPercentage(v.name,v.info.startdate or os.time())
        end
        return Players[src]
    end
    RegisterCallback('AXFW:Inventory:GetPlayer',function(source,cb)
        cb(Functions.GetPlayer(source))
    end)
else 
    Functions.GetPlayer = function()
        local p = promise:new()
        TriggerCallback('AXFW:Inventory:GetPlayer',function(data) p:resolve(data) end)
        local retval = Citizen.Await(p)
        return retval 
    end
end

GetInventoryFunctions = function()
    return Functions
end

exports('GetInventoryFunctions',GetInventoryFunctions)