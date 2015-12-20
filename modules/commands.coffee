module.exports = class Commands

  constructor : (@id) ->

  turret :
    CW : (rads) =>
      tank_id : @id
      comm_type : "ROTATE_TURRET"
      direction : "CW"
      rads : rads
    CCW : (rads) =>
      tank_id : @id
      comm_type : "ROTATE_TURRET"
      direction : "CCW"
      rads : rads
  tank :
    CW : (rads) =>
      tank_id : @id
      comm_type : "ROTATE"
      direction : "CW"
      rads : rads
    CCW : (rads) =>
      tank_id : @id
      comm_type : "ROTATE"
      direction : "CCW"
      rads : rads

  stop : (type) ->
    tank_id : @id
    comm_type : "STOP"
    control : type
  fire : ->
    tank_id : @id
    comm_type : "FIRE"
  moveForward : (distance) ->
    tank_id : @id
    comm_type : "MOVE"
    direction : "FWD"
    distance : distance
  moveBackward : (distance) ->
    tank_id : @id
    comm_type : "MOVE"
    direction : "REV"
    distance : distance
