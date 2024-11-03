// ---------------------------------
// Superheavy Booster Flight Controller
// ---------------------------------

// Library Imports
clearscreen.
runoncepath("0:/StarshipLibraries/utilities/importLib").

local function importRequiredLibraries {
    local requiredLibs is list(
        "launchController",
        "ascentController",
        "stagingController",
        "landingDataModel",
        "boostbackController",
        "postBoostbackController"
    ).
    
    for lib in requiredLibs {
        importLib(lib).
    }
}

// Configuration
local CFG is lexicon(
    "LANDING_SITE", latlng(-0.0972080884740584, -74.5576970966038),
    "BOOSTBACK_SWITCH_THRESHOLD", 85,
    "BOOSTBACK_ROLL_DELAY", 5,
    "BOOSTBACK_ENGINE_SWITCH_DELAY", 9
).

// Boostback steering manager values.
local function initializeSteeringManager {
    set SteeringManager:ROLLCONTROLANGLERANGE to 0.
    set SteeringManager:rollts to 5.
    set SteeringManager:maxstoppingtime to 3.
    set SteeringManager:pitchtorquefactor to 0.75.
    set SteeringManager:yawtorquefactor to 0.75.
}

// Ascent Sequence
local function runAscentSequence {
    wait until ag1.
    
    local terminalCountMode is launchController().
    terminalCountMode["passControl"]().
    
    local ascentMode is ascentController().
    ascentMode["passControl"]().
    
    local hotstageMode is stagingController().
    hotstageMode["passControl"]().
}

local function runBoostbackSequence {
    initializeSteeringManager().
    local landingData is landingDataModel(CFG["LANDING_SITE"]).
    local boosterEngines is SHIP:PARTSNAMED("SEP.23.BOOSTER.CLUSTER").
    local boostbackStartTime is time:seconds.
    local boostback is boostbackController(landingData, 3.5, 1000, 0.6).
    
    rcs on.
    
    lock steering to boostback["getSteering"]().
    lock throttle to boostback["getThrottle"]().
    
    // Roll control delay
    when time:seconds > boostbackStartTime + CFG["BOOSTBACK_ROLL_DELAY"] then {
        set SteeringManager:ROLLCONTROLANGLERANGE to 10.
    }
    
    // Engine mode switch
    when time:seconds > boostbackStartTime + CFG["BOOSTBACK_ENGINE_SWITCH_DELAY"] and verticalSpeed > 0 then {
        boosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
        set ship:control:neutralize to true.
    }
    
    local boostbackEngineSwitched is false.
    when boostback["getStatus"]() >= CFG["BOOSTBACK_SWITCH_THRESHOLD"] and not boostbackEngineSwitched then {
        boosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
        set boostbackEngineSwitched to true.
    }
    
    wait until boostback["completed"]().
    unlock throttle.
    lock throttle to 0.
}

// Main program execution
function main {
    importRequiredLibraries().
    runAscentSequence().
    runBoostbackSequence().

    // Post-boostback execution.
    importLib("postBoostbackController").
    local postBoostbackController is PostBoostbackProgram().
    postBoostbackController["passControl"]().
}

main().