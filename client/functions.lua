Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}
BackEngineVehicles = {
    'ninef', 'adder', 'vagner', 't20', 'infernus', 'zentorno', 'reaper',
    'comet2', 'comet3', 'jester', 'jester2', 'cheetah', 'cheetah2', 'prototipo',
    'turismor', 'pfister811', 'ardent', 'nero', 'nero2', 'tempesta', 'vacca',
    'bullet', 'osiris', 'entityxf', 'turismo2', 'fmj', 're7b', 'tyrus',
    'italigtb', 'penetrator', 'monroe', 'ninef2', 'stingergt', 'surfer',
    'surfer2', 'comet3'
}
OpenTrunk = function()
    local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 127)
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Citizen.Wait(100)
    end
    TaskPlayAnim(GetPlayerPed(-1), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    if (IsBackEngine(GetEntityModel(vehicle))) then
        SetVehicleDoorOpen(vehicle, 4, false, false)
    else
        SetVehicleDoorOpen(vehicle, 5, false, false)
    end
end

CloseTrunk = function()
    local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 127)
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Citizen.Wait(100)
    end
    TaskPlayAnim(GetPlayerPed(-1), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
    if (IsBackEngine(GetEntityModel(vehicle))) then
        SetVehicleDoorShut(vehicle, 4, false)
    else
        SetVehicleDoorShut(vehicle, 5, false)
    end
end

IsBackEngine = function(veh)
    for _, model in pairs(BackEngineVehicles) do
        if GetHashKey(model) == veh then
            return true
        end
    end
    return false
end

GetPlayerWeight = function()
    local weight = 0
    local inventory = InvFunctions.GetPlayer().inventory
    for k,v in pairs(inventory) do 
        weight = 0
    end
    local percentage = (weight/1000)/(120000/100000)
    return percentage 
end

OpenHotbar = function()
    local inventory = InvFunctions.GetPlayer().inventory
    local items = {
        [1] = inventory[1],
        [2] = inventory[2],
        [3] = inventory[3],
        [4] = inventory[4],
        [5] = inventory[5],
        [6] = inventory[6],
    }
    SendNUIMessage({
        action = 'hotbar',
        items = items
    })
end