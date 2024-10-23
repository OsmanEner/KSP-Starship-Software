// ---------------------------------
// Starship Flight Software
// ---------------------------------

// Library Imports
clearscreen.
runoncepath("0:/StarshipLibraries/utilities/importLib").

local function importRequiredLibraries {
    local requiredLibs is list(
        "stagingController",
        "tguidanceController"
    ).
    
    for lib in requiredLibs {
        importLib(lib).
    }
}


// Configuration

set shipGuidance to false.

// Ascent Sequence

local function runAscentSequence {

    local hotstageMode is stagingController().
    wait until hotstageMode["passControl"]().

    wait until shipGuidance = true.

    local shiprunmode is terminalController().
    shiprunmode["passControl"]().
}

// Main program execution

function main {
    importRequiredLibraries().
    runAscentSequence().
}

until false.