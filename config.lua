-------------------
-- CONFIG --
-------------------
Config = {}

Config.MinDamageToUseTowTruck = 150 
Config.KeyScriptTrigger = "qb-vehiclekeys:server:AcquireVehicleKeys"

Config.Ped = {

    ['ambulance'] = {
        job          = "ambulance",
        vehicle      = "ambulance",
        pedModel     = "S_M_M_DOCTOR_01",
        animation    = "cpr_pumpchest",
        drivingStyle = 524863, -- you can change the drivestyle for the ped here: https://vespura.com/fivem/drivingstyle/
        walkingStyle = 786603,
        spawnRadius  = 100,    -- don't go higher than 200
        workTime     = 15000,
        price        = 1000,
    },

    ['mechanic'] = {
        job          = "mechanic",
        vehicle      = "towtruck",
        pedModel     = "S_M_M_TRUCKER_01",
        animation    = "PROP_HUMAN_BUM_BIN",
        bone         = "engine", 
        drivingStyle = 524863, -- you can change the drivestyle for the ped here: https://vespura.com/fivem/drivingstyle/
        walkingStyle = 786603,
        spawnRadius  = 100,    -- don't go higher than 200
        workTime     = 15000,
        price        = 1000,
    },

    ['towtruck'] = {
        job          = "towtruck",
        vehicle      = "flatbed",
        pedModel     = "S_M_M_TRUCKER_01",
        animation    = "PROP_HUMAN_BUM_BIN",
        bone         = "engine", 
        drivingStyle = 524863, -- you can change the drivestyle for the ped here: https://vespura.com/fivem/drivingstyle/
        walkingStyle = 786603,
        spawnRadius  = 100,    -- don't go higher than 200
        workTime     = 15000,
        price        = 1500,
        offset = {    -- for the vehicle position on the flatbed
            x = -0.5, -- left/right
            y = -5.0, -- front/back
            z = 1.0,  -- up/down
        },
    },
}
