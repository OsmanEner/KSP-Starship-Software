@lazyGlobal off.

// ---------------------------------
// Hot-Staging Controller
// ---------------------------------

function stagingController {

    local SeparationStatus to false.
    local StagingContent to "Hotstage_Controller".
    local SoftwareProcessor to processor("StarshipFlightSoftware").

    lock steering to heading(90, 30, -90).
    lock throttle to 0.4.

    local HSRRing to ship:partsdubbed("HSRDecoupler").
    local BoosterEngines to ship:partstagged("BoosterCluster").
    local ShipSLEngines to ship:partstagged("ShipSL").
    local ShipVACEngines to ship:partstagged("ShipVAC").

    for part in BoosterEngines {
        part:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true).
        wait 1.5.
        part:getmodule("ModuleTundraEngineSwitch"):doaction("next engine mode", true). // 3 engines
    }

    wait 3.
    for Engine in ShipVACEngines {
        Engine:activate().
    }
    for Engine in HSRRing {
        Engine:activate().
    }

    wait 1.
    SoftwareProcessor:activate().
    if SoftwareProcessor:connection:sendmessage(StagingContent).
    FOR part IN HSRRing{
        part:getmodule("ModuleDecouple"):Doevent("decouple").
        for Engine in ShipSLEngines {
            Engine:activate().
        }
        set SeparationStatus to true.
    }

    function hotstagingComplete {
        if SeparationStatus = true {
            wait 0.5.
            return true.
        }
    }

    function completed { return hotstagingComplete(). }

    function passControl {

        wait until completed().

    return lexicon(
    "passControl", passControl@,
    "completed", completed@
    ).}
}