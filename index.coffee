argv = require('optimist')
.usage '-t token  -s server -n team_name -p team_password'
.default 'n', 'fordan'
.default 'p', 'manoui'
.alias 't', 'token'
.alias 's', 'server'
.alias 'n', 'teamName'
.alias 'p', 'password'
.argv;
logging = require('./logging.coffee')
Tank = require './modules/tank.coffee'

_ = require 'lodash'
cson = require 'cson'
zmq = require 'zmq'

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
      logging.screen2 cson.stringify(data, null, 2)
    else
      logging.screen1 cson.stringify(data, null, 2)

  connect : ->
    sock.send @MatchConnect()

  MatchConnect : ->
    JSON.stringify
      "comm_type" : "MatchConnect",
      "match_token" : @token,
      "team_name" : @teamName,
      "password" : @password

  send : (data) ->
    data.client_token = @client_token
    sock.send JSON.stringify data

class StateChannel
  sock = zmq.socket 'sub'
  shouldInitialize = true

  constructor : (options) ->
    {@server, @token, @password, @teamName} = options
    @commandChannel = new CommandChannel(options)
    sock.connect "tcp://#{@server}:5556"
    sock.on 'message', @handleMessage.bind @
    sock.subscribe(@token)

  handleMessage : (token, state) ->
    data = JSON.parse state
    if data.comm_type isnt 'GAMESTATE'
      logging.screen2 cson.stringify(data, null, 2)

    if (data.comm_type is "GAME_END") or (data.comm_type is "GAME_START")
      shouldInitialize = true
      return

    if data.comm_type is "MatchEnd"
      process.exit 0

    if shouldInitialize
      @commandChannel.connect()

      friendly = data.players[1]
      @tanks = {}
      for tank in friendly.tanks
        @tanks[tank.id] = new Tank(tank)
      shouldInitialize = false
      return

    if (data.comm_type is 'GAMESTATE') and (shouldInitialize is false)
      for tank in data.players[1].tanks
        @tanks[tank.id].update tank
        @tanks[tank.id].handleMessage data.map,
          data.players[0].tanks,
          data.players[1].tanks,
          @commandChannel
    return

SC = new StateChannel(argv)
