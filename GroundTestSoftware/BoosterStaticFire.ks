// Booster Static Fire Software
// --------------------------------------

print "BOOSTER STATIC FIRE V1.0 SOFTWARE".
print "________________________________________".

runoncepath("0:/libs/utilities/importLib").
importLib("CommonFunctionsLibrary").

// Variables and Initialization
// --------------------------------------

set terminalCountdown to 40.

// Static Fire Function
// --------------------------------------

wait until ag1.
set mode to 1.

until mode = 0 {
    if mode = 1 {
        until terminalCountdown = -5 {
            set terminalCountdown to terminalCountdown -1.
            wait 1.

            if ag3 {
                print "Booster Manual Abort Initiated".
                print "________________________________________".
                lock throttle to 0.
                shutdown.
            }

            if terminalCountdown = 39 {
                print "Booster on Internal Power".
                print "________________________________________".
            }

            if terminalCountdown = 5 {
                WaterDelugeActivation().
                print "Water Deluge Activation".
                print "________________________________________".
            }

            if terminalCountdown = 2 {
                SuperHeavyIgnition().
                print "Booster 3 Engines Activation".
                print "________________________________________".
            }

            if terminalCountdown = 1 {
                SwitchOverPreviousEngine().
                print "Booster 10 Engines Activation".
                print "________________________________________".
            }

            if terminalCountdown = 0 {
                SwitchOverPreviousEngine().
                print "Booster 20 Engines Activation".
                print "________________________________________".
            }

            if terminalCountdown = -4 {
                SuperHeavyShutdown().
                WaterDelugeShutdown().
                print "Starship Engines Shutdown, Safing Mode".
                print "________________________________________".
                set mode to 2.
            }
        }
    }
    if mode = 2 {
        wait 5.
        BoosterSafing().
        wait 20.
        set mode to 0.
    }
}
