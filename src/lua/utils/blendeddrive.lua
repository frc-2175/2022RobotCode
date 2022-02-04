require("utils.math")

-- public static double[] getBlendedMotorValues(double moveValue, double turnValue, double inputThreshold) {
--     virtualRobotDrive.arcadeDrive(moveValue, turnValue, false);
--     double leftArcadeValue = leftVirtualSpeedController.get() * 0.8;
--     double rightArcadeValue = rightVirtualSpeedController.get()* 0.8;

--     virtualRobotDrive.curvatureDrive(moveValue, turnValue, false);
--     double leftCurvatureValue = leftVirtualSpeedController.get();
--     double rightCurvatureValue = rightVirtualSpeedController.get();

--     double lerpT = Math.abs(MathUtility.deadband(moveValue, RobotDriveBase.kDefaultDeadband)) / inputThreshold;
--     lerpT = MathUtility.clamp(lerpT, 0, 1);
--     double leftBlend = MathUtility.lerp(leftArcadeValue, leftCurvatureValue, lerpT);
--     double rightBlend = MathUtility.lerp(rightArcadeValue, rightCurvatureValue, lerpT);

--     double[] blends = { leftBlend, rightBlend };
--     return blends;
-- }
function getBlendedMotorValues(moveValue, turnValue, inputThreshold)
    lerpT = math.abs(deadband(moveValue, .01)) / inputThreshold;
    lerpT = clamp(lerpT, 0, 1)
    leftBlend = lerp(leftArcadeValue, leftCurvatureValue, lerpT)
    rightBlend = lerp(rightArcadeValue, rightCurvatureValue, lerpT)

    return leftBlend, rightBlend
end