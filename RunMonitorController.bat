@echo off
REM Wrapper for Task Scheduler - %~dp0 resolves to this .bat file's own folder,
REM so the whole package stays portable regardless of where it's installed.
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0SudoVDA-MonitorController.ps1"
