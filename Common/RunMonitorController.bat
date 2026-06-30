@echo off
REM Lives in the "Common" folder; the actual script lives one level up in "Controller".
REM %~dp0 resolves to this .bat file's own folder, so the whole package stays
REM portable regardless of where it's installed.
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0..\Controller\SudoVDA-MonitorController.ps1"
