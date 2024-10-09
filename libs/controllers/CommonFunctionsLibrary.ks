// Common Functions Library
// --------------------------------------



// Common Variables
// --------------------------------------

set stagesSeparated to false.

set ShipSLEngines to ship:partstagged("ShipSL").
set ShipVACEngines to ship:partstagged("ShipVAC").
set BoosterCluster to ship:partstagged("BoosterCluster").
set HSRRing to ship:partsdubbed("HSRDecoupler").
set StarshipBody to ship:partsdubbed("StarshipBody").
set BoosterBody to ship:partsdubbed("BoosterBody").
set WaterDeluge to ship:partsdubbed("WaterDeluge").
set Mechazilla to ship:partsdubbed("MechazillaArms").

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

function SeparationCommand {
    FOR part IN HSRRing{
        part:getmodule("ModuleDecouple"):Doevent("decouple").
        set stagesSeparated to true. // Tracks whether or not the ship & booster have separated .
    }
}

function StarshipStaticFireShutdown {
    for Engine in ShipSLEngines {
        Engine:shutdown().
    }
    for Engine in ShipVACEngines {
        Engine:shutdown().
    }
}

function StarshipStaticFireSafing {
    for Engine in StarshipBody {
        Engine:activate().
    }
    wait 15.
        for Engine in StarshipBody {
        Engine:activate().
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

function CloseArms {
    FOR part IN Mechazilla{
        part:getmodule("ModuleSLEController"):Doevent("Close Arms").
        wait 4.
        part:getmodule("ModuleSLEController"):doaction("Stop Arms", true).
        wait 2.
        part:getmodule("ModuleSLEController"):Doevent("Close Arms").
    }
}





