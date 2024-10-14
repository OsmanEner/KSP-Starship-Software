// Common Functions Library
// --------------------------------------



// Common Variables
// --------------------------------------

set stagesSeparated to false.
set starshipAbortAvailable to false.

set ShipSLEngines to ship:partstagged("ShipSL").
set ShipVACEngines to ship:partstagged("ShipVAC").
set BoosterCluster to ship:partstagged("BoosterCluster").
set HSRRing to ship:partsdubbed("HSRDecoupler").
set StarshipBody to ship:partsdubbed("StarshipFlightSoftware").
set BoosterBody to ship:partsdubbed("BoosterFlightSoftware").
set WaterDeluge to ship:partsdubbed("WaterDeluge").
set Mechazilla to ship:partsdubbed("MechazillaArmsSoftware").

// Functions Library
// --------------------------------------

function SLShipIgnition {
    for Engine in ShipSLEngines {
        Engine:activate().
    }
}

function VACShipIgnition {
    for Engine in ShipVACEngines {
        Engine:activate().
    }
}

function SwitchOverPreviousEngine {
    FOR part IN BoosterCluster{
        part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
    }
}

function SwitchOverNextEngine {
    FOR part IN BoosterCluster{
        part:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
    }
}

function SuperHeavyIgnition {
    for Engine in BoosterCluster {
        Engine:activate().
    }
}

function SuperHeavyShutdown {
    for Engine in BoosterCluster {
        Engine:shutdown().
    }
}

function SeparationCommand {
    FOR part IN HSRRing{
        part:getmodule("ModuleDecouple"):Doevent("decouple").
        set stagesSeparated to true. // Tracks whether or not the ship & booster have separated .
    }
}

function StarshipShutdown {
    lock throttle to 0.2.
    for Engine in ShipSLEngines {
        Engine:shutdown().
    }
    wait 2.
    for Engine in ShipVACEngines {
        Engine:shutdown().
    }
}

function BoosterSafing {
    for Engine in BoosterBody {
        Engine:activate().
    }
    wait 15.
        for Engine in StarshipBody {
        Engine:shutdown().
    }
}

function StarshipSafing {
    for Engine in StarshipBody {
        Engine:activate().
    }
    wait 15.
        for Engine in StarshipBody {
        Engine:shutdown().
    }
}

function WaterDelugeActivation {
    for Engine in WaterDeluge {
        Engine:activate().
    }
}

function WaterDelugeShutdown {
    for Engine in WaterDeluge {
        Engine:shutdown().
    }
}

function MechazillaCatchClose {
    FOR part IN Mechazilla{
        part:getmodule("ModuleSLEController"):Doevent("Close Arms").
        part:getmodule("ModuleSLEController"):setfield("Target Speed", 7).
        wait 1.
        part:getmodule("ModuleSLEController"):setfield("Target Speed", 9).
        wait 1.
        part:getmodule("ModuleSLEController"):setfield("Target Speed", 5).
        wait 1.
        part:getmodule("ModuleSLEController"):setfield("Target Speed", 3).
        part:getmodule("ModuleSLEController"):doaction("Stop Arms", true).
        wait 2.
        part:getmodule("ModuleSLEController"):Doevent("Close Arms").
        part:getmodule("ModuleSLEController"):setfield("Target Speed", 2).
    }
}

function StarshipAbort {
    if starshipAbortAvailable = true {
        print "Starship Abort System Initiation".
        print "----------------------------------------".
        lock throttle to 0.
        shutdown.

    } else {
        print "Starship Abort Bypass // Variable Not Found".
        print "----------------------------------------".
    }
}

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







