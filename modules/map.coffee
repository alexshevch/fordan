

module.exports =

  distanceToPoint : (pointA, pointB) ->
    Math.hypot(Math.abs(pointA[0] - pointB[0]), Math.abs(pointA[1] - pointB[1]))

  getNearestEnemy : (friendly, enemies) ->
    # Place holder
    for enemy in enemies
      if enemy.alive
        return enemy

  # http://gamedev.stackexchange.com/questions/1885/target-tracking-when-to-accelerate-and-decelerate-a-rotating-turret
  enemyRads : (enemy, friendly) ->
    turretToTarget =
      x: enemy.position[0] - friendly.position[0]
      y: enemy.position[1] - friendly.position[1]
    desiredAngle = Math.atan2(turretToTarget.y, turretToTarget.x)
    angleDiff = desiredAngle - friendly.turret # angle

    # Normalize angle to [-PI,PI] range. This ensures that the turret
    # turns the shortest way.
    while (angleDiff < -Math.PI)
      angleDiff += 2*Math.PI
    while (angleDiff >= Math.PI)
      angleDiff -= 2*Math.PI
    C0 = 0.5 # Must be determined by trial error
    C1 = 2*Math.sqrt(C0)
    angularAcc = C0 * angleDiff - C1 * 1.5

    predictionTime = 1 # One second prediction, you need to experiment.
    turretToTarget = enemy.position + predictionTime * enemy.speed - friendly.position;
