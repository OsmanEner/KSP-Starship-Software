# Starship Launch Control System
## Common Functions
! All of the set variables will be listed at the top of the lib .ks file, some might be repeated here but its just to know for what they are used.
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
### Catch Arms Closing
```
set Mechazilla to ship:partsdubbed("MechazillaArms").

function CloseArms {
    FOR part IN Mechazilla{
        part:getmodule("ModuleSLEController"):Doevent("Close Arms").
        wait 4.
        part:getmodule("ModuleSLEController"):doaction("Stop Arms", true).
        wait 2.
        part:getmodule("ModuleSLEController"):Doevent("Close Arms").
    }
}
```
