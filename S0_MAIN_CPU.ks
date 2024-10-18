// ---------------------------------
// Mechazilla Flight Software
// ---------------------------------


// ---------------------------------
// Variables and Functions
// ---------------------------------

set Mechazilla to ship:partsdubbed("MechazillaFlightSoftware").
set mode to 1.

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

until mode = 0 {
    if mode = 1 {
        when not ship:messages:empty then {
            set received to ship:messages:pop.
            print received:content.
            set mode to 2.
        }
    }
    if mode = 2 {
        MechazillaCatchClose().
    }
}