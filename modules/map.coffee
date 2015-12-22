
logging = require('./logging.coffee')
screen4 = logging 4
module.exports =

  distanceToPoint : (pointA, pointB) ->
    math.chain(pointA).subtract(pointB).abs().hypot().done()

  defaultReturn : ->
    true

  getTanksInRange : (enemies, friendly) ->
    for enemy in enemies
      if enemy.alive
        if @distanceToPoint friendly.position, enemy.position <= 50
          return enemy

  getNearestEnemy : (enemies, friendly, extraCondtions = @defaultReturn) ->
    closest = Infinity
    closestEnemy = enemies[0]
    for enemy in enemies
      if enemy.alive and extraCondtions(enemy)
        dist = @distanceToPoint friendly.position, enemy.position
        if closest > dist
          closest = dist
          closestEnemy = enemy

    screen4 dist
    closestEnemy
