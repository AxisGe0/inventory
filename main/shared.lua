Shared = {
    PlayerWeight = 120000,
    Slots = 66,
    Debug = true,
    Items = {
        ['lockpick'] = {
            label = 'Lockpick',
            weight = 1000,
            unique = false,
            Close = false,
            Decaytime = 60,
            Use = function(item)
                print('Lockpick Used',json.encode(item))
            end,
        },
        ['water'] = {
            label = 'Water',
            weight = 1000,
            unique = false,
            Close = false,
            Decaytime = 60,
            Use = function(item)
                print('Water Used',json.encode(item))
            end,
        }
    },
}
if not Shared.Debug then 
    print = function() end
end

GetQualityPercentage = function(item,time)
    local current = os.time() 
    if not Shared.Items[item].Decaytime then 
        return 100 
    end
    local percentage = 100 - math.ceil((((current - time) / Shared.Items[item].Decaytime) * 100))
    return percentage > 0 and percentage or 0
end