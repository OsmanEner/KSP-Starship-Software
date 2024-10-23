@lazyglobal off.

// ---------------------------------
// Ascent Controller
// ---------------------------------

function ascentController {
    local ascentStatus is false.
    local gravityTurnStatus is false.

    local pitchAim is 90.
    local firstTWR is 1.51.
    local endAlt is (160000 / firstTWR).
    local finalPitch is 5.

    set steeringManager:maxstoppingtime to 20.
    set steeringManager:TORQUEEPSILONMAX to 0.05.

    lock steering to heading(20, 89, 20).

    wait until ship:altitude > 400.
    lock steering to heading(90, 90, -90).
    set steeringManager:maxstoppingtime to 15.
    wait 2.
    set steeringManager:maxstoppingtime to 2.

    until ascentStatus {
        if not gravityTurnStatus and ship:altitude > 400 {
            set gravityTurnStatus to true.
        }

        if gravityTurnStatus {
            set pitchAim to max(finalPitch, 90 * (1 - (ship:altitude / endAlt))).
            lock steering to heading(90, pitchAim, -90).
        }

        if ship:altitude > 40000 {
            set ascentStatus to true.
        }

        wait 0.01.
    }

    function ascentCompleted {
        return ascentStatus.
    }

    function completed { return ascentCompleted(). }

    return lexicon(
        "passControl", completed@
    ).
}