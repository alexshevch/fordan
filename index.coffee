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

Map = require './modules/map.coffee'
Commands = require './modules/commands.coffee'
_ = require 'lodash'

class CommandChannel
  zmq = require 'zmq'
  sock = zmq.socket 'req'

  constructor : (options) ->
    {@server, @token, @password, @teamName} = options
    # console.log @MatchConnect()
    sock.connect "tcp://#{@server}:5557"
    sock.send @MatchConnect()
    sock.on 'message', @handleMessage.bind @

  handleMessage : (data) ->
    JSONdata = JSON.parse data
    if JSONdata.comm_type is "MatchConnectResp"
      @client_token = JSONdata.client_token
      # console.log @
      # console.log "CommandChannel: #{data}"
    logging.screen1 JSON.stringify(JSONdata, null, 2)

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
  zmq = require 'zmq'
  sock = zmq.socket 'sub'
  initialState = true

  constructor : (options) ->
    {@server, @token, @password, @teamName} = options
    @commandChannel = new CommandChannel(options)
    sock.connect "tcp://#{@server}:5556"
    sock.subscribe(@token)
    sock.on 'message', @handleMessage.bind @

  handleMessage : (token, state) ->
    JSONdata = JSON.parse state
    if JSONdata.comm_type isnt 'GAMESTATE'
      logging.screen2 JSON.stringify(JSONdata, null, 2)
      return
    if initialState
      friendly = JSONdata.players[1]
      @tanks = for tank in friendly.tanks
        command = new Commands(tank.id)
        new Tank(tank, command)
      initialState = false
    else
      for tank in @tanks
        tank.handleMessage JSONdata.map, JSONdata.players[0].tanks, @commandChannel


SC = new StateChannel(argv)

class Tank
  _ = require('lodash')
  constructor : (tank, @commands) ->
    _.extend @, tank

  handleMessage : (map, enemies, CommandChannel) ->
    CommandChannel.send @commands.moveForward 20
    CommandChannel.send @commands.rotateTurretCCW(0.5)
    CommandChannel.send @commands.fire()
    CommandChannel.send @commands.rotateCW .4
