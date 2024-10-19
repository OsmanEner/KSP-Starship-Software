// Import required libraries
runoncepath("0:/libraries/utilities/importLibs").
importLib("landingDataModel").
importLib("hoverSlamModel").
importLib("glideController").
importLib("landingController").
importLib("ascentController").
importLib("boostbackController").

// Constants and initial setup
set LANDING_SITE to latlng(-0.0972080884740584, -74.5576970966038).
//set BOOSTER_HEIGHT to 45.6.
set BOOSTER_HEIGHT to 60.
set BOOSTBACK_SWITCH_THRESHOLD to 85.
set LQMethaneCutoff to 11000.

// Ship parts
set boosterEngines to SHIP:PARTSNAMED("SEP.23.BOOSTER.CLUSTER").
set gridFins to SHIP:PARTSNAMED("SEP.23.BOOSTER.GRIDFIN").
for part in ship:parts {
    if part:name:contains("SEP.23.BOOSTER.INTEGRATED") {
        set BoosterCore to part.
        break.
    }
}

// Helper functions
function ToggleGridfins {
    parameter newState.

    for fin in GridFins {
        if fin:hasmodule("ModuleControlSurface") {
            if newState = true {
                fin:getmodule("ModuleControlSurface"):DoAction("activate all controls", true).
            } else if newState = false {
                fin:getmodule("ModuleControlSurface"):DoAction("deactivate all controls", false).
            }
        }
    }
}

function SetGridFinAuthority {
    parameter x.
    for fin in GridFins {
        for module in list("ModuleControlSurface", "SyncModuleControlSurface") {
            if fin:hasmodule(module) {
                fin:getmodule(module):SetField("authority limiter", x).
            }
        }
    }
}

// Initialize landing data model and set initial fin authority
local landingData is landingDataModel(LANDING_SITE).
SetGridFinAuthority(32).

// Boostback phase
boosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
rcs on.

// Boostback adapter steering manager
set SteeringManager:ROLLCONTROLANGLERANGE to 0.
set SteeringManager:rollts to 5.

local boostback is boostbackController(landingData, 5, 1000, 0.6).
lock steering to boostback["getSteering"]().
wait 8. // Safety wait
lock throttle to boostback["getThrottle"]().

local boostbackEngineSwitched to false.
when boostback["getStatus"]() >= BOOSTBACK_SWITCH_THRESHOLD and not boostbackEngineSwitched then {
    boosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
    set boostbackEngineSwitched to true.
}

wait until boostback["completed"]().
lock throttle to 0.

// Switch engines
boosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
boosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).

// Methane management
local methaneResource is 0.
for res in BoosterCore:resources {
    if res:name = "LqdMethane" {
        set methaneResource to res.
        break.
    }
}

if methaneResource <> 0 {
    if methaneResource:amount > LQMethaneCutoff {
        BoosterCore:activate.
    }
    when methaneResource:amount < LQMethaneCutoff then {
        BoosterCore:shutdown.
    }
} else {
    print "LqdMethane resource not found on BoosterCore!".
}

// Post-boostback steering manager settings
set SteeringManager:pitchtorquefactor to 1.
set SteeringManager:yawtorquefactor to 1.
set steeringManager:TORQUEEPSILONMAX to 0.05.

// Gliding phase
global glide is glideController(landingData, 60, 1).
lock steering to heading(90, 90, 36).
ToggleGridfins(true).
wait until alt:radar <= 30000.
rcs off.
brakes on.
lock steering to glide["getSteering"]().

// Landing prep
local hoverslam is hoverSlamModel(BOOSTER_HEIGHT, -1, 41, 2200).
global landing is landingController(landingData, hoverslam, 2, 1).

// Powered landing phase
wait until alt:radar <= 2200.
SetGridFinAuthority(3).
lock throttle to landing["getThrottle"]().
lock steering to landing["getSteering"]().

when ship:verticalspeed > -30 then {
    boosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
    set steeringManager:rolltorquefactor to 0.75.
    SetGridFinAuthority(2.5).
}

when ship:verticalspeed > -3 then { lock throttle to 0. }

wait until landing["completed"]().
lock throttle to 0.
wait until false.

// TODO : Final landing phase hover over tower.
// Above might just be fixed by using hoverslam model.
// TODO : Maybe use PID for gliding.