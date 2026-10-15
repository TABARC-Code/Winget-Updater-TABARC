# TABARC-Code | Remove scheduled task (does not delete logs)
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
Unregister-ScheduledTask -TaskName 'TABARC Monthly WinGet Update' -Confirm:$false
Write-Host 'Monthly WinGet update task removed.'
