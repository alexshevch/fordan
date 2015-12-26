
logging = require('./logging.coffee')
math = require 'mathjs'
RTree = require './r-tree.js'

screen4 = logging 4

module.exports = class World
  constructor : (terrain) ->
    @RTree = new RTree(10)

    for tile in terrain
      t = tile.boundingBox
      block =
        x: t.corner[0]
        y: t.corner[1]
        w: t.size[0]
        h: t.size[1]

      @RTree.insert(block, block)

    @search = @RTree.search.bind @RTree

  distanceToPoint : (pointA, pointB) ->
    math.chain(pointA).subtract(pointB).abs().hypot().done()

  getTanksInRange : (enemies, friendly) ->
    for enemy in enemies
      unless enemy.alive
        continue
      if @distanceToPoint friendly.position, enemy.position <= 100
        return enemy

  getNearestEnemy : (enemies, friendly, rTree) ->
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
