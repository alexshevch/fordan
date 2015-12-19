logging = require('./logging.coffee')
module.exports = class Tank
  Map = require './map.coffee'
  Commands = require './commands.coffee'
  math = require 'mathjs'
  _ = require 'lodash'
  screen3 = logging 3

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

  handleMessage : (map, enemies, friendlys, CommandChannel) ->
    enemy = Map.getNearestEnemy @, enemies
    rad = Map.getRadToTarget enemy, @
    screen3 rad.toString()
    CommandChannel
    .send @command.moveForward 10
    .send @command.rotateTurretCW rad
    .send @command.fire()
    .send @command.rotateCW rad
