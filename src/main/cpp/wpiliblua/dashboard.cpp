// Automatically generated by bindings.c. DO NOT EDIT.

#include <string_view>
#include <wpi/span.h>
#include <frc/smartdashboard/SmartDashboard.h>
#include <frc/smartdashboard/SendableChooser.h>

#include "luadef.h"

LUAFUNC void PutNumber(const char * keyName, double value) {
    frc::SmartDashboard::PutNumber((std::string_view)keyName, value);
}

LUAFUNC void PutNumberArray(const char * keyName, double * value, size_t size) {
	frc::SmartDashboard::PutNumberArray((std::string_view)keyName, wpi::span(value, size));
}

LUAFUNC void PutString(const char * keyName, const char* value) {
    frc::SmartDashboard::PutString((std::string_view)keyName, (std::string_view)value);
}

LUAFUNC void PutStringArray(const char * keyName, const char ** value, size_t size) {
	frc::SmartDashboard::PutStringArray((std::string_view)keyName, wpi::span(std::vector<std::string>(value, value + size)));
}

LUAFUNC void PutBoolean(const char * keyName, bool value) {
    frc::SmartDashboard::PutBoolean((std::string_view)keyName, value);
}

LUAFUNC void PutBooleanArray(const char * keyName, int * value, size_t size) {
	frc::SmartDashboard::PutBooleanArray((std::string_view)keyName, wpi::span(value, size));
}

LUAFUNC void PutIntChooser(void * data) {
    frc::SmartDashboard::PutData((frc::SendableChooser<int>*)data);
}

LUAFUNC void* SendableChooser_new() {
    return new frc::SendableChooser<int>();
}

LUAFUNC void SendableChooser_AddOption(void* _this, const char * name, int object) {
    ((frc::SendableChooser<int>*)_this)
        ->AddOption((std::string_view)name, object);
}

LUAFUNC int SendableChooser_GetSelected(void* _this) {
    auto _result = ((frc::SendableChooser<int>*)_this)
        ->GetSelected();
    return (int)_result;
}
