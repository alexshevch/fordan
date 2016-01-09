
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
    @getPath = _.throttle @getPath.bind(@), 1000

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
      ang = (ang + (2 * Math.PI) ) %% (2 * Math.PI)

    if(@turret > ang)
      turret = @turret - ang
      @CommandChannel
      .send @command.turretCW(Math.abs(turret) %% (2 * Math.PI))
    else
      turret = ang - @turret
      @CommandChannel
      .send @command.turretCCW(Math.abs(turret) %% (2 * Math.PI))

  getPath : (enemy) ->
    fpos = @position
    epos = enemy.position
    @world.pathFind @position, epos, (path) =>
      if _.isArray path
        @path = path

      try
        length = Math.min(5, @path.length)
        ang = Math.atan2(@path[length].y - fpos[1], @path[length].x - fpos[0])
        # @path.splice 0,length
        if ang < 0
          ang = (ang + (2 * Math.PI) ) %% (2 * Math.PI)

        if(@tracks > ang)
          tracks = @tracks - ang
          @CommandChannel
          .send @command.tankCW(Math.abs(tracks) %% (2 * Math.PI))
        else
          tracks = ang - @tracks
          @CommandChannel
          .send @command.tankCCW(Math.abs(tracks) %% (2 * Math.PI))

        setTimeout =>
          @CommandChannel
          .send @command.moveForward 20
        , tracks * 1.5
      catch e
        screen3 e.stack
    @world.easystar.calculate()


  handleMessage : (enemies, friendlys) ->

    delayedFire = (thisTank, delay) ->
      setTimeout ->
        thisTank.CommandChannel
        .send thisTank.command.fire()

        thisTank.CommandChannel
        .send thisTank.command.fire()
      , delay

    friendsInRange = (target, thisTank) ->
      e = target.position
      t = thisTank.position
      maxX = Math.max e.x, t.x
      maxY = Math.max e.y, t.y
      minX = Math.min e.x, t.x
      minY = Math.min e.y, t.y
      for friend in friendlys
        f = friend.position
        if thisTank.id is friend.id
          continue
        if Math.abs(t.x - f.x) < 10 and Math.abs(t.y - f.y) < 10
          return true
        # check if friend is in fire range
        if minX <= f.x and f.x <= maxX and minY <= f.y and f.y <= maxY
          # check if friend is blocking fire
          dx1 = f.x - t.x
          dy1 = f.y - t.y
          dx2 = e.x - t.x
          dy2 = e.y - t.y

          cross = dx1 * dy2 - dy1 * dx2
          screen3 "cross product:"
          screen3 cross
          if Math.abs(cross) < 15
            return true
      return false

    enemy = @world.getNearestEnemy enemies, @
    #if @world.allowFire enemy, @
      #@target enemy
      #@getPath enemy

    @target enemy

    enemyDist = @world.distanceToPoint(enemy.position, @position)

    if enemyDist <= 100
      if friendsInRange enemy, @
        @CommandChannel
        .send @command.moveBackward 5
        screen3 "friend in range"
      else
        delayedFire @, 0

        @CommandChannel
        .send @command.moveBackward 4 + Math.random() * 12000

        delayedFire @, 0

        delayedFire @, 2 + Math.random() * 1500
    else
      @CommandChannel
      .send @command.moveForward 10

    return
