

module.exports =

  distanceToPoint : (pointA, pointB) ->
    Math.hypot(Math.abs(pointA[0] - pointB[0]), Math.abs(pointA[1] - pointB[1]))

  getNearestEnemy : (friendly, enemies) ->
    # Place holder
    for enemy in enemies
      if enemy.alive
        return enemy
