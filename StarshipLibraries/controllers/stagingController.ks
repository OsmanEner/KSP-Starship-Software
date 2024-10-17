@lazyGlobal off.

// ---------------------------------
// Hot-Staging Controller
// ---------------------------------

function stagingController {

    local SeparationStatus to false.
    local StagingContent to "Hotstage_Controller".
    local SoftwareProcessor to processor("BoosterFlightSoftware").

    lock steering to heading(90, 30, -90).
    lock throttle to 0.4.

    local HSRRing to ship:partsdubbed("HSRDecoupler").
    local BoosterEngines to ship:partstagged("BoosterCluster").
    local ShipSLEngines to ship:partstagged("ShipSL").
    local ShipVACEngines to ship:partstagged("ShipVAC").

    wait 1.
    for part in BoosterEngines {
        part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
        wait 1.5.
        part:getmodule("ModuleTundraEngineSwitch"):doaction("previous engine mode", true).
    }

    wait 3.
    for Engine in ShipVACEngines {
        Engine:activate().
    }
    for Engine in HSRRing {
        Engine:activate().
    }

    wait 1.
    FOR part IN HSRRing{
        part:getmodule("ModuleDecouple"):Doevent("decouple").
        for Engine in ShipSLEngines {
            Engine:activate().
        }
        set SeparationStatus to true.
    }

    if SeparationStatus = true {
        SoftwareProcessor:activate().
        if SoftwareProcessor:connection:sendmessage(StagingContent).
    }

    function hotstagingComplete {
        if SeparationStatus = true {
            wait 0.5.
            return true.
        }
    }

    function completed { return hotstagingComplete(). }

    return lexicon(
        "completed", completed@
    ).
}