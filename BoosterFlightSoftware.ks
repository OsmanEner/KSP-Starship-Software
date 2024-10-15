// Booster Flight Software
// --------------------------------------

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

// Data Logs
// --------------------------------------


until false {
    wait 1.

    if mode = 0 {
        set CurrentGuidanceMode to "Mode Awaiting".
        set UpcomingGuidanceMode to "Mode 1".
    }

    if mode = 1 {
        set CurrentGuidanceMode to "Mode 1".
        set UpcomingGuidanceMode to "Mode 2".
    } else if mode = 2 {
        set CurrentGuidanceMode to "Mode 2".
        set UpcomingGuidanceMode to "Mode 3".
    } else if mode = 3 {
        set CurrentGuidanceMode to "Mode 3".
        set UpcomingGuidanceMode to "Mode 4".
    } else if mode = 4 {
        set CurrentGuidanceMode to "Mode 4".
        set UpcomingGuidanceMode to "Mode 5".
    } else if mode = 5 {
        set CurrentGuidanceMode to "Mode 5".
        set UpcomingGuidanceMode to "Mode 5".
    } else if mode = 6 {
        set CurrentGuidanceMode to "Mode 6".
        set UpcomingGuidanceMode to "Mode 7".
    } else if mode = 7 {
        set CurrentGuidanceMode to "Mode 7".
        set UpcomingGuidanceMode to "Flight Finalization".
    }
}

until BoosterDataLogs = false {
    wait 1.
    set BoosterDataPitch to 90 - vectorangle(ship:up:forevector, ship:facing:forevector).
    print "|───[SPACEX STARSHIP KSP PROGRAM]───|" at(0,1).
    print "_____________________________________" at(0,2).

    print "| [MISSION NAME] " + MissionName at(0,5).
    print "| [CURRENT T+] " + missionTime at(0,6).

    print "|───[FLIGHT ORBIT]───|" at(0,8).
    print "_____________________________________" at(0,9).

    print "| [BOOSTER APOGEE] " + ship:apoapsis at(0,11).
    print "| [BOOSTER PERIAPSIS] " + ship:periapsis at(0,12).
    print "| [BOOSTER INCLINATION] " + ship:orbit:inclination at(0,13).
    print "| [BOOSTER APOGEE ETA] " + eta:apoapsis at(0,14).
    print "| [BOOSTER PERIGEE ETA] " + eta:periapsis at(0,15).

    print "|───[FLIGHT STATISTICS]───|" at(0,17).
    print "_____________________________________" at(0,18).

    print "| [BOOSTER THROTTLE] " + throttle at(0,20).
    print "| [BOOSTER ALTITUDE] " + alt:radar at(0,21).
    print "| [BOOSTER VELOCITY] " + ship:airspeed at(0,22).
    print "| [BOOSTER PITCH] " + BoosterDataPitch at(0,23).
    print "| [BOOSTER YAW] " + ship:direction:yaw at(0,24).
    print "| [BOOSTER ROLL] " + ship:direction:roll at(0,25).
    print "| [BOOSTER DELTA-V] " + ship:deltav:current at(0,26).

    print "|───[FLIGHT SECONDARY INFO]───|" at(0,28).
    print "_____________________________________" at(0,29).

    print "| [BOOSTER AERO PRESSURE] " + ship:q at(0,31).
    print "| [BOOSTER GPS LATITUDE] " + geoPosition:lat at(0,32).
    print "| [BOOSTER GPS LONGITUDE] " + geoPosition:lng at(0,33).

    print "|───[FLIGHT GUIDANCE MODE]───|" at(0,35).
    print "_____________________________________" at(0,36).

    print "| [BOOSTER GUIDANCE CURRENT MODE] " + CurrentGuidanceMode at(0,38).
    print "| [BOOSTER CURRENT EVENT] " + UpcomingGuidanceMode at(0,39).
}

// Booster Terminal Countdown

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

