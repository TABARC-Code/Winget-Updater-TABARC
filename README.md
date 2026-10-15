# TABARC WinGet Updater

Ok so Windows has a remarkable talent for keeping dozens of applications installed and then expecting you to remember which ones need updating. I have clients i get fed up of updatng shit tey can do, and they then moan when i charge them for work thye coulld do.

This is a small PowerShell project to take some of that housekeeping off your hands.

It uses **WinGet**, Microsoft's Windows Package Manager, to upgrade the applications WinGet recognises. The scheduled task runs at **03:00 on the first Saturday of each month**. There are logs, an installer and an uninstaller. 

Note no extra update agent quietly chewing through memory in the background.

## What's in the repository?

| File | Purpose |
| --- | --- |
| `Update-Apps.ps1` | Runs WinGet upgrades and writes a dated log. |
| `Install-Schedule.ps1` | Creates or replaces the monthly scheduled task. |
| `Uninstall-Schedule.ps1` | Removes the scheduled task. |
| `DESCRIPTION.md` | Project summary and limitations. |

## Before you start

You need Windows 10 or 11, WinGet (normally supplied through **App Installer**), an internet connection and an account with administrator rights for setup. The scripts target **Windows PowerShell 5.1**.

Check that WinGet actually works. Open PowerShell and type:

```powershell
winget --version
```

If Windows says the command cannot be found, install or repair **App Installer** first. Don't skip this and hope the scheduled task will magically sort it out. It won't.

## Installation: the beginner's version

1. On GitHub, select **Code → Download ZIP** and extract the folder.
2. Move the extracted project to somewhere permanent, such as `C:\Tools\TABARC-WinGet-Updater`. The scheduled task points at that location, so moving the folder later will break it.
3. Right-click **Windows PowerShell** and choose **Run as administrator**.
4. Enter these commands, adjusting the folder path if you chose another location:

```powershell
cd 'C:\Tools\TABARC-WinGet-Updater'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-Schedule.ps1
```

That's the schedule installed. By default, **your Windows account must be signed in** when the task runs. Locking the screen is fine; signing out is not. If the computer is asleep or switched off at 03:00, Task Scheduler is configured to start the missed task when the machine next becomes available, subject to Windows' normal scheduling behaviour.

### Want it to run when nobody is signed in?

Open **Task Scheduler**, find **TABARC Monthly WinGet Update**, open **Properties → General**, select **Run whether user is logged on or not**, and save. Windows may ask for your account password. This uses your own account rather than SYSTEM, because WinGet package discovery and installation are often tied to a user profile. Check the resulting task in your environment; passwordless or Microsoft-account setups can require extra configuration.

### Test it now

Run this in PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Update-Apps.ps1
```

That runs the updater immediately. It may take some time, and applications that are currently open can interfere with installation. Save your work first.

You can also right-click the task in **Task Scheduler** and choose **Run**. That is the better test of the scheduled account and its permissions.

## The update command

The updater uses these WinGet arguments:

```powershell
winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
```

`--include-unknown` permits upgrade attempts even when WinGet cannot establish the installed version. That's deliberate, but it also makes package matching and installer behaviour worth checking. `--silent` and agreement switches reduce prompts; they **cannot guarantee** that every vendor installer will behave silently.

The updater does **not** force a Windows restart. Individual installers may still request or initiate one, depending on their own behaviour.

## Logs and troubleshooting

Look in:

```text
C:\ProgramData\TABARC-WinGet-Updater\Logs
```

Each run creates a timestamped log. A successful process exit is not proof that every application on the computer was updated: some packages may be skipped, require a different installer, or simply not exist in the WinGet catalogues.

If nothing updates, run `winget upgrade` interactively first and check the task's **Last Run Result** in Task Scheduler. If the task reports that WinGet cannot be found, verify that the scheduled user can run `winget --version` and that App Installer is available to that user.

This script does **not** run Windows Update, update drivers or firmware, or cover all portable and proprietary applications. It also doesn't update software managed only by Chocolatey or Scoop.

## Removing it

Open PowerShell as administrator in the project folder and run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Uninstall-Schedule.ps1
```

The task is removed. You can then delete the repository folder. Existing logs remain in `ProgramData` until you delete them yourself.

## Safety and maintenance

A monthly, silent, unattended upgrade is a convenience rather than a guarantee. Some software is sensitive to version changes, and there is no automatic rollback here. Back up important work and review the logs occasionally. For production machines, test updates before deploying them broadly.

The installer uses `-ExecutionPolicy Bypass` **for that PowerShell process only**; it does not permanently change the machine's execution policy. Read scripts before running them, particularly if you've downloaded them from somewhere other than the project repository.

## Licence

MIT

**TABARC-Code** — a small tool for a tedious job.
