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

global ShipGuidance to false.

// Main program execution
function main {
    runShipGuidance().
}

// Catch ship guidance toggle message
when not ship:messages:empty then {
    set received to ship:messages:pop.
    print received:content. // Maybe not needed in future flights, since we should always get the message.
    set ShipGuidance to true.
}

when shipGuidance then { main(). }

// This gets executed after main is finished,
// since passControl halts to itself until the shiprunmode is complete.
until false.