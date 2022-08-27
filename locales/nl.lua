local Translations = {
    
    notify = {
        ['not_a_mechanic'] = "Je bent geen monteur",
        ['services_is_use'] = "Deze dienst is al in gebruik",
        ['in_transit'] = "De %{job} is onderweg!",
        ['only_when_badly_injured'] = "Je kunt dit alleen gebruiken als je erg zwaargewond bent",
        ['you_were_cared'] = "Er werd voor u gezorgd en u werd gefactureerd: %{amount}",
        ['job_is_helping'] = "De %{job} helpt je",
        ['vehicle_is_restored'] = "Uw voertuig is gerestaureerd en u heeft een factuur ontvangen: %{amount}",
        ['vehicle_is_teken'] = "Uw voertuig is meegenomen door het takelbedrijf en u bent gefactureerd: %{amount}",
        ['to_much_ems_online'] = "Er zijn heel veel ems-spelers online.",
        ['vehicle_unable_to_drive'] = "Uw voertuig heeft te veel schade, er komt een takelwagen uw kant op.",
        ['vehicle_can_drive'] = "Uw voertuig kan nog rijden, er komt een monteur uw kant op.",
        ['not_the_owner'] = "Je bent niet de eigenaar van dit voertuig",
        ['stored_by_mechanic'] = "Uw Voertuig wordt gestald door de monteur",
        ['area_is_obstructed'] = "Het gebied word belemmerd",
        ['is_in_vehicle'] = "Je zit al in een voertuig",
    },
    
    menu = {
        ['header_menu'] = "Kapoten veortuigen Lijst",
        ['store'] = "Pakeer Voertuig",
        ['close_menu'] = "Sluit menu",
    },

    vehicle = {
        ['plate'] = "Kenteken: %{plate}<br>",
        ['fuel']  = "Brandstof: %{fuel}%<br>",
        ['engine'] = "Motor: %{engine}%<br>",
        ['body']  = "Body: %{body}%<br>",
    },
    
    command = {
        ['callinfo'] = "Bel een AI EMS-service",
    }
}

Lang = Locale:new({
    phrases = Translations, 
    warnOnMissing = true
})