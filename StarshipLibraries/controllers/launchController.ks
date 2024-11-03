@lazyGlobal off.

// ---------------------------------
// Terminal Countdown Controller
// ---------------------------------

function launchController {
    local LaunchStatus to false.
    local terminalCountdown to 10.
    local abortMode to false.

    lock throttle to 0.7.
    lock steering to heading(36, 90, 36).

    local BoosterEngines to ship:partstagged("BoosterCluster").
    local WaterDeluge to ship:partsdubbed("WaterDeluge").

    until LaunchStatus {
        wait 1.
        set terminalCountdown to terminalCountdown - 1.

        when terminalCountdown = 5 then {
            for Engine in WaterDeluge {
                Engine:activate().
            }
        }

        when terminalCountdown = 2 then {
            for Engine in BoosterEngines {
                Engine:activate().
            }
        }

        when terminalCountdown = -1 then {
            for part in BoosterEngines {
                part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
                part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
            }
        }

        when terminalCountdown = -2 then {
            toggle ag2.
            set LaunchStatus to true.
            for Engine in WaterDeluge {
                Engine:shutdown().
            }
        }
    }

    function terminalComplete {
        if LaunchStatus = true {
            wait 0.01.
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