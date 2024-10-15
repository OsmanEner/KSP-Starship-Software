// Booster Telemetry Software
// --------------------------------------

// Initialization and Variables
// --------------------------------------

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

    print "| [BOOSTER GUIDANCE CURRENT MODE] " + mode at(0,38).
}