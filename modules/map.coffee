
logging = require('./logging.coffee')
screen4 = logging 4
module.exports =

  distanceToPoint : (pointA, pointB) ->
    Math.hypot(Math.abs(pointA[0] - pointB[0]), Math.abs(pointA[1] - pointB[1]))

  getNearestEnemy : (enemies, friendly) ->
    closest = Infinity
    closestEnemy = enemies[0]
    for enemy in enemies
      if enemy.alive
        dist = @distanceToPoint friendly.position, enemy.position
        if closest > dist
          closest = dist
          closestEnemy = enemy

    screen4 dist
    closestEnemy
