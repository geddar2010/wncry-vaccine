@echo off

SET ThisDirectory=%~dp0

SET PSScriptsPath=%ThisDirectory%SafeMode.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -Command "& '%PSScriptsPath%'"