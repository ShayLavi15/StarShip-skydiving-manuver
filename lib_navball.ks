// A library of functions to calculate navball-based directions:

// This file is distributed under the terms of the MIT license, (c) the KSLib team

@lazyglobal off.
lock A to SSimpact:position:mag.
lock B to lauchpad:position:mag.
lock C to v(ship:position:x,lauchpad:position:y,0).
lock AB to vang(impact:position,lauchpad:position).
//lock alpha to arcsin(A*AB/C).
//lock beta to arcsin(B*AB/C).

function east_for {
  parameter ves is ship.

  return vcrs(ves:up:vector, ves:north:vector).
}

function compass_for {
  parameter ves is ship,thing is "default".

  local pointing is ves:facing:forevector.
  if not thing:istype("string") {
    set pointing to type_to_vector(ves,thing).
  }

  local east is east_for(ves).

  local trig_x is vdot(ves:north:vector, pointing).
  local trig_y is vdot(east, pointing).

  local result is arctan2(trig_y, trig_x).

  if result < 0 {
    return 360 + result.
  } else {
    return result.
  }
}

function pitch_for {
  parameter ves is ship,thing is "default".

  local pointing is ves:facing:forevector.
  if not thing:istype("string") {
    set pointing to type_to_vector(ves,thing).
  }
//if(alt:radar < 7500) {return 90 - vang(ves:up:vector, pointing).}
 return -1*(90 - vang(ves:velocity:surface:NORMALIZED, pointing)).
  
}
//function roll_adjust {
//lock vec1 to vxcl(ship:facing:vector,-velocity:surface).
//IF VDOT(vec1,SHIP:FACING:STARVECTOR) > 0 {
  //  RETURN -vang(vec1,ship:facing:topvector).
//} ELSE {
  //  RETURN vang(vec1,ship:facing:topvector).
//}

function roll_adjust {
lock vec1 to vxcl(ship:facing:vector,-1*velocity:surface:normalized).
lock vec2 to vxcl(ship:facing:vector,SHIP:FACING:STARVECTOR).
//if Vdot(vec1,vec2) > 0 {return -vang(vec1,vec2).}
return vang(vec1,vec2).
   
}


function vertical_distance_trajectory {
parameter tarPos.
if abs(tarPos:bearing) < 90{
return VDOT(VXCL(UP:VECTOR, tarPos:position:NORMALIZED), VXCL(UP:VECTOR, (tarPos:position - addons:tr:impactpos:position))).}
else return -VDOT(VXCL(UP:VECTOR, tarPos:position:NORMALIZED), VXCL(UP:VECTOR, (tarPos:position - addons:tr:impactpos:position))).
}

function vertical_distance {
parameter tarPos.
if abs(tarPos:bearing) < 90{
return VDOT(VXCL(UP:VECTOR, tarPos:position:NORMALIZED), VXCL(UP:VECTOR, (tarPos:position - ship:geoposition:position))).}
else return -1*VDOT(VXCL(UP:VECTOR, tarPos:position:NORMALIZED), VXCL(UP:VECTOR, (tarPos:position - ship:geoposition:position))).
}

function horizontal_distance {
parameter Pad.
local diff is (Pad:position - addons:tr:impactpos:position).
local diff_horizontal is VXCL(UP:VECTOR, diff).
local pad_horizontal is VXCL(UP:VECTOR, Pad:position).
if VDOT(UP:VECTOR,VCRS(addons:tr:impactpos:position,Pad:position)) > 0 {return VXCL(pad_horizontal,diff_horizontal):mag.}
else return -1*(VXCL(pad_horizontal,diff_horizontal):mag).
}


function on_dir {
  parameter dir.
  parameter offset.
  if VANG(dir:vector, ship:facing:vector) < offset {return true.}
  else return false.
}

function roll_for {
  parameter ves is ship,thing is "default".

  local pointing is ves:facing.
  if not thing:istype("string") {
    if thing:istype("vessel") or pointing:istype("part") {
      set pointing to thing:facing.
    } else if thing:istype("direction") {
      set pointing to thing.
    } else {
      print "type: " + thing:typename + " is not reconized by roll_for".
	}
  }

  local trig_x is vdot(pointing:topvector,ves:up:vector).
  if abs(trig_x) < 0.0035 {//this is the dead zone for roll when within 0.2 degrees of vertical
    return 0.
  } else {
    local vec_y is vcrs(ves:up:vector,ves:facing:forevector).
    local trig_y is vdot(pointing:topvector,vec_y).
    return arctan2(trig_y,trig_x).
  }
}

function compass_and_pitch_for {
  parameter ves is ship,thing is "default".

  local pointing is ves:facing:forevector.
  if not thing:istype("string") {
    set pointing to type_to_vector(ves,thing).
  }

  local east is east_for(ves).

  local trig_x is vdot(ves:north:vector, pointing).
  local trig_y is vdot(east, pointing).
  local trig_z is vdot(ves:up:vector, pointing).

  local compass is arctan2(trig_y, trig_x).
  if compass < 0 {
    set compass to 360 + compass.
  }
  local pitch is arctan2(trig_z, sqrt(trig_x^2 + trig_y^2)).

  return list(compass,pitch).
}

function bearing_between {
  parameter ves,thing_1,thing_2.

  local vec_1 is type_to_vector(ves,thing_1).
  local vec_2 is type_to_vector(ves,thing_2).

  local fake_north is vxcl(ves:up:vector, vec_1).
  local fake_east is vcrs(ves:up:vector, fake_north).

  local trig_x is vdot(fake_north, vec_2).
  local trig_y is vdot(fake_east, vec_2).

  return arctan2(trig_y, trig_x).
}

function type_to_vector {
  parameter ves,thing.
  if thing:istype("vector") {
    return thing:normalized.
  } else if thing:istype("direction") {
    return thing:forevector.
  } else if thing:istype("vessel") or thing:istype("part") {
    return thing:facing:forevector.
  } else if thing:istype("geoposition") or thing:istype("waypoint") {
    return (thing:position - ves:position):normalized.
  } else {
    print "type: " + thing:typename + " is not recognized by lib_navball".
  }
}
