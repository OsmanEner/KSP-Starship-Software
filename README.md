# Starship Launch Control System
**VERSION: v1**

## Overview

This repository contains kOS scripts for the launch control system of a Starship replica in Kerbal Space Program (KSP).

## Common Information

### Launch Pad A Information

```
Pad Direction Information: Heading 20, Pitch 90, Roll 20
Pad Direction Pitchover: Heading 90, Pitch [SET], Roll 0
OLM Coordinates: Lat -0.260225864690855, Lon -74.5053157223163
```

## Common Functions

All `set` variables are listed at the top of the `CommonFunctionsLibrary.ks` file. Some might be repeated here for clarity.

### Ignite Engines

```kos
set ShipSLEngines to ship:partstagged("ShipSL").

function SLShipIgnition {
    for Engine in ShipSLEngines {
        Engine:activate().
    }
}
```

### Stage Separation Command

```kos
set HSRRing to ship:partsdubbed("HSRDecoupler").

function SeparationCommand {
    for part in HSRRing {
        part:getmodule("ModuleDecouple"):Doevent("decouple").
        set BoostbackBurnGuidance to true. // Initiate boostback guidance.
    }
}
```

### Change Booster Previous Engine Mode

```kos
set BoosterCluster to ship:partsdubbed("BoosterCluster").

function SwitchOverPreviousEngine {
    for part in BoosterCluster {
        part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
    }
}
```

### Change Booster Next Engine Mode

```kos
set BoosterCluster to ship:partsdubbed("BoosterCluster").

function SwitchOverNextEngine {
    for part in BoosterCluster {
        part:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
    }
}
```

### Catch Arms Closing

```kos
set Mechazilla to ship:partsdubbed("MechazillaArms").

function MechazillaCatchClose {
    FOR part IN Mechazilla{
        part:getmodule("ModuleSLEController"):Doevent("Close Arms").
        part:getmodule("ModuleSLEController"):setfield("Target Speed", 7).
        wait 4.
        part:getmodule("ModuleSLEController"):doaction("Stop Arms", true).
        part:getmodule("ModuleSLEController"):setfield("Target Speed", 2).
        wait 2.
        part:getmodule("ModuleSLEController"):Doevent("Close Arms").
    }
}
```

### Different Vessel Communications Receive

```kos
when not ship:messages:empty then {
  set received to ship:messages:pop.
  print received:content.
  MechazillaCatchClose().
}
```

### Different Vessel Communications Send

```kos
set CatchCommunications to vessel("[SpaceX] Booster 1 Pad").
set EstablishCatchCommunications to CatchCommunications:connection.
set message to "Arms".

if EstablishCatchCommunications:isconnected {
    if EstablishCatchCommunications:sendmessage(message) {
        print message.
    }
}
```

## Coding Conventions

### Naming

* **Functions:** `PascalCase` (e.g., `BoostbackScript`)
* **Variables:** `camelCase` (e.g., `isBoostbackActive`)
* **Constants:** `UPPER_SNAKE_CASE` (e.g., `TARGET_APOAPSIS`)

### Style

* Consistent indentation (4 spaces recommended).
* Remove unnecessary blank lines.
* Comments to explain complex logic.
* Define constants for reusable values. Avoid magic numbers.
* Keywords in lowercase (e.g., `global`, `lock`, `function`, `set`, `wait`, `until`).

### Messaging

* Inter-ship/stage messages: `snake_case` (e.g., `"booster_boostback_burn"`).

## Usage

This project is for private use.  Usage instructions will be added later.

## License

This project doesn't yet have a license.
