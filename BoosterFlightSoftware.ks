// Booster Flight Software
// --------------------------------------

runoncepath("0:/libs/utilities/importLib").
importLib("BoosterTelemetry").

// Initialization and Variables
// --------------------------------------

clearscreen.

set ship:control:neutralize to true.

set MissionName to "Starship Flight 1".
set targetApoapsis to 250000.
set targetPeriapsis to 20000.
set firstTWR to 1.51.
set endAlt to (160000 / firstTWR).
set finalPitch to 5.
set lzlatlng to kerbin:geopositionlatlng(-20, -73). // Change for re-entry coordinates
lock throttle to 1.
set StarshipTerminalCountdown to 10.
set mode to 0.

declare global expectedModeOutput is 0.
set sendProcessor to processor("MechazillaArmsSoftware").
set sendContent to "Stage1_Communications".
set BoosterDataLogs to true.

set terminal:height to 41.
set terminal:width to 60.

set ag1 to false.
set ag2 to false.
set ag3 to false.
set ag4 to false.
set ag5 to false.
set ag6 to false.
set ag7 to false.
set ag8 to false.
set ag9 to false.
set ag10 to false.

set SteelPlateWaterDeluge to ship:partsdubbed("WaterDeluge").
set BoosterEngines to ship:partstagged("BoosterCluster").

// Booster Terminal Countdown
// --------------------------------------

wait until ag1.
set mode to 1.

until mode = 0 {
    if mode = 1 {
        until StarshipTerminalCountdown = -3 {
            set StarshipTerminalCountdown to StarshipTerminalCountdown -1.
            wait 1.

            if abort {
                lock throttle to 0.
                shutdown.
            }

            if StarshipTerminalCountdown = 5 {
                for Engine in SteelPlateWaterDeluge {
                    Engine:activate().
                }
            }

            if StarshipTerminalCountdown = 2 {
                for Engine in BoosterEngines {
                    Engine:activate().
                }
            }

            if StarshipTerminalCountdown = -2 {
                if sendProcessor:connection:sendmessage(sendContent).
            }
        }
    }
}

