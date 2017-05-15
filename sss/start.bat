@echo off

SET ThisDirectory=%~dp0

SET PSScriptsPath=%ThisDirectory%NormalMode.ps1

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT

REM if %OS%==32BIT %~dp0\psexec.exe -i -s powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -Command "& '%PSScriptsPath%'"

if %OS%==32BIT %~dp0\psexec.exe -i -s powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File %PSScriptsPath% %~dp0

REM if %OS%==64BIT %~dp0\psexec64.exe -i -s powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -Command "& '%PSScriptsPath%'"

if %OS%==64BIT %~dp0\psexec.exe -i -s powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File %PSScriptsPath% %~dp0

set /p UIPath=What?