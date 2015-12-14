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
