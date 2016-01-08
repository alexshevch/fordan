
logging = require('./logging.coffee')
math = require 'mathjs'
RTree = require 'rtree'
EasyStar = require 'easystarjs'
ndarray = require('ndarray')
createPlanner = require('l1-path-finder')
_ = require 'lodash'

module.exports = class World
  constructor : (@map) ->
    @RTree = new RTree(10)
    @solidOnly = new RTree(10)
    # screen4 @map.terrain.length
    for tile in @map.terrain
      t = tile.boundingBox
      block =
        x: t.corner[0]
        y: t.corner[1]
        w: t.size[0]
        h: t.size[1]
      @RTree.insert(block, block)
      if tile.type is "SOLID"
        @solidOnly.insert block,block

    matrix = []
    for y in [0..(@map.size[1])]
      for x in [(@map.size[0])..0]
        blockages = @RTree.search(
          x: x
          y: y
          w: 3
          h: 2 ).length
        matrix.push if blockages > 0 then 1 else 0

    mat = ndarray(matrix, [@map.size[1],@map.size[0]])
    @planner = createPlanner(mat)

  distanceToPoint : (pointA, pointB) ->
    math.chain(pointA).subtract(pointB).abs().hypot().done()

  pathFind : (pointA, pointB) ->
    _.chunk @getFullDataForPoint(pointA, pointB).path, 2

  distFind : (pointA, pointB) ->
    @getFullDataForPoint(pointA, pointB).dist

  getFullDataForPoint : (pointA, pointB) ->
    path = []
    dist = @planner.search(
      Math.round(pointA[1]),
      Math.round(pointA[0]),
      Math.round(pointB[1]),
      Math.round(pointB[0]),
      path)
    {
      path: path
      dist: dist
    }

  getNearestPathEnemy : (enemies, friendly) ->

    closest = Infinity
    closestEnemy = enemies[0]
    for enemy in enemies
      unless enemy.alive
        continue
      dist = @distFind(friendly.position, enemy.position)
      if closest > dist
        closest = dist
        closestEnemy = enemy

    {
      closestEnemy: closestEnemy
      dist: closest
    }
