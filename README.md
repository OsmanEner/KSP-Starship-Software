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
// ensure that CurrentVessel is a valid ship and
// HSRRing is your separator part.
SET CurrentVessel to SHIP.
set HSRRing to CurrentVessel:partsdubbed("HSRDecoupler").

function SeparationCommand {
    FOR part IN HSRRing{
        part:getmodule("ModuleDecouple"):Doevent("decouple").
    }
}
```
