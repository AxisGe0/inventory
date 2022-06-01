Shared = {
    PlayerWeight = 120000,
    Slots = 66,
    Items = {
        ['lockpick'] = {
            label = 'Lockpick',
            weight = 1000,
            unique = false,
            Close = false,
            Use = function(item)
                print('Lockpick Used',json.encode(item))
            end,
        },
        ['water'] = {
            label = 'Water',
            weight = 1000,
            unique = false,
            Close = false,
            Use = function(item)
                print('Water Used',json.encode(item))
            end,
        }
    },
}