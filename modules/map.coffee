

module.exports =


  getNearestEnemy : (friendlyTank, enemyTanks) ->
    # Place holder
    enemyTanks[0]

  # http://gamedev.stackexchange.com/questions/1885/target-tracking-when-to-accelerate-and-decelerate-a-rotating-turret
  enemyRads : (target, turret) ->
    turretToTarget =
      x: target.position[0] - turret.position[0]
      y: target.position[1] - turret.position[1]
    desiredAngle = Math.atan2(turretToTarget.y, turretToTarget.x)
    angleDiff = desiredAngle - turret.turret # angle

    # Normalize angle to [-PI,PI] range. This ensures that the turret
    # turns the shortest way.
    while (angleDiff < -Math.PI)
      angleDiff += 2*Math.PI
    while (angleDiff >= Math.PI)
      angleDiff -= 2*Math.PI
    C0 = 0.5 # Must be determined by trial error
    C1 = 2*Math.sqrt(C0)
    angularAcc = C0 * angleDiff - C1 * 1.5;

    predictionTime = 1 # One second prediction, you need to experiment.
    turretToTarget = target.position + predictionTime * target.speed - turret.position;
