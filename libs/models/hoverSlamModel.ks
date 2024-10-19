@lazyglobal off.

function hoverSlamModel {
    parameter bias is 20,
              maxTwr is -1,
              altTarget is 0,
              relightAltTarget is 0.

    if maxTwr < 0 {
        set maxTwr to ship:availablethrust/ship:mass/g.
    }
    
    lock deltalt to (alt:radar - (altTarget + bias) + getBurnAlt()).

    function g { return body:mu/(ship:altitude + body:radius)^2. }

    function getBurnAlt {
        local v0 to ship:velocity:surface:mag.
        return -(v0^2)/(2*g*(maxTwr - 1)).
    }

    function burnTwr {
        local v0 to ship:velocity:surface:mag.
        return min((v0^2)/(2*g*deltalt) + 1, maxTwr).
    }

    function getThrust {
        parameter twr.
        return twr*ship:mass*g/ship:availablethrust.
    }

    function getThrottle {
        local optimalRelightAlt to getBurnAlt().
        local relightAlt to choose optimalRelightAlt if relightAltTarget = 0 else relightAltTarget.
        
        if deltalt > relightAlt or ship:verticalspeed > 0 { return 0. }
        
        if abs(deltalt) < 0.1 and ship:verticalspeed:abs < 0.1 { return 0. }  // Do nothing if at target
        
        local desiredTwr to burnTwr().
        local currentSpeed to ship:velocity:surface:mag.
        
        if currentSpeed < 3 {
            return getThrust(max(desiredTwr, 0.99)).
        } else {
            local speedFactor to min(currentSpeed / 10, 1).  // Gradually reduce thrust as speed decreases
            return getThrust(desiredTwr * speedFactor + 0.99 * (1 - speedFactor)).
        }
    }

    return lexicon(
        "getThrottle", getThrottle@
    ).
}