@lazyglobal off.

// ---------------------------------
// Terminal Countdown Controller
// ---------------------------------

function terminalController {
    global LaunchStatus is false.
    local terminalCountdown is 10.
    local abortMode is false.

    lock steering to heading(36, 90, 36).

    local BoosterEngines is ship:partstagged("BoosterCluster").
    local WaterDeluge is ship:partsdubbed("WaterDeluge").
    //local TowerQD is ship:partsdubbed("QuickDisconnect"). // Unused for now.

    until LaunchStatus or abortMode {
        print "T-" + terminalCountdown.
        wait 1.
        set terminalCountdown to terminalCountdown - 1.

        if terminalCountdown = 5 {
            print "Activating Water Deluge System".
            for Engine in WaterDeluge {
                Engine:activate().
            }
        }

        if terminalCountdown = 2 {
            print "Igniting Booster Engines".
            for Engine in BoosterEngines {
                Engine:activate().
            }
            for part in BoosterEngines {
                part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
                wait 0.1.
                part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
            }
        }

        if terminalCountdown = 0 {
            print "Checking Engine Status".
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

        if terminalCountdown <= -1 and abortMode {
            print "ABORT: Engine Failure Detected".
            lock throttle to 0.
            for Engine in BoosterEngines {
                Engine:shutdown().
            }
            for Engine in WaterDeluge {
                Engine:shutdown().
            }
            break.
        }

        if terminalCountdown = -2 and not abortMode {
            // TODO: qd and bqd retraction
            print "Liftoff Successful. Shutting down Water Deluge".
            for Engine in WaterDeluge {
                Engine:shutdown().
            }
            break.
        }
    }

    function terminalComplete {
        return LaunchStatus.
    }

    return lexicon(
        "completed", terminalComplete@
    ).
}

// NOTE : Remove prints before flight, only for debugging purposes.