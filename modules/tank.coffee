
Commands = require './commands.coffee'
logging = require './logging.coffee'

_ = require 'lodash'
math = require 'mathjs'

screen3 = logging 3

module.exports = class Tank

  constructor : (rawTank, @CommandChannel, @world) ->
    _.extend @, rawTank
    @command = new Commands(@id)
    # @target = _.throttle @target.bind(@), 10
    @getPath = _.throttle @getPath.bind(@), 30

  update : (data) ->
    {@position, @tracks, @type, @turret, @projectiles} = data

  calcLead : (enemy) ->
    epos = enemy.position
    vy = enemy.speed * Math.sin(enemy.tracks)
    vx = enemy.speed * Math.cos(enemy.tracks)

    rCrossV = epos[0] * vy - epos[1] * vx
    magR = Math.sqrt(epos[0]*epos[0] + epos[1]*epos[1])
    angleAdjust = Math.asin(rCrossV / (30 * magR))

  target : (enemy) ->
    fpos = @position
    epos = enemy.position

    adjust = @calcLead(enemy)

    ang1 = Math.atan2(epos[1] - fpos[1] + enemy.hitRadius, epos[0] - fpos[0] + enemy.hitRadius)
    ang2 = Math.atan2(epos[1] - fpos[1] - enemy.hitRadius, epos[0] - fpos[0] - enemy.hitRadius)
    ang = ((ang1 + ang2) / 2)
    if ang < 0
      ang = (ang + (2 * Math.PI) ) % (2 * Math.PI)

    if(@turret > ang)
      turret = @turret - ang
      @CommandChannel
      .send @command.turretCW(Math.abs(turret) % (2 * Math.PI))
    else
      turret = ang - @turret
      @CommandChannel
      .send @command.turretCCW(Math.abs(turret) % (2 * Math.PI))

  getPath : (enemy) ->
    fpos = @position
    epos = enemy.position
    @world.pathFind @position, epos, (path) =>
      unless _.isArray path
        return
        # path = path

      try
        length = Math.round(path.length*0.05)
        ang = Math.atan2(path[length].y - fpos[1], path[length].x - fpos[0])
        screen3 "#{@id} #{path.length}"
        if ang < 0
          ang = (ang + (2 * Math.PI) ) % (2 * Math.PI)

        if(@tracks > ang)
          tracks = @tracks - ang
          @CommandChannel
          .send @command.tankCW(Math.abs(tracks) % (2 * Math.PI))
        else
          tracks = ang - @tracks
          @CommandChannel
          .send @command.tankCCW(Math.abs(tracks) % (2 * Math.PI))


        @CommandChannel
        .send @command.moveForward length
    @world.easystar.calculate()


  handleMessage : (enemies, friendlys) ->
    enemy = @world.getNearestEnemy enemies, @
    @target enemy
    @getPath enemy

    enemyDist = @world.distanceToPoint(enemy.position, @position)
    if enemyDist <= 100
      @CommandChannel
      .send @command.fire()
      #
      # @CommandChannel
      # .send @command.moveBackward 5
      #
      # @CommandChannel
      # .send @command.fire()

    # else

    return
