set LANDING_SITE to latlng(-0.0972080884740584, -74.5576970966038).
set LatCtrl to 0.
set LngCtrl to 0.
set LngError to 0.
set LatError to 0.
set ErrorVector to V(0, 0, 0).
set BoosterEngines to SHIP:PARTSNAMED("SEP.23.BOOSTER.CLUSTER").
set GridFins to SHIP:PARTSNAMED("SEP.23.BOOSTER.GRIDFIN").
for part in ship:parts {
    if part:name:contains("SEP.23.BOOSTER.INTEGRATED") {
        set BoosterCore to part.
    }
}
set HSR to SHIP:PARTSNAMED("SEP.23.BOOSTER.HSR").
if HSR:length = 0 {
    set HSR to SHIP:PARTSNAMED("SEP.23.BOOSTER.HSR (" + ship:name + ")").
}
set InitialError to -9999.
set maxDecel to 0.
set TotalstopTime to 0.
set TotalstopDist to 0.
set stopDistance3Engines to 0.
set landingRatio to 0.
set LandingBurnStarted to false.
set stopTime10Engines to 0.
set TimeStabilized to 0.
set MiddleEnginesShutdown to false.
set hover to false.
set Planet1G to CONSTANT():G * (ship:body:mass / (ship:body:radius * ship:body:radius)).
set BoosterHeight to 64. // Landing height
set LQMethane to 0. // Unused for now, don't remove
set LQMethaneCutoff to 10000.
set LngCtrlPID to PIDLOOP(0.35, 0.3, 0.25, -10, 10).
set LngCtrlPID:setpoint to 50.
set LatCtrlPID to PIDLOOP(0.25, 0.2, 0.1, -5, 5).
set RollVector to heading(270,0):vector.
set BoosterReturnMass to 135.8.
set BoosterRaptorThrust to 673.
set CorrFactor to 0.655.
set PIDFactor to 8.
set CatchVS to -0.3. // vertical speed
lock RadarAlt to alt:radar - BoosterHeight.
set FinalDeceleration to 8.

SetGridFinAuthority(32).

clearscreen.

until False {
    PostBoostbackProgram().
}

function PostBoostbackProgram {
    wait 0.001.

    set ApproachUPVector to (LANDING_SITE:position - body:position):normalized.
    set ApproachVector to vxcl(up:vector, LANDING_SITE:position - ship:position):normalized.
    set CurrentVec to facing:forevector.

    if verticalspeed > 0 {

        set turnTime to time:seconds.
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("previous engine mode", true). // 13 engines
        set SteeringManager:pitchtorquefactor to 1.
        set SteeringManager:yawtorquefactor to 1.

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

        set SteeringManager:maxstoppingtime to 5.

        for res in ship:resources {
            if res:name = "LqdMethane" {
                lock LQMethane to res:amount.
            }
        }

        
        local CurrentVecRotation is AngleAxis(-5 * min(time:seconds - turnTime, 27), lookdirup(CurrentVec, up:vector):starvector).
        local SteeringVectorUp is lookdirup(CurrentVec * CurrentVecRotation, up:vector).
        local SteeringVectorDown is lookdirup(CurrentVec * CurrentVecRotation, -up:vector).

        if vang(facing:forevector, SteeringVectorDown:vector) > 10 {
            lock SteeringVector to SteeringVectorDown.
            lock steering to SteeringVector.
            
            PerformSteeringCorrections(18).
            
            lock SteeringVector to SteeringVectorUp.
            lock steering to SteeringVector.
            
            PerformSteeringCorrections(4).
            set SteeringManager:maxstoppingtime to 2.
            PerformSteeringCorrections(13).
        }

        PerformSteeringCorrections(2.5).

        ToggleGridfins(true).

        PerformSteeringCorrections(2.5).

        BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 5).
    }
    else {
        lock steering to facing:forevector.
    }

    until altitude < 30000 {
        SteeringCorrections().
        rcs on.
        if abs(steeringmanager:angleerror) > 10 {
            BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 25).
        }
        else if abs(steeringmanager:angleerror) < 0.25 and KUniverse:activevessel = ship {
            if TimeStabilized = "0" {
                set TimeStabilized to time:seconds.
            }
            if time:seconds - TimeStabilized > 5 {
                BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 10).
                set TimeStabilized to 0.
            }
        }
        else {
            set TimeStabilized to 0.
        }
        wait 0.1.
    }

    BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
    lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), ApproachVector * AngleAxis(2 * LatCtrl, up:vector)).
    lock steering to SteeringVector.

    until landingRatio > 1 and alt:radar < 2000 {
        SteeringCorrections().
        if altitude > 20000 {
            rcs on.
        }
        else {
            rcs off.
        }
        wait 0.1.
    }

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

    if abs(LngError - LngCtrlPID:setpoint) > 20 or abs(LatError) > 5 {
        lock RadarAlt to alt:radar - BoosterHeight.
        lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
        lock steering to SteeringVector.
    }

    set LngCtrlPID:setpoint to 0.

    when verticalspeed > -50 and (stopDistance3Engines / RadarAlt) < 1 and LngError < 10 or verticalspeed > -30 then {
        set MiddleEnginesShutdown to true.
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).

        lock SteeringVector to lookdirup(up:vector - 0.02 * velocity:surface - 0.02 * ErrorVector, RollVector).
        lock steering to SteeringVector.

        set steeringmanager:rolltorquefactor to 0.75.
        SetGridFinAuthority(2.5).
    }

    until verticalspeed > CatchVS and RadarAlt < 1 or verticalspeed > -0.01 or hover {
        SteeringCorrections().
        if RadarAlt > 500 {
            rcs off.
        }
        else {
            rcs on.
        }
        wait 0.1.
    }
    set t to time:seconds.
    lock steering to lookDirUp(up:vector - 0.025 * vxcl(up:vector, velocity:surface), facing:topvector).
    lock throttle to (Planet1G + (verticalspeed / CatchVS - 1)) / (max(ship:availablethrust, 0.000001) / ship:mass * 1/cos(vang(-velocity:surface, up:vector))).
    until time:seconds > t + 8 or ship:status = "LANDED" and verticalspeed > -0.01 or RadarAlt < -1 {
        SteeringCorrections().
        print "landing hover".
        rcs on.
        wait 0.01.
    }

    set ship:control:translation to v(0, 0, 0).
    unlock steering.
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    rcs off.
    clearscreen.
    print "landed".
    wait 0.01.
    BoosterEngines[0]:shutdown.

    ToggleGridfins(false).
    BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).

    unlock throttle.
}

FUNCTION SteeringCorrections {
    if KUniverse:activevessel = ship {
        set addons:tr:descentmodes to list(true, true, true, true).
        set addons:tr:descentgrades to list(true, true, true, true).
        set addons:tr:descentangles to list(180, 180, 180, 180).
        if not addons:tr:hastarget {
            ADDONS:TR:SETTARGET(LANDING_SITE).
        }
        if altitude > 15000 and KUniverse:activevessel = vessel(ship:name) {
            set ApproachVector to vxcl(up:vector, LANDING_SITE:position - ship:position):normalized.
        }

        if addons:tr:hasimpact {
            set ErrorVector to ADDONS:TR:IMPACTPOS:POSITION - LANDING_SITE:POSITION.
        }
        set LatError to vdot(AngleAxis(-90, ApproachUPVector) * ApproachVector, ErrorVector).
        set LngError to vdot(ApproachVector, ErrorVector).

        if altitude < 30000 or KUniverse:activevessel = vessel(ship:name) {

            if InitialError = -9999 and addons:tr:hasimpact {
                set InitialError to LngError.
            }
            set LngCtrlPID:maxoutput to max(min(abs(LngError - LngCtrlPID:setpoint) / (PIDFactor), 10), 2.5).
            set LngCtrlPID:minoutput to -LngCtrlPID:maxoutput.
            set LatCtrlPID:maxoutput to max(min(abs(LatError) / (10), 5), 0.5).
            set LatCtrlPID:minoutput to -LatCtrlPID:maxoutput.

            set LngCtrl to -LngCtrlPID:UPDATE(time:seconds, LngError).
            set LatCtrl to -LatCtrlPID:UPDATE(time:seconds, LatError).
            if LngCtrl > 0 {
                set LatCtrl to -LatCtrl.
            }

            set maxDecel to max((ship:availablethrust / ship:mass) - 9.805, 0.000001).
            set maxDecel3Engines to (3 * BoosterRaptorThrust / min(ship:mass, BoosterReturnMass - 12.5)) - 9.805.

            if not (MiddleEnginesShutdown) {
                set stopTime10Engines to (airspeed - 50) / min(maxDecel, 50).
                set stopDistance10Engines to ((airspeed + 50) / 2) * stopTime10Engines.
                set stopTime3Engines to min(50, airspeed) / min(maxDecel3Engines, FinalDeceleration).
                set stopDistance3Engines to (min(50, airspeed) / 2) * stopTime3Engines.
                set TotalstopTime to stopTime10Engines + stopTime3Engines.
                set TotalstopDist to (stopDistance10Engines + stopDistance3Engines) * cos(vang(-velocity:surface, up:vector)).
                set landingRatio to TotalstopDist / (RadarAlt - 2.5).
            }
            else {
                set TotalstopTime to airspeed / min(maxDecel, FinalDeceleration).
                set TotalstopDist to (airspeed / 2) * TotalstopTime.
                set landingRatio to TotalstopDist / (RadarAlt - 2.5).
            }

            if alt:radar < 1500 {
                rcs off.
                set magnitude to min(RadarAlt / 100, (ship:position - LANDING_SITE:position):mag / 20).
                if ErrorVector:mag > magnitude and LandingBurnStarted {
                    set ErrorVector to ErrorVector:normalized * magnitude.
                }
            }
            if CorrFactor * ship:groundspeed < LngCtrlPID:setpoint and alt:radar < 5000 {
                set LngCtrlPID:setpoint to CorrFactor * ship:groundspeed.
            }
            
            lock RadarAlt to alt:radar - BoosterHeight.
        }
    }
}

function LandingThrottle {
    if verticalspeed > CatchVS {
        set minDecel to (Planet1G - 0.025) / (max(ship:availablethrust, 0.000001) / ship:mass * 1/cos(vang(-velocity:surface, up:vector))).
        set Hover to true.
        return minDecel.
    }
    wait 0.001.
    return max((landingRatio * min(maxDecel, 50)) / maxDecel, 0.33).
}

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

function PerformSteeringCorrections {
    parameter duration.
    local endTime is time:seconds + duration.
    until time:seconds >= endTime {
        SteeringCorrections().
        rcs on.
        wait 0.1.
    }
}

function completed { return ship:status = "LANDED". }

function passControl {
    parameter isUnlocking is true.
    wait until completed().

    if isUnlocking { unlock throttle. unlock steering. }


return lexicon(
    "passControl", passControl@,
    "completed", completed@
).}