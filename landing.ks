clearscreen.
set radarOffset to 27.	 				// The value of alt:radar when landed (on gear)
lock trueRadar to alt:radar - radarOffset.			// Offset radar to get distance from gear to ground
lock g to constant:g * body:mass / body:radius^2.		// Gravity (m/s^2)
lock maxDecel to (ship:availablethrust / ship:mass) - g.	// Maximum deceleration possible (m/s^2)
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		// The distance the burn will require
lock idealThrottle to stopDist / trueRadar.			// Throttle required for perfect hoverslam
lock impactTime to trueRadar / abs(ship:verticalspeed).		// Time until impact, used for landing gear


	function landingflaps{
     parameter xy.
     if xy = "x" {set x to 0. set y to 90.}
     if xy = "y" {set x to 0. set y to 0.}
     ship:partstagged("URfin")[0]:getmodule("ModuleControlSurface"):setfield("deploy angle", x).
     ship:partstagged("ULfin")[0]:getmodule("ModuleControlSurface"):setfield("deploy angle", x).
     ship:partstagged("Rfin")[0]:getmodule("ModuleControlSurface"):setfield("deploy angle", y).
     ship:partstagged("Lfin")[0]:getmodule("ModuleControlSurface"):setfield("deploy angle", y).
}

    function shouldland{
        print "alt: " + trueRadar at(0,1).
        print "stop: " + stopDist at(0,2).
        if trueRadar < stopDist + 400 return true.
        return false.
    }

    function land{
 set roll to ship:facing:roll.
 landingflaps("x").
 if addons:tr:hasimpact lock STEERING to ship:srfretrograde.// +R(0,SlamCor:UPDATE(0.05, abs(vertical_distance(landingpad))),roll).
 set addons:tr:retrograde to true.
 SET SteeringManager:ROLLTORQUEFACTOR to 0.
 sas off.
 //rcs on.

 when on_dir(ship:srfretrograde,15) then {
 rcs on.
 UNTIL trueRadar < stopDist{wait 0.05.}	 
lock throttle to idealThrottle.
gear on.
 UNTIL ship:verticalspeed > -0.01 {wait 0.05.
 }
	 	 
	set ship:control:pilotmainthrottle to 0.
	rcs off.
    }
    }