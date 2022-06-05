## AXFW's Inventory System

AXFW's Inventory System is standalone that means that it can be run on any server no matter what framework,
`You must have basic Lua knowledge to use the inventory system`
## Requirements

> **oxmysql**   [Link](https://github.com/overextended/oxmysql/)

## Creating/Registering Items
__inventory/main/shared.lua__
All the items must be put inside the Items table 
```lua
Shared = {
    PlayerWeight = 120000,
    Slots = 66,
    Items = {
        -- Place all items here
    },
}
```
Example of registering/creating an item
```lua
['water'] = {
      label = 'Water',
      weight = 1000,
      unique = false,
      Close = false,
      Use = function(item)
            print('Water Used',json.encode(item))
      end,
}
```
**label**  `type:string`\
**weight** `type:number`\
**unique** `type: boolean true/false`\
**Close**  `type: boolean true/false`\
**Use**    `type: function(executed client side,first argument/parameter returns item info)`
## Main
**Getting the functions**
```lua
InvFunctions = exports.inventory:GetInventoryFunctions()
```
**Getting Players**\
`Client Side`
```lua
local Player = InvFunctions.GetPlayer()
```
`Server Side`
```lua
local Player = InvFunctions.GetPlayer(source)
```
**source**  `type:number(player's id)`\
\
**Adding Items**\
`Server Side`
```lua
local Player = InvFunctions.GetPlayer(source)
Player.Functions.AddItem(name,amount,slot,info)
```

