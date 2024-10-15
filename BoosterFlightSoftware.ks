// Booster Flight Software
// --------------------------------------

print "BOOSTER FLIGHT SOFTWARE V1.0 SOFTWARE".
print "________________________________________".

runoncepath("0:/libs/utilities/importLib").
importLib("dataController").

// Initialization and Variables
// --------------------------------------

clearscreen.

set ship:control:neutralize to true.

set targetApoapsis to 250000.
set targetPeriapsis to 250000.
set firstTWR to 1.51.
set endAlt to (160000 / firstTWR).
set finalPitch to 5.
set lzlatlng to kerbin:geopositionlatlng(-20, -73). // Change for re-entry coordinates

declare global expectedModeOutput is 0.
set sendProcessor to processor("MechazillaArmsSoftware").
set sendContent to "Stage1_Communications".

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

// Functions
// --------------------------------------