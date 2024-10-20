@lazyglobal off.

// ---------------------------------
// Terminal Countdown Controller
// ---------------------------------

function terminalController {
    declare global LaunchStatus to false.
    local terminalCountdown to 10.
    local abortMode to false.

    lock steering to heading(36, 90, 36).

    local BoosterEngines to ship:partstagged("BoosterCluster").
    local WaterDeluge to ship:partsdubbed("WaterDeluge").
    local TowerQD to ship:partsdubbed("QuickDisconnect").

    until LaunchStatus {
        wait 1.
        set terminalCountdown to terminalCountdown - 1.

        if terminalCountdown = 5 {
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
                if Engine:ignition = false or Engine:thrust < 6539 {
                    set abortMode to true.
                    break.
                }
            }
            if not abortMode {
                set LaunchStatus to true.
            }
        }

        if terminalCountdown = -1 and abortMode {
            lock throttle to 0.
            for Engine in BoosterEngines {
                Engine:shutdown().
            }
            for Engine in WaterDeluge {
                Engine:shutdown().
            }
        }

        if terminalCountdown = -2 and not abortMode {
            // TODO: qd and bqd retraction
            set LaunchStatus to true.
            for Engine in WaterDeluge {
                Engine:shutdown().
            }
        }
    }

    function terminalComplete {
        if LaunchStatus {
            wait 0.5.
            return true.
        }
    }

    return lexicon(
        "completed", terminalComplete@
    ).
}