@lazyglobal off.
// glideController ::
//     landingDataModel ->
//     float* ->
//     float* ->
//     glideController
function glideController {
    parameter ldata,
              aoa is 10,
              errorScaling is 1.

    // public getSteering :: nothing -> direction
    function getSteering {
        // returns steering vector accounting for max angle of attack
        local errorVector is ldata["errorVector"]().
        local velVector is -ship:velocity:surface.
        local result is velVector + errorVector*errorScaling.

        // [ improvement ] could check if velVector and errorVector ratio is
        // larger than tan(aoa)
        if vang(result, velVector) > aoa
        {
            set result to velVector:normalized
                          + tan(aoa)*errorVector:normalized.
        }

        return lookdirup(result, facing:topvector).
    }

    // public getThrottle :: nothing -> float
    function getThrottle { return 0. } // no throttle during gliding

    // public completed :: nothing -> bool
    function completed { return throttle > 0. }

    // public passControl :: bool* -> nothing
    function passControl {
        // performs gliding towards target maneuver
        parameter isUnlocking is true.

        lock steering to getSteering().
        lock throttle to getThrottle().
        wait until completed().

        if isUnlocking { unlock throttle. unlock steering. }
    }

        // public terminateExecution :: bool* -> nothing
    function terminateExecution {
        // terminates the execution of the landing controller
        parameter terminate is false.

        if terminate {
            unlock steering.
            unlock throttle.
            completed().
        }
    }

    // Return Public Fields
    return lexicon(
        "getSteering", getSteering@,
        "getThrottle", getThrottle@,
        "completed", completed@,
        "passControl", passControl@,
        "terminateExecution", terminateExecution@
    ).
}
