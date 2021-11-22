// Automatically generated by bindings.c. DO NOT EDIT.

#include <frc/Solenoid.h>
#include <frc/DoubleSolenoid.h>
#include "frc/PneumaticsModuleType.h"

#include "luadef.h"

LUAFUNC void* Solenoid_new(int moduleType, int channel) {
    return new frc::Solenoid((frc::PneumaticsModuleType)moduleType, channel);
}

LUAFUNC void Solenoid_Set(void* _this, bool on) {
    ((frc::Solenoid*)_this)
        ->Set(on);
}

LUAFUNC bool Solenoid_Get(void* _this) {
    auto _result = ((frc::Solenoid*)_this)
        ->Get();
    return _result;
}

LUAFUNC void* DoubleSolenoid_new(int moduleType, int forwardChannel, int reverseChannel) {
    return new frc::DoubleSolenoid((frc::PneumaticsModuleType)moduleType, forwardChannel, reverseChannel);
}

LUAFUNC void* DoubleSolenoid_newWithModule(int moduleNumber, int moduleType, int forwardChannel, int reverseChannel) {
    return new frc::DoubleSolenoid(moduleNumber, (frc::PneumaticsModuleType)moduleType, forwardChannel, reverseChannel);
}

LUAFUNC void DoubleSolenoid_Set(void* _this, int value) {
    ((frc::DoubleSolenoid*)_this)
        ->Set((frc::DoubleSolenoid::Value)value);
}

LUAFUNC int DoubleSolenoid_Get(void* _this) {
    auto _result = ((frc::DoubleSolenoid*)_this)
        ->Get();
    return _result;
}
