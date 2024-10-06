// Starship Static Fire Software
// --------------------------------------

print "STARSHIP STATIC FIRE V1.0 SOFTWARE".
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
                print "Starship Manual Abort Initiated".
                print "________________________________________".
                lock throttle to 0.
                shutdown.
            }

            if terminalCountdown = 39 {
                print "Starship on Internal Power".
                print "________________________________________".
            }

            if terminalCountdown = 20 {
                print "Water Deluge Activation".
                print "________________________________________".
                toggle ag6.
            }

            if terminalCountdown = 2 {
                SLShipIgnition().
                print "Starship SL Engines Activation".
                print "________________________________________".
            }

            if terminalCountdown = 0 {
                VACShipIgnition().
                print "Starship VAC Engines Activation".
                print "________________________________________".
            }

            if terminalCountdown = -4 {
                StarshipStaticFireShutdown().
                print "Starship Engines Shutdown, Safing Mode".
                print "________________________________________".
                set mode to 2.
            }
        }
    }
    if mode = 2 {
        wait 5.
        StarshipStaticFireSafing().
        wait 20.
        set mode to 0.
    }
}
