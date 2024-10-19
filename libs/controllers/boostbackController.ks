@lazyglobal off.
// boostbackController :: landingData -> float -> float -> boostbackController
function boostbackController {
    parameter ldata,
              errorScaling is 5,
              undershoot is 0,
              maxThrottle is 1.

    local initialDistance to 0.
    local currentDistance to 0.

    lock landingPosition to ldata["getSite"]():position.
    lock impactPosition to ldata["getImpact"]():position.

    // private endBurn :: nothing -> bool
    function endBurn {
        // returns true if boostback burn should end
        local landingProjection to vxcl(up:forevector, landingPosition).
        local impactProjection  to vxcl(up:forevector, impactPosition).
        set currentDistance to (impactProjection - landingProjection):mag.

        return vang(landingProjection, impactProjection) < 45
               and (impactProjection:mag > landingProjection:mag or currentDistance <= undershoot).
    }

    // public getSteering :: nothing -> vector
    function getSteering {
        local errorVector is ldata["errorVector"]().
        local yawVector is vxcl(up:forevector, -errorVector):normalized.

        return yawVector*errorScaling - ship:velocity:surface:normalized.
    }

    // public getThrottle :: nothing -> float
    function getThrottle {
        if endBurn() { return 0. }
        return max(0, min(maxThrottle, (currentDistance - undershoot)/1000 + 0.25)).
    }

    // public completed :: nothing -> bool
    function completed { return endBurn(). }

    // public getStatus :: nothing -> float
    function getStatus {
        if initialDistance = 0 {
            set initialDistance to currentDistance.
            return 0.
        }
        return min(100, max(0, 100 * (1 - (currentDistance - undershoot) / (initialDistance - undershoot)))).
    }

    // public passControl :: bool* -> nothing
    function passControl {
        // performs boostback maneuver
        parameter isUnlocking is true.

        local initialSteering is getSteering().
        lock steering to initialSteering.
        wait until vang(initialSteering, ship:facing:forevector) < 5.

        lock steering to getSteering().
        lock throttle to getThrottle().
        wait until completed().

        if isUnlocking { unlock throttle. unlock steering. }
    }

    return lexicon(
        "getThrottle", getThrottle@,
        "getSteering", getSteering@,
        "completed", completed@,
        "passControl", passControl@,
        "getStatus", getStatus@
    ).
}