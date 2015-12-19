module.exports = class Commands
  constructor : (@id) ->
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
  turretCW : (rads) ->
    tank_id : @id
    comm_type : "ROTATE_TURRET"
    direction : "CW"
    rads : rads
  turretCCW : (rads) ->
    tank_id : @id
    comm_type : "ROTATE_TURRET"
    direction : "CCW"
    rads : rads
  tankCW : (rads) ->
    tank_id : @id
    comm_type : "ROTATE"
    # CW or CCW
    direction : "CW"
    rads : rads
  tankCCW : (rads) ->
    tank_id : @id
    comm_type : "ROTATE"
    # CW or CCW
    direction : "CCW"
    rads : rads
