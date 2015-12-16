module.exports = class Commands
  constructor : (@id) ->
  stop : (type) ->
      tank_id : @id
      comm_type : "STOP"
      # one of MOVE, ROTATE, ROTATE_TURRET, FIRE
      control : type
  fire : () ->
      tank_id : @id
      comm_type : "FIRE"
  moveForward : (distance) ->
      tank_id : @id
      comm_type : "MOVE"
      # FWD or REV
      direction : "FWD"
      distance : distance
  moveBackward : (distance) ->
      tank_id : @id
      comm_type : "MOVE"
      # FWD or REV
      direction : "REV"
      distance : distance
  rotateTurretCW : (rads) ->
      tank_id : @id
      comm_type : "ROTATE_TURRET"
      direction : "CW"
      rads : rads
  rotateTurretCCW : (rads) ->
      tank_id : @id
      comm_type : "ROTATE_TURRET"
      direction : "CCW"
      rads : rads
  rotateCW : (rads) ->
      tank_id : @id
      comm_type : "ROTATE"
      # CW or CCW
      direction : "CW"
      rads : rads
  rotateCCW : (rads) ->
      tank_id : @id
      comm_type : "ROTATE"
      # CW or CCW
      direction : "CCW"
      rads : rads
