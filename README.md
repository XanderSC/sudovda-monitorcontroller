# SudoVDA Monitor Controller

Automatically disconnects your physical monitors when you start a [Steam Remote Play](https://store.steampowered.com/remoteplay) / Steam Link stream to a [SudoVDA](https://github.com/SudoMaker/SudoVDA) virtual display (e.g. streaming to a Steam Deck), and restores them — in their original positions, orientations, and primary-display setting — the moment the stream ends.

No more monitors staying lit (and risking OLED burn-in) while you're playing on the couch in another room, and no more manually juggling display settings before and after every session.

## How it works

1. Watches the system's active monitor count for the delta caused by SudoVDA's virtual display appearing/disappearing — this happens regardless of which game or app is being streamed.
2. When a stream starts: saves your current monitor layout, sets the SudoVDA display as primary, and disables all physical monitors.
3. When the stream ends: restores the saved layout exactly as it was — no window repositioning, no lost orientation settings.
4. Runs as a Windows scheduled task at login, fully in the background.

The script is fully dynamic — it doesn't hardcode your monitor names, count, or display numbers, and it auto-detects the SudoVDA display by its driver name rather than its (session-incrementing) display number. It should work out of the box on any setup running SudoVDA, with any number of physical monitors, streaming any game.

## Requirements

- Windows 10/11
- [SudoVDA](https://github.com/SudoMaker/SudoVDA) installed and working
- Steam, with **Settings → Remote Play → Advanced Host Options → Primary display while streaming** set to the SudoVDA display
- [MultiMonitorTool](https://www.nirsoft.net/utils/multi_monitor_tool.html) by NirSoft (see setup below — **not bundled in this repo**, see Licensing note)
- PowerShell execution policy allowing local scripts to run (`RemoteSigned` is sufficient)

## Setup

1. Clone or download this repo to a folder of your choice, e.g. `C:\Tools\SudoVDA-MonitorController\`.
2. Download `MultiMonitorTool.exe` from [nirsoft.net](https://www.nirsoft.net/utils/multi_monitor_tool.html) and place it directly in that same folder.
3. Open PowerShell **as Administrator** and run:
   ```powershell
   & "C:\Tools\SudoVDA-MonitorController\CreateScheduledTask.ps1"
   ```
4. Done. The task now runs automatically at every login. The first time it runs it will:
   - Record a SHA256 hash of `MultiMonitorTool.exe` (so future runs can detect if it's been tampered with or swapped)
   - Save your current monitor layout as the baseline to restore to

That's it — no need to edit any paths, display names, or monitor counts in the script itself.

## Testing

Run the launcher manually first to confirm everything works before relying on the scheduled task:

```powershell
& "C:\Tools\SudoVDA-MonitorController\RunMonitorController.bat" 2>&1
```

Start a stream from your client device and confirm your physical monitors disconnect. End the stream and confirm they're restored. Check progress at any time via the log:

```powershell
Get-Content "C:\Tools\SudoVDA-MonitorController\SudoVDA-MonitorController.log" -Tail 20
```

## Applying changes after editing the script

PowerShell scripts are interpreted, not compiled, so the scheduled task simply re-reads `SudoVDA-MonitorController.ps1` fresh each time it starts. After making edits, just restart the running instance — no rebuild or re-registration needed:

```powershell
Stop-ScheduledTask -TaskName "SudoVDA Monitor Controller"
Start-Sleep -Seconds 2
Start-ScheduledTask -TaskName "SudoVDA Monitor Controller"
```

Then check the log to confirm it started cleanly with no syntax errors from the edit:

```powershell
Get-Content "C:\Tools\SudoVDA-MonitorController\SudoVDA-MonitorController.log" -Tail 15
```

A couple of things **not** to do here:
- **Don't re-run `CreateScheduledTask.ps1`** for code changes — it only registers the task definition (trigger, target path, privilege level), which hasn't changed. It's only needed again if you move the folder to a new location or want to recreate the task from scratch.
- **Don't run `RunMonitorController.bat` manually** while the scheduled task is also running — you'll end up with two instances fighting over the same monitors. Only run it directly if the scheduled task isn't currently active.

## Stopping the controller

```powershell
# Stop the currently running instance
Stop-ScheduledTask -TaskName "SudoVDA Monitor Controller"

# Pause it so it won't auto-start at the next login either
Disable-ScheduledTask -TaskName "SudoVDA Monitor Controller"

# Re-enable it later
Enable-ScheduledTask -TaskName "SudoVDA Monitor Controller"
```

`Stop-ScheduledTask` is a hard stop, so the script's cleanup (`finally` block) may not get a chance to run. If your monitors are left disconnected afterward, restore them manually:

```powershell
& "C:\Tools\SudoVDA-MonitorController\MultiMonitorTool.exe" /LoadConfig "C:\Tools\SudoVDA-MonitorController\MonitorConfig-Normal.cfg"
```

Check current state at any time with:

```powershell
Get-ScheduledTask -TaskName "SudoVDA Monitor Controller" | Select-Object TaskName, State
```

## Maintenance

- **Changed your physical monitor setup permanently** (added/removed a monitor, repositioned them)? Just re-save the baseline config:
  ```powershell
  & "C:\Tools\SudoVDA-MonitorController\MultiMonitorTool.exe" /SaveConfig "C:\Tools\SudoVDA-MonitorController\MonitorConfig-Normal.cfg"
  ```
- **Updated MultiMonitorTool.exe**? Delete the hash file so it's regenerated on the next run:
  ```powershell
  Remove-Item "C:\Tools\SudoVDA-MonitorController\MultiMonitorTool.sha256" -Force
  ```
- **Want to remove the scheduled task entirely?**
  ```powershell
  Unregister-ScheduledTask -TaskName "SudoVDA Monitor Controller" -Confirm:$false
  ```

## Files

| File | Purpose |
|---|---|
| `SudoVDA-MonitorController.ps1` | Main script — all detection and control logic |
| `RunMonitorController.bat` | Launcher used by the scheduled task |
| `CreateScheduledTask.ps1` | One-time setup script to register the scheduled task |
| `MonitorConfig-Normal.cfg` | Auto-generated on first run — your saved monitor layout |
| `MultiMonitorTool.sha256` | Auto-generated on first run — integrity hash for the bundled tool |
| `SudoVDA-MonitorController.log` | Runtime log, useful for troubleshooting |

## Licensing note on MultiMonitorTool

MultiMonitorTool is free NirSoft software, but its license does not permit redistribution on third-party sites. For that reason it is **not included in this repository** — you'll need to download it directly from NirSoft (link above) and drop it into the project folder yourself. The script's built-in SHA256 check will record and verify its hash on first run.

## License

MIT — see [LICENSE](LICENSE).
