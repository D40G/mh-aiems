## MH AI EMS Services
- When there are no ems players online to help your players.
- this also works for the mechanic job, they have a work menu in F1 to spawn the broken vehicles,
- this only is possible if a towtruck has take your vehicle to the mechanic. 


## Dependencies
- [oxmysql](https://github.com/overextended/oxmysql/releases/tag/v1.9.3)
- [qb-core](https://github.com/qbcore-framework/qb-core)


## Optional
- [qb-radialmenu](https://github.com/qbcore-framework/qb-radialmenu)


## How to install
- Copy the `table` from `mh-aiems.sql` to your database
- Copy the folder `mh-aiems` to `resources/[qb]/`
- press in game F8 and type `refresh` then `ensure mh-aiems` or restart your server.


## User Commands
- `/callai mechanix`
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
- only mechanics can fix this vehicle, with the F1 job menu.
- so if your vehicle does not get fix. you have to wait untill a mechanic fix your vehicle with the F1 job menu.
- cause in real live your vehicle also is stored by the mechanic is you let it tow,
- this script does the same thing.
 

## The payment
- the payment only happens when the job is done, this because if the job doesnot spawn in you lose money,
- so i build it like this so you never lose monay again when the ped and his vehicle does not spawn in.


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
{
    id = 'fixbrokenvehicles',
    title = 'Fix Vehicles',
    icon = 'car',
    type = 'client',
    event = 'mh-aiems:client:FixVehicle',
    shouldClose = true
},
```

## Database Table
```sql
CREATE TABLE IF NOT EXISTS `broken_player_vehicles` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `plate` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vehicle` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mods` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
```
