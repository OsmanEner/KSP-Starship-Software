# Starship Launch Control System
## Common Functions
### Ignite Engines
```
set ShipSLEngines to ship:partstagged("ShipSL").

for Engine in ShipSLEngines {
    Engine:activate().
}
```
### Check for Stage Separation
```
if ship:separators[7]:isdecoupled {
    print("w").
}
```
