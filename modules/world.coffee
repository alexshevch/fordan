
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
    for y in [0..(@map.size[1])-1]
      for x in [0..(@map.size[0])-1]
        blockages = @RTree.search(x: x, y: y, w: 2, h: 2).length
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

  allowFire : (enemy, friendly) ->
    e = enemy.position
    f = friendly.position
    xstart = if e[0] < f[0] then e[0] else f[0]
    ystart = if e[1] < f[1] then e[1] else f[1]
    widthRange = Math.abs(e[0]-f[0])
    heightRange = Math.abs(e[1]-f[1])
    solidInRange = @solidOnly.search(
      x: xstart
      y: ystart
      w: widthRange
      h: heightRange
      )
    if solidInRange.length > 0
      for terrain in solidInRange
        # calculate the cross product between enemy and friedly points
        dxe = terrain.x - e.x
        dye = terrain.y - e.y

        dxf = e.x - f.x
        dyf = e.y - f.y

        cross = dxe * dyf - dye * dxf
        if cross < 0.5
          return false
    return true

  getNearestPathEnemy : (enemies, friendly) ->

    closest = Infinity
    closestEnemy = enemies[0]
    for enemy in enemies
      if not enemy.alive
        continue
      dist = @distFind(friendly.position, enemy.position)
      if closest > dist
        closest = dist
        closestEnemy = enemy

    {
      closestEnemy: closestEnemy
      dist: closest
    }
