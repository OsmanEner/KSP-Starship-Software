@lazyGlobal off.

// ---------------------------------
// Hot-Staging Controller
// ---------------------------------

function ascentController {

    local ascentStatus to false.
    local gravityTurnStatus to false.

    local pitchAim to 1.
    local firstTWR to 1.51.
    local endAlt to (160000 / firstTWR).
    local finalPitch to 5.

    lock steering to heading(36, 81, 36).
    lock throttle to 0.7.

    set steeringManager:maxstoppingtime to 20.
    set steeringManager:TORQUEEPSILONMAX to 0.05.

    wait until ship:altitude > 800.
    lock steering to heading (90,90,-90).
    set steeringManager:maxstoppingtime to 2.
    set gravityTurnStatus to true.

    if gravityTurnStatus = true {
        set pitchAim to (max(finalPitch, 90 * (1 - (ship:altitude / endAlt)))).
        wait 0.01.

        lock steering to heading (90,pitchAim,-90).

        if ship:altitude > 39000 {
            set ascentStatus to true.
            set gravityTurnStatus to false.
        }
    }

    function ascentCompleted {
        if ascentStatus = true {
            wait 0.5.
            return true.
        }
    }

    function completed { return ascentCompleted(). }

    return lexicon(
        "completed", completed@
    ).
}