# They setup the library weird. This import method works...
zmq = require './node_modules/zmq/'
console.log zmq

class Server

	constructor : (@server, @token, @password, @teamName) ->

class Commands

	fire : () ->

	move : () ->

	rotateTurret : () ->

	rotateTank : () ->

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
