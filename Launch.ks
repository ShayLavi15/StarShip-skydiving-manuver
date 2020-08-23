function runscript {
    parameter name.
    runpath("0:/"+name+".ks").
}

runscript("lib_navball").

set APPID to PIDLOOP(0.001,0,0,0,1).

set rollOnLaunch to ship:facing:roll.
function launch {
    parameter apo.
    parameter landingpad.
    set APPID:setpoint to apo.
    sas off.
  //return "APOGEE". 
   //return "Coast_Complete". 
if SSstat = "MECO" set APPID:maxoutput to 0.25.
lock steering to up + R(0,0,landingpad:heading).
lock twr to max(ship:maxthrust, 1) / ship:mass / 10.
lock steering to heading(landingpad:heading, max(90 - ship:velocity:surface:mag / (40 / min(twr, 2.5)), 20)).
lock throttle to APPID:UPDATE(0.05, apoapsis).
until throttle < 0.1 {
    print "AP: " + apoapsis at(0,10).
    print landingpad:heading at(0,11).
    print APPID:output at(0,12).
    }
lock throttle to 0.
wait 2.
if SHIP:PARTS:LENGTH > 35 {stage. wait 2. print "MECO". return "MECO".}
else {print "APOGEE". return "APOGEE".}


}
