// Common Functions Library
// --------------------------------------



// Common Variables
// --------------------------------------

set BoostbackBurnGuidance to false.

set ShipSLEngines to ship:partstagged("ShipSL").
set ShipVACEngines to ship:partstagged("ShipVAC").
set BoosterCluster to ship:partstagged("BoosterCluster").
set HSRRing to ship:partsdubbed("HSRDecoupler").

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
        set BoostbackBurnGuidance to true. // Use this variable to commence boostback guidance.
    }
}


