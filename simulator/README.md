# 2175 Full Real Actual Simulator

Simulating robots!!

## Editing or creating new fields

Make a new scene and build something new using stuff from `fields/parts`. Test robots can be dropped in from the `robots` folder and immediately driven around using WASD or the arrow keys.

You can use the `FollowingCamera.gd` script on a Godot camera to make it automatically follow your robot of choice.

## Editing or creating new robots

Creating robots is somewhat more difficult because it needs to play nice with Godot's physics system. We have several systems to help you create robots with plausible physical properties, and that automatically connect to the WPILib simulator if available. All the tools are in `robots/parts`.

Whenever possible, use `RobotBox` and `RobotCylinder` for basic shapes on your robot. They allow you to specify real-world dimensions and materials, and will automatically calculate the correct mass and center of mass based on this. As a rule of thumb, use as few rigid bodies as you can. Rigid bodies still need to be manually attached to each other using Godot's physics joints.

Use `Wheel` for either drive wheels or intake wheels.

To build an intake mechanism, use `IntakeArea` and `IntakeLauncher`. Any game pieces that touch an `IntakeArea` will be "captured" by the robot. Any captured game pieces can then be launched or placed using an `IntakeLauncher`. The `IntakeLauncher` will shoot game pieces along its own X axis with a configurable velocity - including zero, which allows game pieces to be placed instead of shot.
