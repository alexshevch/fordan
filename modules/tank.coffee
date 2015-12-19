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
    if @tracks > rad
      CommandChannel
      .send @command.turretCW rad
    else
      CommandChannel
      .send @command.turretCCW rad

    if @turret > rad
      CommandChannel
      .send @command.tankCCW rad
    else
      CommandChannel
      .send @command.tankCW rad

    CommandChannel
    .send @command.moveForward 10
    .send @command.fire()
