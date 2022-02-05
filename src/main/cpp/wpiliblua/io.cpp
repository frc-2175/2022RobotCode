// Automatically generated by bindings.c. DO NOT EDIT.

#include <frc/Joystick.h>

#include "luadef.h"

// Construct an instance of a joystick.
LUAFUNC void* Joystick_new(int port) {
    return new frc::Joystick(port);
}

LUAFUNC double Joystick_GetX(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetX();
    return (double)_result;
}

LUAFUNC double Joystick_GetY(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetY();
    return (double)_result;
}

LUAFUNC double Joystick_GetZ(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetZ();
    return (double)_result;
}

LUAFUNC double Joystick_GetThrottle(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetThrottle();
    return (double)_result;
}

LUAFUNC bool Joystick_GetTriggerHeld(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetTrigger();
    return (bool)_result;
}

LUAFUNC bool Joystick_GetTriggerPressed(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetTriggerPressed();
    return (bool)_result;
}

LUAFUNC bool Joystick_GetTriggerReleased(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetTriggerReleased();
    return (bool)_result;
}

LUAFUNC bool Joystick_GetTopHeld(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetTop();
    return (bool)_result;
}

LUAFUNC bool Joystick_GetTopPressed(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetTopPressed();
    return (bool)_result;
}

LUAFUNC bool Joystick_GetTopReleased(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetTopReleased();
    return (bool)_result;
}

LUAFUNC bool Joystick_GetButtonHeld(void* _this, int button) {
    auto _result = ((frc::Joystick*)_this)
        ->GetRawButton(button);
    return (bool)_result;
}

LUAFUNC bool Joystick_GetButtonPressed(void* _this, int button) {
    auto _result = ((frc::Joystick*)_this)
        ->GetRawButtonPressed(button);
    return (bool)_result;
}

LUAFUNC bool Joystick_GetButtonReleased(void* _this, int button) {
    auto _result = ((frc::Joystick*)_this)
        ->GetRawButtonReleased(button);
    return (bool)_result;
}

LUAFUNC double Joystick_GetRawAxis(void* _this, int axis) {
    auto _result = ((frc::Joystick*)_this)
        ->GetRawAxis(axis);
    return (double)_result;
}

LUAFUNC int Joystick_GetPOV(void* _this) {
    auto _result = ((frc::Joystick*)_this)
        ->GetPOV();
    return (int)_result;
}
