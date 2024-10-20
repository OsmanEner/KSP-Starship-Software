@lazyGlobal off.

// ---------------------------------
// Ascent Controller
// ---------------------------------

function ascentController {


    local ascentStatus to false.
    local gravityTurnStatus to false.

    local pitchAim to 1.
    local firstTWR to 1.51.
    local endAlt to (160000 / firstTWR).
    local finalPitch to 5.

    set steeringManager:maxstoppingtime to 20.
    set steeringManager:TORQUEEPSILONMAX to 0.05.

    lock steering to heading(20, 89, 20).

    wait until ship:altitude > 400.
    lock steering to heading (90,90,-90).
    set steeringManager:maxstoppingtime to 15.
    wait 2.
    set gravityTurnStatus to true.
    set steeringManager:maxstoppingtime to 2.

    until gravityTurnStatus = true {
        wait 0.01.
        set pitchAim to (max(finalPitch, 90 * (1 - (ship:altitude / endAlt)))).
        print pitchAim.

        lock steering to heading (90,pitchAim,-90).

        if ship:altitude > 40000 {
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