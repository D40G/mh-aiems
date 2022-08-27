## MH AI EMS Services
- When there are no ems players online to help your players.
- this also works for the mechanic job, they have a work menu in F1 to spawn the broken vehicles,
- this is only possible if a towtruck has take your vehicle to the mechanic. 


## Dependencies
- [oxmysql](https://github.com/overextended/oxmysql/releases/tag/v1.9.3)
- [qb-core](https://github.com/qbcore-framework/qb-core)


## Optional
- [qb-radialmenu](https://github.com/qbcore-framework/qb-radialmenu)

![foto1](https://naskho.org/images/ReadPlease.gif)

## How to install
- Copy the `table` from `mh-aiems.sql` to your database
- Copy the folder `mh-aiems` to `resources/[qb]/`
- press in game F8 and type `refresh` then `ensure mh-aiems` or restart your server.


## User Commands
- `/callai mechanic`
- `/callai towtruck`
- `/callai ambulance` 


## How it works
- The ambulance only works if you are dead or in last-stand.
- The mechanic only works if your vehicle engine damage is above 150 health (it's still possible to drive)
- The towtruck only works if yout vehicle engine damage is below 150 health (it's not possible to drive)


## What does the towtruck and recover works?
- when your vehicle is taken by the towtruck, it wil be saved the database,
- so the mechanic job can spawn this vehicle and fix it for you, if this player is online,
- only the mechanic job can recover the vehicle from the database,
- so have enough mechanics on your server, or the players will not get their vehicle back.


## Add in `qb-radialmenu/config.lua` around line 296
- change the `3` if you have more items.
```lua
    [3] = {
        id = 'aiemsservices',
        title = 'AI EMS Service',
        icon = 'bell',
        items = {
            {
                id = 'callambulance',
                title = 'Call Ambulance',
                icon = 'bell',
                type = 'client',
                event = 'mh-aiems:client:callambulance',
                shouldClose = true
            }, {
                id = 'callmechanic',
                title = 'Call Mechanic',
                icon = 'bell',
                type = 'client',
                event = 'mh-aiems:client:callmechanic',
                shouldClose = true
            }, {
                id = 'calltowtruck',
                title = 'Call Tow Truck',
                icon = 'bell',
                type = 'client',
                event = 'mh-aiems:client:calltowtruck',
                shouldClose = true
            },
        }
    }
```

## Add for Mechanic job in `qb-radialmenu/config.lua` around line 586
```lua
{
    id = 'brokenvehicles',
    title = 'Broken Vehicles',
    icon = 'car',
    type = 'client',
    event = 'mh-aiems:client:getBrokenVehicles',
    shouldClose = true
},
```
