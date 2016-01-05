argv = require('optimist')
.usage '-t token  -s server -n team_name -p team_password'
.default 'n', 'fordan'
.default 'p', 'manoui'
.alias 't', 'token'
.alias 's', 'server'
.alias 'n', 'teamName'
.alias 'p', 'password'
.argv;

Tank = require './modules/tank'
World = require './modules/world.coffee'
logging = require './modules/logging.coffee'

_ = require 'lodash'
zmq = require 'zmq'
math = require 'mathjs'

screen0 = logging 0,4
screen1 = logging 1,5

class CommandChannel
  sock = zmq.socket 'req'

  constructor : (options) ->
    {@server, @token, @password, @teamName} = options
    sock.connect "tcp://#{@server}:5557"
    sock.on 'message', @handleMessage.bind @
    # do need this VERY FIRST/INITIAL connect when the match
    # hasn't started there wont be any sub data
    do @connect

  handleMessage : (data) ->
    data = JSON.parse data
    if data.comm_type is "MatchConnectResp"
      @client_token = data.client_token
      screen0 data
    else
      screen1 data

  connect : ->
    sock.send JSON.stringify
      "comm_type" : "MatchConnect"
      "match_token" : @token
      "team_name" : @teamName
      "password" : @password

  send : (data) ->
    data.client_token = @client_token
    sock.send JSON.stringify data
    @

screen2 = logging 2

class StateChannel
  sock = zmq.socket 'sub'
  shouldInitialize = true

  constructor : (options) ->
    {@server, @token, @password, @teamName} = options
    @commandChannel = new CommandChannel(options)
    sock.connect "tcp://#{@server}:5556"
    sock.on 'message', @handleUpdate.bind(@)
    sock.subscribe(@token)

  initialize : (data) ->
    @commandChannel.connect()
    # @world = new World(data.map)
    @tanks = {}
    shouldInitialize = false
    return

  # index one isnt always the friendly team and vice versa
  getFriendly : (data) ->
    friendly = data.players[1]
    if friendly.name isnt @teamName
      friendly = data.players[0]
    return friendly

  getEnemy : (data) ->
    enemy = data.players[1]
    if enemy.name is @teamName
      enemy = data.players[0]
    return enemy

  handleUpdate : (token, state) ->
    data = JSON.parse state
    if data.comm_type isnt 'GAMESTATE'
      screen2 data

    if (data.comm_type is "GAME_END") or (data.comm_type is "GAME_START")
      shouldInitialize = true
      return

    if data.comm_type is "MatchEnd"
      process.exit 0

    if shouldInitialize
      return @initialize(data)

    if (data.comm_type is 'GAMESTATE')
      friendly = @getFriendly data
      enemy = @getEnemy data
      for tank in friendly.tanks
        if not tank.alive
          delete @tanks[tank.id]
          continue
        if not(_.isObject @tanks[tank.id])
          world = new World(data.map)
          @tanks[tank.id] = new Tank(tank, @commandChannel, world)
        @tanks[tank.id].update tank
        @tanks[tank.id].handleMessage enemy.tanks, friendly.tanks

    return

SC = new StateChannel(argv)
