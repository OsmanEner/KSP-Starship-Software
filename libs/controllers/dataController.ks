// Common Functions Library
// --------------------------------------


// Data Readouts
// --------------------------------------

function StarshipLogging{
    log "// ------------------------------------------" to dataStarshipController.txt.
    log "// ---- Data Logging Packet // Starship ----" to dataStarshipController.txt.
    log "// ------------------------------------------" to dataStarshipController.txt.
    log time + " // dataController Packet Time" to dataStarshipController.txt.
    log ship:altitude + " // dataController Altitude" to dataStarshipController.txt.
    log ship:velocity + " // dataController Velocity" to dataStarshipController.txt.
    log ship:apoapsis + " // dataController Apogee" to dataStarshipController.txt.
    log ship:periapsis + " // dataController Apogee" to dataStarshipController.txt.
    log ship:deltav:current + " // dataController Delta-V Remaining" to dataStarshipController.txt.
    log orbit:inclination + " // dataController Orbit Inclination" to dataStarshipController.txt.
    log geoPosition + " // dataController Vehicle Position" to dataStarshipController.txt.
}

function SuperHeavyLogging{
    log "// ------------------------------------------" to dataBoosterController.txt.
    log "// ---- Data Logging Packet // Booster ----" to dataBoosterController.txt.
    log "// ------------------------------------------" to dataBoosterController.txt.
    log time + " // dataController Packet Time" to dataBoosterController.txt.
    log ship:altitude + " // dataController Altitude" to dataBoosterController.txt.
    log ship:velocity + " // dataController Velocity" to dataBoosterController.txt.
    log ship:apoapsis + " // dataController Apogee" to dataBoosterController.txt.
    log ship:periapsis + " // dataController Apogee" to dataBoosterController.txt.
    log ship:deltav:current + " // dataController Delta-V Remaining" to dataBoosterController.txt.
    log orbit:inclination + " // dataController Orbit Inclination" to dataBoosterController.txt.
    log geoPosition + " // dataController Vehicle Position" to dataBoosterController.txt.
}







