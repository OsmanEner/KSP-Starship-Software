// ---------------------------------
// Stage 1 Super Heavy Software
// ---------------------------------

clearscreen.

runoncepath("0:/StarshipLibraries/utilities/importLib").
importLib("landingDataModel").
importLib("hoverSlamModel").
importLib("glideController").
importLib("landingController").
importLib("ascentController").
importLib("stagingController").
importLib("tguidanceController").
importLib("boostbackController").

// ---------------------------------
// Terminal Countdown Controller
// ---------------------------------

local LaunchStatus to false.
local terminalCountdown to 10.
local abortMode to false.

lock steering to heading(36, 90, 36).

local BoosterEngines to ship:partstagged("BoosterCluster").
local WaterDeluge to ship:partsdubbed("WaterDeluge").
local OLMSeparation to ship:partsdubbed("DSS").
local TowerQD to ship:partsdubbed("QuickDisconnect"). unused

function terminalComplete {
    if LaunchStatus = true {
        wait 0.01.
        return true.
    }
    return false.
}

// ---------------------------------
// Super Heavy Ascent Modes
// ---------------------------------

wait until ag1.

until LaunchStatus {
    wait 1.
    set terminalCountdown to terminalCountdown - 1.

    if terminalCountdown = 5 {
        lock throttle to 0.7.
        for Engine in WaterDeluge {
            Engine:activate().
        }
    }

    if terminalCountdown = 2 {
        for Engine in BoosterEngines {
            Engine:activate().
        }
        for part in BoosterEngines {
            part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
            wait 1.
            part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
        }
    }

    if terminalCountdown = 0 {
        for Engine in BoosterEngines {
            if Engine:ignition = true {
                set LaunchStatus to true.
            } else if Engine:ignition = false {
                set abortMode to true.
            }
            if Engine:thrust > 6539 {
                set LaunchStatus to true.
            } else if Engine:thrust < 6539 {
                set abortMode to true.
            }
        }
    }

    if terminalCountdown = -1 {
        if abortMode = true {
            unlock throttle.
            lock throttle to 0.
            for Engine in BoosterEngines {
                Engine:shutdown().
            }
            for Engine in WaterDeluge {
                Engine:shutdown().
            }
        }
    }

    if terminalCountdown = -2 {
        OLMSeparation:getmodule("ModuleAnimateGeneric"):doevent("close clamps + qd").
        TowerQD:getmodule("ModuleSLEAnimate"):doevent("Full Retraction").
        for Engine in WaterDeluge {
            Engine:shutdown().
        }
        OLMSeparation:getmodule("ModuleDockingNode"):doevent("Undock").
        set LaunchStatus to true.
    }
}

wait until terminalComplete().

local ascentMode is ascentController().
wait until ascentMode["completed"]().

local hotstageMode is stagingController().
lock throttle to 0.7.
wait until hotstageMode["completed"]().


// ---------------------------------
// Super Heavy Landing Modes
// ---------------------------------

// Constants and initial setup
set LANDING_SITE to latlng(-0.260225864690855, -74.5053157223163).
set BOOSTBACK_SWITCH_THRESHOLD to 85.
set LQMethaneCutoff to 11000.
set CatchVerticalSpeed to -0.3.
set BoosterHeight to 46.8 + 45. // first number is actual booster height (without HSR), second number is desired landing altitude.
// VERY HACKY, to be fixed either pre-flight if really possible, or can be fixed on flight 2, since it isn't gonna directly
// cause issues, but can be tricky to work with in the future, especially for rewrites.
// Additionally, it's supposed to be a constant, making it weird to work with IN GENERAL...
set FinalDeceleration to 7.5.
set RectificationFactor to 0.725.
set PIDSensitivityFactor to 5.
set RollHeadingVector to heading(270,0):vector. // Final wanted roll/hdg for catch.
set steeringManager:maxstoppingtime to 15. // Smoother and faster roll, experimental.

// SEP Constants, thanks Janus :D
set BoosterReturnMass to 135.8.
set BoosterRaptorThrust to 673.

// Global variables
global LandingBurnStarted is false.
global maximumDeccelerationFactor is 0.
global landingRatio is 0.
global shouldHover is false.
global CenterEnginesDeccelTime is 0.
global InnerRingSwitch is false.
global InitialError is -9999.
global LatitudeControlPIDoutput is 0.
global LongitudeControlPIDoutput is 0.

// Pre-execution locks
lock PlanetGravityRelativeToShip to CONSTANT():G * (ship:body:mass / (ship:body:radius * ship:body:radius)).
lock ApproachVector to vxcl(up:vector, LANDING_SITE:position - ship:position):normalized.
lock TrueAltitude to alt:radar - BoosterHeight.

// PID Controllers
// Could be tweaked as of the date of this comment.
set LatitudeControlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
set LongitudeControlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
set LongitudeControlPID:setpoint to 50.

// SEP Booster parts
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

function LandingThrottle {
    if verticalspeed > CatchVerticalSpeed {
        set minDecel to (PlanetGravityRelativeToShip - 0.025) / (max(ship:availablethrust, 0.000001) / ship:mass * 1/cos(vang(-velocity:surface, up:vector))).
        set shouldHover to true.
        return minDecel.
    }
    wait 0.001.
    return max((landingRatio * min(maximumDeccelerationFactor, 50)) / maximumDeccelerationFactor, 0.33).
}

// Initialize landing data model and set initial fin authority
local landingData is landingDataModel(LANDING_SITE).
SetGridFinAuthority(32).

// Initialize important variables from landing data model.
set ErrorVector to landingData["errorVector"]().
lock LatError to landingData["latError"]().
lock LngError to landingData["lngError"]().

// Main program
// (I added the comments for easier navigation since this is a big script)
function MainProgram {
    // Boostback phase
    BoostbackPhase().

    // Gliding phase
    GlidingPhase().

    // Landing phase
    LandingPhase().

    // Post-landing
    PostLanding().
}

function BoostbackPhase {
    boosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
    rcs on.

    // Boostback adapter steering manager
    set SteeringManager:ROLLCONTROLANGLERANGE to 0.
    set SteeringManager:rollts to 5.

    local boostback is boostbackController(landingData, 5, 1000, 0.6).
    lock steering to boostback["getSteering"]().
    wait 4. // Safety wait
    lock throttle to boostback["getThrottle"]().

    local boostbackEngineSwitched to false.
    when boostback["getStatus"]() >= BOOSTBACK_SWITCH_THRESHOLD and not boostbackEngineSwitched then {
        boosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
        set boostbackEngineSwitched to true.
        set SteeringManager:ROLLCONTROLANGLERANGE to 10.
    }

    wait until boostback["completed"]().
    lock throttle to 0.
    set SteeringManager:ROLLCONTROLANGLERANGE to 180.

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
    }

    // Post-boostback steering manager settings
    set SteeringManager:pitchtorquefactor to 1.
    set SteeringManager:yawtorquefactor to 1.
    set steeringManager:TORQUEEPSILONMAX to 0.05.
}

function GlidingPhase {
    set glide to glideController(landingData, 20, 1.2).
    lock steering to heading(90, 90, 36).

    when alt:radar <= 55000 then { rcs off. }

    wait until alt:radar <= 30000.
    ToggleGridfins(true).
    brakes on.
    lock steering to glide["getSteering"]().

    until landingRatio > 1 and alt:radar < 2000 {
        SteeringCorrections().
        wait 0.1.
    }
}

function LandingPhase {
    // Catch message handling, sending to the stage 0 CPU
    set CatchCommunications to vessel("[SpaceX] Integrated Flight 1 Base").
    set EstablishCatchCommunications to CatchCommunications:connection.
    set message to "Arms".

    if EstablishCatchCommunications:isconnected {
        if EstablishCatchCommunications:sendmessage(message) {
            print message.
        }
    }

    lock throttle to LandingThrottle().
    lock SteeringVector to lookdirup(-velocity:surface, ApproachVector).
    lock steering to SteeringVector.

    set LandingBurnStarted to true.

    if abs(LngError - LongitudeControlPID:setpoint) > 20 or abs(LatError) > 5 {
        lock TrueAltitude to alt:radar - BoosterHeight.
        lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
        lock steering to SteeringVector.
    }

    set LongitudeControlPID:setpoint to 0.

    when verticalspeed > -50 and (CenterEnginesDeccelTime / TrueAltitude) < 1 and LngError < 10 or verticalspeed > -30 then {
        set InnerRingSwitch to true.
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).

        lock SteeringVector to lookdirup(up:vector - 0.02 * velocity:surface - 0.02 * ErrorVector, RollHeadingVector).
        lock steering to SteeringVector.

        set steeringmanager:rolltorquefactor to 0.75.
        SetGridFinAuthority(2.5).
    }

    until verticalspeed > CatchVerticalSpeed and TrueAltitude < 1 or verticalspeed > -0.01 or shouldHover {
        SteeringCorrections().
        if TrueAltitude > 500 {
            rcs off.
        }
//        else {
//            rcs on.
//        }
// RCS disabled for testing purposes (flight 1).
        wait 0.1.
    }
    set t to time:seconds.
    lock steering to lookDirUp(up:vector - 0.025 * vxcl(up:vector, velocity:surface), facing:topvector).
    lock throttle to (PlanetGravityRelativeToShip + (verticalspeed / CatchVerticalSpeed - 1)) / (max(ship:availablethrust, 0.000001) / ship:mass * 1/cos(vang(-velocity:surface, up:vector))).
    until time:seconds > t + 8 or ship:status = "LANDED" and verticalspeed > -0.01 or TrueAltitude < -1 {
        SteeringCorrections().
        rcs on.
        wait 0.01.
    }
}

function PostLanding {
    set ship:control:translation to v(0, 0, 0).
    unlock steering.
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    rcs off.
    wait 0.01.
    BoosterEngines[0]:shutdown.

    ToggleGridfins(false).
    BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).

    unlock throttle.
}

function SteeringCorrections {
    if KUniverse:activevessel = ship {
        set addons:tr:descentmodes to list(true, true, true, true).
        set addons:tr:descentgrades to list(true, true, true, true).
        set addons:tr:descentangles to list(180, 180, 180, 180).
        if not addons:tr:hastarget {
            ADDONS:TR:SETTARGET(LANDING_SITE).
        }
        if altitude > 15000 and KUniverse:activevessel = vessel(ship:name) {
            lock ApproachVector to vxcl(up:vector, LANDING_SITE:position - ship:position):normalized.
        }

        if altitude < 30000 or KUniverse:activevessel = vessel(ship:name) {
            if InitialError = -9999 and addons:tr:hasimpact {
                set InitialError to LngError.
            }
            set LongitudeControlPID:maxoutput to max(min(abs(LngError - LongitudeControlPID:setpoint) / (PIDSensitivityFactor), 10), 2.5).
            set LongitudeControlPID:minoutput to -LongitudeControlPID:maxoutput.
            set LatitudeControlPID:maxoutput to max(min(abs(LatError) / (10), 5), 0.5).
            set LatitudeControlPID:minoutput to -LatitudeControlPID:maxoutput.

            set LongitudeControlPIDoutput to -LongitudeControlPID:UPDATE(time:seconds, LngError).
            set LatitudeControlPIDoutput to -LatitudeControlPID:UPDATE(time:seconds, LatError).
            if LongitudeControlPIDoutput > 0 {
                set LatitudeControlPIDoutput to -LatitudeControlPIDoutput.
            }

            set maximumDeccelerationFactor to max((ship:availablethrust / ship:mass) - 9.805, 0.000001).
            set maxDecceleration3Engines to (3 * BoosterRaptorThrust / min(ship:mass, BoosterReturnMass - 12.5)) - 9.805.

            if not (InnerRingSwitch) {
                set stopTime10Engines to (airspeed - 50) / min(maximumDeccelerationFactor, 50).
                set stopDist9 to ((airspeed + 50) / 2) * stopTime10Engines.
                set stopTimeCenterOnly to min(50, airspeed) / min(maxDecceleration3Engines, FinalDeceleration).
                set CenterEnginesDeccelTime to (min(50, airspeed) / 2) * stopTimeCenterOnly.
                set TotalstopTime to stopTime10Engines + stopTimeCenterOnly.
                set totalStopDistance to (stopDist9 + CenterEnginesDeccelTime) * cos(vang(-velocity:surface, up:vector)).
                set landingRatio to totalStopDistance / (TrueAltitude - 2.5).
            }
            else {
                set TotalstopTime to airspeed / min(maximumDeccelerationFactor, FinalDeceleration).
                set totalStopDistance to (airspeed / 2) * TotalstopTime.
                set landingRatio to totalStopDistance / (TrueAltitude - 2.5).
            }

            if alt:radar < 1500 {
                rcs off.
                set magnitude to min(TrueAltitude / 100, (ship:position - LANDING_SITE:position):mag / 20).
                if ErrorVector:mag > magnitude and LandingBurnStarted {
                    set ErrorVector to ErrorVector:normalized * magnitude.
                }
            }
            if RectificationFactor * ship:groundspeed < LongitudeControlPID:setpoint and alt:radar < 5000 {
                set LongitudeControlPID:setpoint to RectificationFactor * ship:groundspeed.
            }
            
            lock TrueAltitude to alt:radar - BoosterHeight.
        }
    }
}

// Main execution
MainProgram().

// TODO: Fix wobbly rotation