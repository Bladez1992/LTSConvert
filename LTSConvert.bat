@echo off
cd /d "%~dp0"
powershell.exe -noexit -ExecutionPolicy Bypass -WindowStyle hidden -file .\LTSConvert.ps1
exit
