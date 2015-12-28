
logging = require('./logging.coffee')
math = require 'mathjs'
RTree = require 'rtree'
EasyStar = require 'easystarjs'

screen4 = logging 4

module.exports = class World
  constructor : (@map) ->
    @RTree = new RTree(10)

    screen4 @map.terrain.length
    for tile in @map.terrain
      t = tile.boundingBox
      block =
        x: t.corner[0]
        y: t.corner[1]
        w: t.size[0]
        h: t.size[1]
      @RTree.insert(block, block)

    matrix = []
    for y in [@map.size[1]..0]
      submatrix = []
      for x in [@map.size[0]..0]
        blockages = @RTree.search(
          x: x
          y: y
          w: 1
          h: 1 ).length
        submatrix.push if blockages > 0 then 1 else 0
      matrix.push submatrix
    @easystar = new EasyStar.js()
    screen4 matrix.length
    @easystar.setGrid(matrix)
    @easystar.setAcceptableTiles([0])
    @easystar.setIterationsPerCalculation(500)

    str = ""
    for i in matrix
      str+=i.toString()+'\n'
    fs = require 'fs'
    fs.writeFile 'thing', str

  pathFind : (pointA, pointB, cb) ->
    @easystar.findPath(Math.round(pointA[0]), Math.round(pointA[1]), Math.round(pointB[0]), Math.round(pointB[1]), cb)

  distanceToPoint : (pointA, pointB) ->
    math.chain(pointA).subtract(pointB).abs().hypot().done()

  getTanksInRange : (enemies, friendly) ->
    for enemy in enemies
      unless enemy.alive
        continue
      if @distanceToPoint friendly.position, enemy.position <= 100
        return enemy

  getNearestEnemy : (enemies, friendly) ->

    closest = Infinity
    closestEnemy = enemies[0]
    for enemy in enemies
      unless enemy.alive
        continue
      dist = @distanceToPoint friendly.position, enemy.position
      if closest > dist
        closest = dist
        closestEnemy = enemy

    closestEnemy
