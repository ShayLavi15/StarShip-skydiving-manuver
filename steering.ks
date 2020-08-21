
function runscript {
    parameter name.
    runpath("0:/"+name+".ks").
}
runscript("lib_navball").

lock pitch to pitch_for().
lock yaw to JRTI:bearing.
lock roll to roll_for().
set pitchPID TO PIDLOOP(2,0.8,1,-45,45).
set pitchPID:setpoint to -3.
set yawPID TO PIDLOOP(1.4,0,1.5,-20,20).
set yawPID:setpoint to 0.
set rollPID TO PIDLOOP(0.2,0.01,0.1,-45,45).
set rollPID:setpoint to 0.
set PtarPID TO PIDLOOP(0.17,0,0,-17,11).
set PtarPID:setpoint to -20.
set RtarPID TO PIDLOOP(0.07,0.01,0.01,-6,6).
set vspeedPID TO PIDLOOP(0.5,0.3,1,-70,0).
set vspeedPID:setpoint to -90.

function steer{
    parameter landingpad.
 set ground_Distance to vxcl(up:vector , JRTI:position):mag.
 set time_till_impact to addons:tr:TIMETILLIMPACT.
 set horizontal_speed to  1.5*ground_Distance/time_till_impact.
 set pitchPID:setpoint to vspeedPID:UPDATE(TIME:SECONDS, -ship:groundspeed).

 if alt:radar < 35000 unlock steering.
 if horizontal_speed < ship:groundspeed set vspeedPID:setpoint to max(-horizontal_speed,-85).
 if(ship:groundspeed < 150){
   set rollPID:setpoint to RtarPID:UPDATE(TIME:SECONDS, -horizontal_distance(JRTI)).
   set rollPID:kp to 2. set rollPID:ki to 0.8. set rollPID:kd to 1.2.
   set pitchPID:kp to 3. set pitchPID:ki to 0.8. set pitchPID:kd to 2.1.
 }
 ship:partstagged("URfin")[0]:getmodule("ModuleControlSurface"):setfield("deploy angle",45 + (-pitchPID:UPDATE(TIME:SECONDS, pitch) + yawPID:UPDATE(TIME:SECONDS, yaw) + rollPID:UPDATE(TIME:SECONDS, roll))/3).
 ship:partstagged("ULfin")[0]:getmodule("ModuleControlSurface"):setfield("deploy angle",45 + (-pitchPID:UPDATE(TIME:SECONDS, pitch) + -yawPID:UPDATE(TIME:SECONDS, yaw) + -rollPID:UPDATE(TIME:SECONDS, roll))/3).
 ship:partstagged("Rfin")[0]:getmodule("ModuleControlSurface"):setfield("deploy angle",45 + (pitchPID:UPDATE(TIME:SECONDS, pitch) + rollPID:UPDATE(TIME:SECONDS, roll))/2).
 ship:partstagged("Lfin")[0]:getmodule("ModuleControlSurface"):setfield("deploy angle",45 + (pitchPID:UPDATE(TIME:SECONDS, pitch) + -rollPID:UPDATE(TIME:SECONDS, roll))/2).
}
