# Starship Launch Control System
## Common Functions
### Ignite Engines
```
function SLShipIgnition {
    set ShipSLEngines to ship:partstagged("ShipSL").

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
SET CurrentVessel to SHIP.
set HSRRing to CurrentVessel:partsdubbed("HSRDecoupler").
function SeparationCommand {
    FOR part IN HSRRing{
        part:getmodule("ModuleDecouple"):Doevent("decouple").
    }
}
```
