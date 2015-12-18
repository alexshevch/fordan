module.exports = class Tank
  Map = require './map.coffee'
  Commands = require './commands.coffee'
  math = require 'mathjs'
  _ = require 'lodash'

  tankTypes =
    fast :
      rof: 5 # seconds delay
      turretRotation: 1.5 # rads
      tankRotation: 1.5 # rads
    slow :
      rof: 3 # seconds delay
      turretRotation: 1 # rads
      tankRotation: 1 # rads

  constructor : (tank) ->
    _.extend @, tank
    @command = new Commands(@id)

  update : (data) ->
    {@position, @tracks, @type, @turret, @projectiles} = data

  target : (enemyId) ->
    1

  handleMessage : (map, enemies, friendlys, CommandChannel) ->
    enemy = Map.getNearestEnemy @, enemies

    CommandChannel.send @command.moveForward 20
    CommandChannel.send @command.rotateTurretCW(0.4)
    CommandChannel.send @command.fire()
    CommandChannel.send @command.rotateCW .4
