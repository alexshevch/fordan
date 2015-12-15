argv = require('optimist')
.usage '-t token  -s server -n team_name -p team_password'
.demand ['t', 's']
.default 'n', 'fordan'
.default 'p', 'manoui'
.alias 't', 'token'
.alias 's', 'server'
.alias 'n', 'teamName'
.alias 'p', 'password'
.argv;

Commands = require './commands.coffee'

class ServerBindings
  MatchConnect : () ->
    JSON.stringify
      "comm_type" : "MatchConnect",
      "match_token" : @token,
      "team_name" : @teamName,
      "password" : @password

class CommandChannel extends ServerBindings
  zmq = require 'zmq'
  sock = zmq.socket 'req'
  sock.on 'message', (data) ->
    console.log "CommandChannel: #{data}"
  constructor : (@server, @token, @password, @teamName) ->
    console.log @MatchConnect()
    sock.connect "tcp://#{@server}:5557"
    sock.send @MatchConnect()

class StateChannel extends ServerBindings
  zmq = require 'zmq'
  sock = zmq.socket 'sub'
  sock.on 'message', (token, state) ->
    state = JSON.parse state
    console.log state.comm_type
    console.log state.players
    console.log state.map.size
    # console.log "StateChannel: #{state}}"
  constructor : (@server, @token, @password, @teamName) ->
    sock.connect "tcp://#{@server}:5556"
    sock.subscribe(@token)

comm = new Commands(argv.token)
CC = new CommandChannel(argv.server, argv.token, argv.password, argv.teamName)
SC = new StateChannel(argv.server, argv.token, argv.password, argv.teamName)

class Strategy

  constructor : ->

class Tank
  constructor : (@id) ->

  getState : () ->

class Map
  constructor : () ->

  # low level get state
  getTerrain : () ->

  # high level state
  getEnemies : () ->

  # high level get map state
  getFriendlies : () ->
