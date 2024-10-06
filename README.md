# Starship Launch Control System
## Common Functions
### Ignite Engines
```
set ShipSLEngines to ship:partstagged("ShipSL").

function SLShipIgnition {
    for Engine in ShipSLEngines {
        Engine:activate().
    }
}
```
### Check for Stage Separation
```
function SeparationCheck {
    if ship:separators[7]:isdecoupled {
        print("w").
    }
}
```
### Stage Separation Command
These two can be defined as wanted in the code, just
ensure that HSRRing is your separator part.
```
set HSRRing to ship:partsdubbed("HSRDecoupler").

function SeparationCommand {
    FOR part IN HSRRing{
        part:getmodule("ModuleDecouple"):Doevent("decouple").
    }
}
```
### Change Booster Previous Engine Mode
```
set BoosterCluster to ship:partsdubbed("BoosterCluster").

function SwitchOverPreviousEngine {
    FOR part IN BoosterCluster{
        part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
    }
}
```
### Change Booster Next Engine Mode
```
set BoosterCluster to ship:partsdubbed("BoosterCluster").

function SwitchOverNextEngine {
    FOR part IN BoosterCluster{
        part:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
    }
}
```
