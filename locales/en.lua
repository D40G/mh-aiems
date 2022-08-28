local Translations = {

    notify = {
        ['not_a_mechanic'] = "You are not a mechanic",
        ['services_is_use'] = "This service is already in use",
        ['in_transit'] = "The %{job} is on his way!",
        ['only_when_badly_injured'] = "You can only use this if you are very badly injured",
        ['you_were_cared'] = "You were cared for and you were billed: %{amount}",
        ['job_is_helping'] = "The %{job} is helping you",
        ['vehicle_is_restored'] = "Your vehicle has been restored, and you were billed: %{amount}",
        ['vehicle_is_teken'] = "Your vehicle has been taken by the towtruck company, and you were billed: %{amount}",
        ['to_much_ems_online'] = "There are tomany ems players online.",
        ['vehicle_unable_to_drive'] = "Your vehicle has to much damage, a towtruck is comming your way.",
        ['vehicle_can_drive'] = "Your vehicle is still able to drive, a mechanic is comming your way.",
        ['not_the_owner'] = "Your not the owner of this vehicle",
        ['stored_by_mechanic'] = "Your Vehicle is stored by the mechanic",
        ['area_is_obstructed'] = "This area is obstructed",
        ['is_in_vehicle'] = "You are already in a vehicle",
        ['off_duty'] = "You are not on duty",
    },
    
    menu = {
        ['header_menu'] = "Broken Vehicles List",
        ['store'] = "Park Vehicle",
        ['close_menu'] = "Sluit menu",
    },

    vehicle = {
        ['plate'] = "Plate: %{plate}<br>",
        ['fuel']  = "Fuel: %{fuel}%<br>",
        ['engine'] = "Engine: %{engine}%<br>",
        ['body']  = "Body: %{body}%<br>",
    },
    
    command = {
        ['callinfo'] = "Call an AI EMS Service",
    },
}

Lang = Locale:new({
    phrases = Translations, 
    warnOnMissing = true
})
