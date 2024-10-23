// ---------------------------------
// Starship Flight Software
// ---------------------------------

// Library Imports
clearscreen.
runoncepath("0:/StarshipLibraries/utilities/importLib").

importLib("tguidanceController").

local function runShipGuidance {
    local shiprunmode is terminalGuidanceController().
    shiprunmode["passControl"]().
}

set ShipGuidance to false.

// Main program execution
function main {
    runShipGuidance().
}

// Catch ship guidance toggle message
// TO IMPLEMENT

when shipGuidance then { main(). }

// This gets executed after main is finished,
// since passControl halts to itself until the shiprunmode is complete.
until false.