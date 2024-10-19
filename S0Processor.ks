// ---------------------------------
// Mechazilla Flight Software
// ---------------------------------

// ("[SpaceX] Integrated Flight 1 Base"). vessel name

// ---------------------------------
// Variables and Functions
// ---------------------------------

set Mechazilla to ship:partsdubbed("MechazillaFlightSoftware").

function MechazillaCatchClose {
    FOR part IN Mechazilla{
        part:getmodule("ModuleSLEController"):Doevent("Close Arms").
        part:getmodule("ModuleSLEController"):setfield("Target Speed", 7).
        wait 4.
        part:getmodule("ModuleSLEController"):doaction("Stop Arms", true).
        part:getmodule("ModuleSLEController"):setfield("Target Speed", 2).
        wait 2.
        part:getmodule("ModuleSLEController"):Doevent("Close Arms").
    }
}

when not ship:messages:empty then {
    set received to ship:messages:pop.
    print received:content.
    MechazillaCatchClose().
}

until false.