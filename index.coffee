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
    """{
    "comm_type" : "MatchConnect",
    "match_token" : "#{@token}",
    "team_name" : "#{@teamName}",
    "password" : "#{@password}"
  }"""

  constructor : (@server, @token, @password, @teamName, @port) ->

class CommandChannel extends ServerBindings
  zmq = require 'zmq'
  sock = zmq.socket 'req'
  constructor : (@server, @token, @password, @teamName) ->
    console.log "tcp://#{@server}:5557"
    console.log @MatchConnect()
    sock.connect "tcp://#{@server}:5557"
    sock.send @MatchConnect()
    sock.on 'message', (data) ->
      console.log "CommandChannel: #{data}"

class StateChannel extends ServerBindings
  zmq = require 'zmq'
  sock = zmq.socket 'sub'
  constructor : (@server, @token, @password, @teamName) ->
    sock.connect "tcp://#{@server}:5556"
    sock.subscribe(@token);
    sock.on 'message', (token, state) ->
      console.log "StateChannel: #{state}}"

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
