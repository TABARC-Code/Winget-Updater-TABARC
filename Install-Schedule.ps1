# TABARC-Code | Install first-Saturday 03:00 task
# Run in Windows PowerShell as Administrator.
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
$taskName = 'TABARC Monthly WinGet Update'
$updater = Join-Path $PSScriptRoot 'Update-Apps.ps1'
if (-not (Test-Path -LiteralPath $updater)) { throw "Cannot find $updater" }

# Run as the installing user, with stored credentials via Task Scheduler.
# WinGet's per-user registrations are not reliably accessible under SYSTEM.
$user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
Write-Host "Task account: $user"
Write-Host 'The task will run with your account at the highest available privilege.'
Write-Host 'Windows may request your password to allow execution while signed out.'

$service = New-Object -ComObject Schedule.Service
$service.Connect()
$root = $service.GetFolder('\')
$task = $service.NewTask(0)
$task.RegistrationInfo.Description = 'WinGet application updates at 03:00 on the first Saturday of each month.'
$task.Settings.Enabled = $true
$task.Settings.StartWhenAvailable = $true
$task.Settings.ExecutionTimeLimit = 'PT4H'
$task.Settings.MultipleInstances = 2
$task.Settings.DisallowStartIfOnBatteries = $false
$task.Settings.StopIfGoingOnBatteries = $false
$task.Principal.UserId = $user
$task.Principal.LogonType = 2 # S4U: no stored password, but no network credentials; unsuitable for WinGet downloads.

# Change to interactive token: reliable WinGet access, but requires sign-in.
$task.Principal.LogonType = 3
$task.Principal.RunLevel = 1
$trigger = $task.Triggers.Create(5) # monthly day-of-week
$trigger.StartBoundary = (Get-Date).ToString('yyyy-MM-ddT03:00:00')
$trigger.DaysOfWeek = 64             # Saturday
$trigger.WeeksOfMonth = 1            # first Saturday
$trigger.MonthsOfYear = 4095         # every month
$trigger.Enabled = $true
$action = $task.Actions.Create(0)
$action.Path = Join-Path $PSHOME 'powershell.exe'
$action.Arguments = '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' + $updater + '"'
$root.RegisterTaskDefinition($taskName, $task, 6, $user, $null, 3) | Out-Null
Write-Host "Installed: $taskName" -ForegroundColor Green
Write-Host 'Runs on the first Saturday each month at 03:00, when this user is signed in.'
Write-Host 'For unattended signed-out execution, configure a password-backed user task in Task Scheduler.'
