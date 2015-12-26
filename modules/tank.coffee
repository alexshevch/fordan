
Commands = require './commands.coffee'
logging = require('./logging.coffee')

_ = require 'lodash'
math = require 'mathjs'

screen3 = logging 3

module.exports = class Tank

  constructor : (rawTank, @CommandChannel, @world) ->
    _.extend @, rawTank
    @command = new Commands(@id)

  update : (data) ->
    {@position, @tracks, @type, @turret, @projectiles} = data

  target : (enemy) ->
    fpos = @position
    epos = enemy.position

    ang1 = Math.atan2(epos[1] - fpos[1] + enemy.hitRadius, epos[0] - fpos[0] + enemy.hitRadius)
    ang2 = Math.atan2(epos[1] - fpos[1] - enemy.hitRadius, epos[0] - fpos[0] - enemy.hitRadius)
    ang = (ang1 + ang2) / 2

    if ang < 0
      ang = (ang + (2 * Math.PI) ) % (2 * Math.PI)

    roadBlocks = @world.search
      x: @position[0]-@hitRadius-100
      y: @position[1]-@hitRadius-100
      h: @hitRadius+100
      w: @hitRadius+100

    # collision detection code. Simulates repulsion from obstacles.
    # Not exactly pathfinding
    for block in roadBlocks
      blockAngle = Math.atan2(block.centerY-@position[1], block.centerX-@position[0])
      dist = @world.distanceToPoint @position, [block.centerX, block.centerY]
      if blockAngle < 0
        trackAngle = ang - (100 / (dist))
      else
        trackAngle = ang + (100 / (dist))

    tankoffsetAmount = 0
    if(@tracks > trackAngle)
      tracks = @tracks - trackAngle
      -tankoffsetAmount = tracks
      @CommandChannel
      .send @command.tankCW(Math.abs(tracks) % (2 * Math.PI))
    else
      tracks = trackAngle - @tracks
      tankoffsetAmount = tracks
      @CommandChannel
      .send @command.tankCCW(Math.abs(tracks) % (2 * Math.PI))

    if(@turret > ang)
      turret = @turret - ang + tankoffsetAmount
      @CommandChannel
      .send @command.turretCW(Math.abs(turret) % (2 * Math.PI))
    else
      turret = ang - @turret + tankoffsetAmount
      @CommandChannel
      .send @command.turretCCW(Math.abs(turret) % (2 * Math.PI))
    return turret

  handleMessage : (enemies, friendlys) ->
    enemy = @world.getNearestEnemy enemies, @
    turretDifference = @target enemy

    if @world.distanceToPoint(enemy.position, @position) <= 100
      @CommandChannel
      .send @command.fire()

    @CommandChannel
    .send @command.moveForward 10

    return
