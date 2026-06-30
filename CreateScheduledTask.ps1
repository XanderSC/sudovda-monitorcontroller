# Run this script once, in an elevated (Administrator) PowerShell window, to
# register the SudoVDA Monitor Controller as a scheduled task that starts
# automatically at login.
#
# Re-running it is safe - it will simply overwrite the existing task definition.

$scriptPath = "$PSScriptRoot\SudoVDA-MonitorController.ps1"
$batPath = "$PSScriptRoot\RunMonitorController.bat"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: SudoVDA-MonitorController.ps1 not found next to this script." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $batPath)) {
    Write-Host "ERROR: RunMonitorController.bat not found next to this script." -ForegroundColor Red
    exit 1
}

$action = New-ScheduledTaskAction -Execute $batPath
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0 -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName "SudoVDA Monitor Controller" `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -RunLevel Highest `
    -Force | Out-Null

Write-Host "Scheduled task 'SudoVDA Monitor Controller' created successfully." -ForegroundColor Green
Write-Host "  Script: $scriptPath"
Write-Host "  Launcher: $batPath"
Write-Host ""
Write-Host "The task will run automatically at every login from now on."
Write-Host "Starting it now for an immediate test..."

Start-ScheduledTask -TaskName "SudoVDA Monitor Controller"
Start-Sleep -Seconds 3
Get-ScheduledTask -TaskName "SudoVDA Monitor Controller" | Select-Object TaskName, State
