@lazyGlobal off.

// ---------------------------------
// Terminal Countdown Controller
// ---------------------------------

function terminalController {
    declare global LaunchStatus to false.
    declare global terminalCountdown to 10.
    declare global abortMode to false.

    lock steering to heading(36, 90, 36).

    local BoosterEngines to ship:partstagged("BoosterCluster").
    local WaterDeluge to ship:partsdubbed("WaterDeluge").
    // local TowerQD to ship:partsdubbed("QuickDisconnect"). unused

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
            for part in BoosterEngines {
                part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
                wait 1.
                part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
            }
        }

        when terminalCountdown = 0 then {
            for Engine in BoosterEngines {
                if Engine:ignition = true {
                    return true.
                } else if Engine:ignition = false {
                    set abortMode to true.
                }
                if Engine:thrust > 6539 {
                    return true.
                } else if Engine:thrust < 6539 {
                    set abortMode to true.
                }
            }
        }

        when terminalCountdown = -1 then {
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

        when terminalCountdown = -2 then {
            // TODO: qd and bqd retraction
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

    return lexicon(
        "completed", terminalComplete@
    ).
}