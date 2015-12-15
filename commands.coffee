module.exports = class Commands
  constructor : (@token) ->

  stop : () ->
    tank_id : "eb49f487-92dc-4f66-ac83-91ae04a4cc16"
    comm_type : "STOP"
    # one of MOVE, ROTATE, ROTATE_TURRET, FIRE
    control : "ROTATE"
    client_token : @token
  fire : () ->
    tank_id : "eb49f487-92dc-4f66-ac83-91ae04a4cc16"
    comm_type : "FIRE"
    client_token : @token
  move : () ->
    tank_id : "eb49f487-92dc-4f66-ac83-91ae04a4cc16"
    comm_type : "MOVE"
    direction : "FWD"
    distance : 10
    client_token : @token
  rotateTurret : () ->
    tank_id : "eb49f487-92dc-4f66-ac83-91ae04a4cc16"
    comm_type : "ROTATE_TURRET"
    direction : "CCW"
    rads : 1.11
    client_token : @token
  rotateTank : () ->
    tank_id : "eb49f487-92dc-4f66-ac83-91ae04a4cc16"
    comm_type : "ROTATE"
    direction : "CW"
    rads : 3.14
    client_token : @token
