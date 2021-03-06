// Automatically generated by bindings.c. DO NOT EDIT.

#include <frc/SPI.h>
#include "AHRS.h"

#include "luadef.h"

LUAFUNC void* AHRS_new(int value) {
    return new AHRS((frc::SPI::Port)value);
}

LUAFUNC float AHRS_GetPitch(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetPitch();
    return (float)_result;
}

LUAFUNC float AHRS_GetRoll(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetRoll();
    return (float)_result;
}

LUAFUNC float AHRS_GetYaw(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetYaw();
    return (float)_result;
}

LUAFUNC float AHRS_GetCompassHeading(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetCompassHeading();
    return (float)_result;
}

LUAFUNC void AHRS_ZeroYaw(void* _this) {
    ((AHRS*)_this)
        ->ZeroYaw();
}

LUAFUNC bool AHRS_IsCalibrating(void* _this) {
    auto _result = ((AHRS*)_this)
        ->IsCalibrating();
    return (bool)_result;
}

LUAFUNC bool AHRS_IsConnected(void* _this) {
    auto _result = ((AHRS*)_this)
        ->IsConnected();
    return (bool)_result;
}

LUAFUNC double AHRS_GetByteCount(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetByteCount();
    return (double)_result;
}

LUAFUNC double AHRS_GetUpdateCount(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetUpdateCount();
    return (double)_result;
}

LUAFUNC float AHRS_GetWorldLinearAccelX(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetWorldLinearAccelX();
    return (float)_result;
}

LUAFUNC float AHRS_GetWorldLinearAccelY(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetWorldLinearAccelY();
    return (float)_result;
}

LUAFUNC float AHRS_GetWorldLinearAccelZ(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetWorldLinearAccelZ();
    return (float)_result;
}

LUAFUNC bool AHRS_IsMoving(void* _this) {
    auto _result = ((AHRS*)_this)
        ->IsMoving();
    return (bool)_result;
}

LUAFUNC bool AHRS_IsRotating(void* _this) {
    auto _result = ((AHRS*)_this)
        ->IsRotating();
    return (bool)_result;
}

LUAFUNC float AHRS_GetBarometricPressure(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetBarometricPressure();
    return (float)_result;
}

LUAFUNC float AHRS_GetAltitude(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetAltitude();
    return (float)_result;
}

LUAFUNC bool AHRS_IsAltitudeValid(void* _this) {
    auto _result = ((AHRS*)_this)
        ->IsAltitudeValid();
    return (bool)_result;
}

LUAFUNC bool AHRS_GetFusedHeading(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetFusedHeading();
    return (bool)_result;
}

LUAFUNC bool AHRS_IsMagneticDisturbance(void* _this) {
    auto _result = ((AHRS*)_this)
        ->IsMagneticDisturbance();
    return (bool)_result;
}

LUAFUNC bool AHRS_IsMagnetometerCalibrated(void* _this) {
    auto _result = ((AHRS*)_this)
        ->IsMagnetometerCalibrated();
    return (bool)_result;
}

LUAFUNC float AHRS_GetQuaternionW(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetQuaternionW();
    return (float)_result;
}

LUAFUNC float AHRS_GetQuaternionX(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetQuaternionX();
    return (float)_result;
}

LUAFUNC float AHRS_GetQuaternionY(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetQuaternionY();
    return (float)_result;
}

LUAFUNC float AHRS_GetQuaternionZ(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetQuaternionZ();
    return (float)_result;
}

LUAFUNC void AHRS_ResetDisplacement(void* _this) {
    ((AHRS*)_this)
        ->ResetDisplacement();
}

LUAFUNC void AHRS_UpdateDisplacement(void* _this, float accel_x_g, float accel_y_g, int update_rate_hz, bool is_moving) {
    ((AHRS*)_this)
        ->UpdateDisplacement(accel_x_g, accel_y_g, update_rate_hz, is_moving);
}

LUAFUNC float AHRS_GetVelocityX(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetVelocityX();
    return (float)_result;
}

LUAFUNC float AHRS_GetVelocityY(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetVelocityY();
    return (float)_result;
}

LUAFUNC float AHRS_GetVelocityZ(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetVelocityZ();
    return (float)_result;
}

LUAFUNC float AHRS_GetDisplacementX(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetDisplacementX();
    return (float)_result;
}

LUAFUNC float AHRS_GetDisplacementY(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetDisplacementY();
    return (float)_result;
}

LUAFUNC float AHRS_GetDisplacementZ(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetDisplacementZ();
    return (float)_result;
}

LUAFUNC double AHRS_GetAngle(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetAngle();
    return (double)_result;
}

LUAFUNC double AHRS_GetRate(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetRate();
    return (double)_result;
}

LUAFUNC void AHRS_SetAngleAdjustment(void* _this, double angle) {
    ((AHRS*)_this)
        ->SetAngleAdjustment(angle);
}

LUAFUNC double AHRS_GetAngleAdjustment(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetAngleAdjustment();
    return (double)_result;
}

LUAFUNC void AHRS_Reset(void* _this) {
    ((AHRS*)_this)
        ->Reset();
}

LUAFUNC float AHRS_GetRawGyroX(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetRawGyroX();
    return (float)_result;
}

LUAFUNC float AHRS_GetRawGyroY(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetRawGyroY();
    return (float)_result;
}

LUAFUNC float AHRS_GetRawAccelX(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetRawAccelX();
    return (float)_result;
}

LUAFUNC float AHRS_GetRawAccelY(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetRawAccelY();
    return (float)_result;
}

LUAFUNC float AHRS_GetRawAccelZ(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetRawAccelZ();
    return (float)_result;
}

LUAFUNC float AHRS_GetRawMagX(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetRawMagX();
    return (float)_result;
}

LUAFUNC float AHRS_GetRawMagY(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetRawMagY();
    return (float)_result;
}

LUAFUNC float AHRS_GetRawMagZ(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetRawMagZ();
    return (float)_result;
}

LUAFUNC float AHRS_GetPressure(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetPressure();
    return (float)_result;
}

LUAFUNC float AHRS_GetTempC(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetTempC();
    return (float)_result;
}

LUAFUNC int AHRS_GetActualUpdateRate(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetActualUpdateRate();
    return (int)_result;
}

LUAFUNC void AHRS_EnableLogging(void* _this, bool enable) {
    ((AHRS*)_this)
        ->EnableLogging(enable);
}

LUAFUNC void AHRS_EnableBoardlevelYawReset(void* _this, bool enable) {
    ((AHRS*)_this)
        ->EnableBoardlevelYawReset(enable);
}

LUAFUNC bool AHRS_IsBoardlevelYawResetEnabled(void* _this) {
    auto _result = ((AHRS*)_this)
        ->IsBoardlevelYawResetEnabled();
    return (bool)_result;
}

LUAFUNC int AHRS_GetGyroFullScaleRangeDPS(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetGyroFullScaleRangeDPS();
    return (int)_result;
}

LUAFUNC int AHRS_GetAccelFullScaleRangeG(void* _this) {
    auto _result = ((AHRS*)_this)
        ->GetAccelFullScaleRangeG();
    return (int)_result;
}

LUAFUNC void AHRS_Calibrate(void* _this) {
    ((AHRS*)_this)
        ->Calibrate();
}
