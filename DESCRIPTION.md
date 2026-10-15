# TABARC WinGet Updater — project description

A lightweight Windows PowerShell utility for monthly application maintenance. It runs WinGet upgrades with silent-install and agreement-acceptance flags, including packages whose installed version is unknown, and records the result in timestamped logs.

The default schedule is **03:00 on the first Saturday of every month**. Installation and removal are handled by separate scripts, so users don't have to build a scheduled task by hand.

It's intentionally modest. This isn't a magic unicorn universal Windows patching system, a driver updater or a magical cure for badly behaved installers. WinGet only updates applications it can identify and manage, and some publishers insist on their own prompts or update tools. The default scheduled task runs in the installing user's session; a signed-out configuration needs a deliberate change in Task Scheduler.

## Suggested GitHub repository description

> Monthly WinGet application updates for Windows, with PowerShell scheduling, silent upgrades and readable logs.

## Suggested topics

`powershell` · `winget` · `windows` · `automation` · `task-scheduler` · `software-updates` · `tabarc-code`
