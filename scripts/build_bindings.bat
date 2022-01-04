@echo off
setlocal

call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64

set binddir=src\bindings
set flags=/nologo

if not exist %binddir%\build mkdir %binddir%\build
pushd %binddir%\build
    cl %flags% ..\bindings.c
popd
if ERRORLEVEL 1 goto Failed

%binddir%\build\bindings.exe
if ERRORLEVEL 1 goto Failed

goto Success
:Failed
echo An error occurred during the script.
set EXITCODE=1
:Success
exit /B %EXITCODE%
