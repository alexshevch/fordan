
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
      x: @position[0]
      y: @position[1]
      h: @hitRadius+2
      w: @hitRadius+2

    screen3 roadBlocks, false if roadBlocks.length > 0
    # for block in roadBlocks
    #   if @position[0] > block.x
    #     # blockage on the left
    #     if @position[1] < enemy.position[1]
    #       ang = 1.5708
    #     else
    #       ang = 4.71239
    #   else if @position[0] < block.x
    #     # block on the right
    #     if @position[1] < enemy.position[1]
    #       ang = 1.5708
    #     else
    #       ang = 4.71239
    #   if @position[1] > block.y
    #     # blockage on the bottom
    #     if @position[0] < enemy.position[0]
    #       ang = 0
    #     else
    #       ang = 3.14159
    #   else if @position[1] < block.y
    #     # Blockage on the top
    #     if @position[0] < enemy.position[0]
    #       ang = 0
    #     else
    #       ang = 3.14159

    if(@tracks > ang)
      angle = @tracks - ang
      @CommandChannel
      .send @command.tankCW(Math.abs(angle) % (2 * Math.PI))
    else
      angle = ang - @tracks
      @CommandChannel
      .send @command.tankCCW(Math.abs(angle) % (2 * Math.PI))

    if(@turret > ang)
      angle = @turret - ang
      @CommandChannel
      .send @command.turretCW(Math.abs(angle) % (2 * Math.PI))
    else
      angle = ang - @turret
      @CommandChannel
      .send @command.turretCCW(Math.abs(angle) % (2 * Math.PI))
    return

  handleMessage : (enemies, friendlys) ->
    enemy = @world.getNearestEnemy enemies, @
    @target enemy

    if @world.distanceToPoint(enemy.position, @position) <= 100
      @CommandChannel
      .send @command.fire()

    @CommandChannel
    .send @command.moveForward 10

    return
