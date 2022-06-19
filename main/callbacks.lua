local Callbacks = {}
RegisterCallback = function(name,cb)
    for k,v in pairs(Callbacks) do 
        if v.name == name then 
            RemoveEventHandler(v.handler)
            print('Updating Function For The Following Callback',name)
            Callbacks[k] = nil
        end
    end
    RegisterNetEvent('TriggerCallback:Server'..name)
    local handler = AddEventHandler('TriggerCallback:Server'..name,function(...)
        local src = source
        cb(source,function(...)
            TriggerClientEvent('TriggerCallback:Client'..name,src,...)
        end,...)
    end)
    table.insert(Callbacks,{name=name,handler=handler})
end
TriggerCallback = function(name,cb,...)
    RegisterNetEvent('TriggerCallback:Client'..name)
    local handler = AddEventHandler('TriggerCallback:Client'..name,function(...)
        cb(...)
    end)
    TriggerServerEvent('TriggerCallback:Server'..name,...)
    CreateThread(function()
        Wait(500)
        RemoveEventHandler(handler)
    end)
end