# Starship Launch Control System
## Common Information

### Launch Pad A Information
```
Pad Direction Information: Heading 0, Pitch 90, Roll 36
Pad Direction Pitchover: Heading 90, Pitch [SET], Roll 0
OLM Coordinates: Lat - -0.260225864690855 // Lon - -74.5053157223163 
```

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
### Stage Separation Command
```
set HSRRing to ship:partsdubbed("HSRDecoupler").

function SeparationCommand {
    FOR part IN HSRRing{
        part:getmodule("ModuleDecouple"):Doevent("decouple").
        set BoostbackBurnGuidance to true. // Use this variable to commence boostback guidance.
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
