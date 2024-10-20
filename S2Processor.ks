// ---------------------------------
// Starship Flight Software
// ---------------------------------

clearscreen.

runoncepath("0:/StarshipLibraries/utilities/importLib").
importLib("tguidanceController").

importLib("S1_Telemetry_Data").

// ---------------------------------
// Variables and Functions
// ---------------------------------

set shipGuidance to false.

// ---------------------------------
// Starship Ascent
// ---------------------------------

when not core:messages:empty then {
    set received to core:messages:pop.

    if received:content = "Hotstage_Controller" {
        set shipGuidance to true.
    }
}

wait until shipGuidance = true.

local shipMode is tguidanceController().
lock throttle to 0.7.
wait until shipMode["completed"]().

until false.