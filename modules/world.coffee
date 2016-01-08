
logging = require('./logging.coffee')
math = require 'mathjs'
RTree = require 'rtree'
EasyStar = require 'easystarjs'

screen4 = logging 4

module.exports = class World
  constructor : (@map) ->
    @RTree = new RTree(10)
    @solidOnly = new RTree(10)
    screen4 @map.terrain.length
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
    for y in [(@map.size[1])..0]
      submatrix = []
      for x in [(@map.size[0])..0]
        # if x < 2 or y <2
        #   submatrix.push 1
        # else
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
    @easystar.enableDiagonals()
    # fs = require 'fs'
    # fs.writeFile 'thing', JSON.stringify matrix
  haveFiringSolution : (enemy, friendly) ->


  pathFind : (pointA, pointB, cb) ->
    @easystar.findPath(Math.round(pointA[0]), Math.round(pointA[1]), Math.round(pointB[0]), Math.round(pointB[1]), cb)

  distanceToPoint : (pointA, pointB) ->
    math.chain(pointA).subtract(pointB).abs().hypot().done()

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

  getTanksInRange : (enemies, friendly) ->
    for enemy in enemies
      unless enemy.alive
        continue
      if @distanceToPoint friendly.position, enemy.position <= 100
        return enemy

  getNearestEnemy : (enemies, friendly) ->

    closest = Infinity
    closestEnemy = enemies[0]
    #screen4 "positions:"
    #screen4 friendly.position[0]
    for enemy in enemies
      unless enemy.alive or @allowFire enemy, friendly
        continue
      dist = @distanceToPoint friendly.position, enemy.position
      if closest > dist
        closest = dist
        closestEnemy = enemy

    closestEnemy
