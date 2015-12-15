module.exports = class Commands
  constructor : (@token) ->

  stop : (id, type) ->
    JSON.stringify
      tank_id : id
      comm_type : "STOP"
      # one of MOVE, ROTATE, ROTATE_TURRET, FIRE
      control : type
      client_token : @token
  fire : (id) ->
    JSON.stringify
      tank_id : id
      comm_type : "FIRE"
      client_token : @token
  move : (id, direction) ->
    JSON.stringify
      tank_id : id
      comm_type : "MOVE"
      # FWD or REV
      direction : direction
      distance : 10
      client_token : @token
  rotateTurret : (id, direction, rads) ->
    JSON.stringify
      tank_id : id
      comm_type : "ROTATE_TURRET"
      direction : direction
      rads : rads
      client_token : @token
  rotateTank : (id, direction, rads) ->
    JSON.stringify
      tank_id : id
      comm_type : "ROTATE"
      # CW or CCW
      direction : direction
      rads : rads
      client_token : @token
