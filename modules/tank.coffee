
Commands = require './commands.coffee'
logging = require './logging.coffee'

_ = require 'lodash'
math = require 'mathjs'

screen3 = logging 3
screen5 = logging 5
module.exports = class Tank

  constructor : (rawTank, @CommandChannel, @world) ->
    _.extend @, rawTank
    @command = new Commands(@id)
    # @target = _.throttle @target.bind(@), 10
    # @getPath = _.throttle @getPath.bind(@), 2000/@speed

  update : (data) ->
    {@position, @tracks, @type, @turret, @projectiles} = data

  calcLead : (enemy) ->
    epos = enemy.position
    vy = enemy.speed * Math.sin(enemy.tracks)
    vx = enemy.speed * Math.cos(enemy.tracks)

    rCrossV = epos[0] * vy - epos[1] * vx
    magR = Math.sqrt(epos[0]*epos[0] + epos[1]*epos[1])
    angleAdjust = Math.asin(rCrossV / (30 * magR))

  target : (enemy, dist) ->
    fpos = @position
    epos = enemy.position

    adjust = @calcLead(enemy)

    ang1 = Math.atan2(epos[1] - fpos[1] + enemy.hitRadius, epos[0] - fpos[0] + enemy.hitRadius)
    ang2 = Math.atan2(epos[1] - fpos[1] - enemy.hitRadius, epos[0] - fpos[0] - enemy.hitRadius)
    ang = ((ang1 + ang2) / 2)

    turret = Math.atan2(Math.sin(ang-@turret), Math.cos(ang-@turret))
    if(turret < 0)
      @CommandChannel
      .send @command.turretCW(Math.abs(turret))
    else
      @CommandChannel
      .send @command.turretCCW(Math.abs(turret))

    setTimeout =>
      if dist <= 100

        @CommandChannel
        .send @command.fire()

        setTimeout =>
          @CommandChannel
          .send @command.fire()
        ,  _.random(0, 2500)

    , (turret * 1.5)*1000

  getPath : (enemy, dist) ->

    fpos = @position
    epos = enemy.position
    @path = @world.pathFind fpos, enemy.position
    if _.isEmpty @path
      fpos[0] = fpos[0] + _.random(-5,5)
      fpos[1] = fpos[1] + _.random(-5,5)
      @path = @world.pathFind fpos, enemy.position
      if _.isEmpty @path
        return
    screen3 "#{JSON.stringify @path}"
    try
      length = Math.min(1, @path.length)
      ang = Math.atan2(@path[length][0] - fpos[1], @path[length][1] - fpos[0])
      tracks = Math.atan2(Math.sin(ang-@tracks), Math.cos(ang-@tracks))

      if(tracks < 0)
        @CommandChannel
        .send @command.tankCW(Math.abs(tracks))
      else
        @CommandChannel
        .send @command.tankCCW(Math.abs(tracks))

      setTimeout =>
        if dist <= 100
          if Math.random() < 0.2
            @CommandChannel
            .send @command.moveBackward _.random(0,18)
          else
            @CommandChannel
            .send @command.moveForward _.random(0,18)

        else
          @CommandChannel
          .send @command.moveForward 10
      , (tracks * 1.5)*1000


  handleMessage : (enemies, friendlys) ->
    enemy = @world.getNearestPathEnemy(enemies, @)
    @target(enemy.closestEnemy, enemy.dist)
    @getPath(enemy.closestEnemy, enemy.dist)

    return
