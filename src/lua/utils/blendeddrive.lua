require("utils.math")
--public void blendedDrive(double xSpeed, double zRotation, boolean speedSmoothing)

function blendedDrive(xSpeed, zRotation, speedSmoothing, currentSpeed)
    if speedSmoothing then
        MAX_SPEED_TIME = 0.5 --change this to change reaction time!
        MAX_CHANGE_PER_TICK = 1.0 / (MAX_SPEED_TIME * 50.0)
        change = xSpeed - currentSpeed --where do we get current speed??? follow up ! --TODO
        --if we're slowing down or speeding up?
        if (( currentSpeed > 0 and change < 0 ) or ( currentSpeed < 0 and change > 0)) then
            --limiting change
            if (change > MAX_CHANGE_PER_TICK) then
                change = MAX_CHANGE_PER_TICK
            elseif (change < -MAX_CHANGE_PER_TICK) then
                change = -MAX_CHANGE_PER_TICK
            end
        end
        currentSpeed += change;
    else 
        currentSpeed = desiredSpeed
    end
end


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
    lerpT = math.abs(Deadband(moveValue, .01)) / inputThreshold
    lerpT = clamp(lerpT, 0, 1)
    leftBlend = lerp(leftArcadeValue, leftCurvatureValue, lerpT)
    rightBlend = lerp(rightArcadeValue, rightCurvatureValue, lerpT)

    return leftBlend, rightBlend
end