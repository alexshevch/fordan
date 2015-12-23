Commands = require './commands.coffee'
Map = require './map.coffee'
_ = require 'lodash'
logging = require('./logging.coffee')
math = require 'mathjs'
ppDist = require("point-polygon-distance")
screen3 = logging 3

module.exports = class Tank

  tankTypes =
    fast :
      rof: 5 # seconds delay
      turretRotation: 1.5 # rads
      tankRotation: 1.5 # rads
    slow :
      rof: 3 # seconds delay
      turretRotation: 1 # rads
      tankRotation: 1 # rads

  constructor : (tank, @CommandChannel, @globalState) ->
    _.extend @, tank
    @command = new Commands(@id)

  update : (data) ->
    {@position, @tracks, @type, @turret, @projectiles} = data

  targetTurret : (enemy) ->
    fpos = @position
    epos = enemy.position

    ang1 = Math.atan2(epos[1] - fpos[1] + enemy.hitRadius, epos[0] - fpos[0] + enemy.hitRadius)
    ang2 = Math.atan2(epos[1] - fpos[1] - enemy.hitRadius, epos[0] - fpos[0] - enemy.hitRadius)
    # This controls to tracks to point to the enemy
    cang = @turret
    ang = (ang1 + ang2) / 2

    if ang < 0
      ang = (ang + (2 * Math.PI) ) % (2 * Math.PI)

    if(cang > ang)
      ang = cang - ang
      @CommandChannel
      .send @command.turretCW(Math.abs(ang) % (2 * Math.PI))

    else
      ang = ang - cang
      @CommandChannel
      .send @command.turretCCW(Math.abs(ang) % (2 * Math.PI))
    return

  rotateTracks : (enemy) ->
    fpos = @position
    epos = enemy.position

    ang1 = Math.atan2(epos[1] - fpos[1] + enemy.hitRadius, epos[0] - fpos[0] + enemy.hitRadius)
    ang2 = Math.atan2(epos[1] - fpos[1] - enemy.hitRadius, epos[0] - fpos[0] - enemy.hitRadius)
    # This controls to tracks to point to the enemy
    cang = @tracks
    ang = (ang1 + ang2) / 2

    if ang < 0
      ang = (ang + (2 * Math.PI) ) % (2 * Math.PI)

    if(cang > ang)
      ang = cang - ang
      @CommandChannel
      .send @command.tankCW(Math.abs(ang) % (2 * Math.PI))

    else
      ang = ang - cang
      @CommandChannel
      .send @command.tankCCW(Math.abs(ang) % (2 * Math.PI))
    return

  handleMessage : (enemies, friendlys) ->
    enemy = Map.getNearestEnemy enemies, @
    @targetTurret enemy
    @rotateTracks enemy

    if Map.distanceToPoint(enemy.position, @position) <= 50
      @CommandChannel
      .send @command.fire()

    @CommandChannel
    .send @command.moveForward 10

    return
