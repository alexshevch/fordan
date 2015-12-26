
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

    roadBlocks = @world.search
      x: @position[0]
      y: @position[1]
      h: @hitRadius+2
      w: @hitRadius+2

    screen3 roadBlocks if roadBlocks.length > 0
    for block in roadBlocks
      if @position[0] > block.x
        # blockage on the left
        if @position[1] < enemy.position[1]
          things = 1.5708
        else
          things = 4.71239
      else if @position[0] < block.x
        # block on the right
        if @position[1] < enemy.position[1]
          things = 1.5708
        else
          things = 4.71239
      if @position[1] > block.y
        # blockage on the bottom
        if @position[0] < enemy.position[0]
          things = 0
        else
          things = 3.14159
      else if @position[1] < block.y
        # Blockage on the top
        if @position[0] < enemy.position[0]
          things = 0
        else
          things = 3.14159

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
    enemy = @world.getNearestEnemy enemies, @
    @targetTurret enemy
    @rotateTracks enemy

    if @world.distanceToPoint(enemy.position, @position) <= 50
      @CommandChannel
      .send @command.fire()

    @CommandChannel
    .send @command.moveForward 10

    return
