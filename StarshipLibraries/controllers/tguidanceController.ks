@lazyGlobal off.

// ---------------------------------
// Terminal Guidance Controller
// ---------------------------------

function terminalController {

    local ShipAscentStatus to false.

    local ShipSLEngines to ship:partstagged("ShipSL").
    local ShipVACEngines to ship:partstagged("ShipVAC").

    local targetApoapsis is 200000.
    local targetPeriapsis is 10000.
    local minimumPeriapsis is -50000.

    lock steering to heading(90,0,-90).

    until ShipAscentStatus = true {
        wait 0.5.
        if ship:apoapsis > targetApoapsis {
            lock steering to heading(90,-30,-90).
        }
        if ship:apoapsis < targetApoapsis {
            lock steering to heading(90,10,-90).
        }

        if ship:periapsis > minimumPeriapsis {
            lock throttle to 0.3.
            for Engine in ShipVACEngines {
                Engine:shutdown().
            }
        }

        if ship:apoapsis > targetApoapsis and ship:periapsis > targetPeriapsis {
            for Engine in ShipSLEngines {
                Engine:shutdown().
            }
            wait 0.5.
            set ShipAscentStatus to true.
        }
    }

    function terminalComplete {
        if ShipAscentStatus = true {
            wait 0.5.
            return true.
        }
    }

    function completed { return terminalComplete(). }

    function passControl {

        wait until completed().

    return lexicon(
    "passControl", passControl@,
    "completed", completed@
    ).}
}