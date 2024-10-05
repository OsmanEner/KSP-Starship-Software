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
```
// These two can be defined as wanted in the code, just
// ensure that HSRRing is your separator part.
set HSRRing to ship:partsdubbed("HSRDecoupler").

function SeparationCommand {
    FOR part IN HSRRing{
        part:getmodule("ModuleDecouple"):Doevent("decouple").
    }
}
```
### Change Booster Previous Engine Mode
```
function PreviousBoosterMode {
    toggle ag9.
}
```
### Change Booster Next Engine Mode
```
function NextBoosterMode {
    toggle ag10.
}
```
