# TABARC-Code | WinGet application updater
# Runs without confirmation prompts where the package installer permits it.
# This updates WinGet-managed applications, not Windows itself.

$ErrorActionPreference = 'Stop'
$logDir = Join-Path $env:ProgramData 'TABARC-WinGet-Updater\Logs'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$logFile = Join-Path $logDir ('Update-{0}.log' -f (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'))

function Write-Log([string]$message) {
    $line = '{0} | {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $message
    Write-Host $line
    Add-Content -LiteralPath $logFile -Value $line -Encoding UTF8
}

Write-Log ('Started as {0}' -f [Security.Principal.WindowsIdentity]::GetCurrent().Name)

# WinGet is an App Installer alias; its availability depends on the task account.
$command = Get-Command 'winget.exe' -ErrorAction SilentlyContinue
if (-not $command) {
    Write-Log 'ERROR: winget.exe is unavailable in this account. Check App Installer and the scheduled task identity.'
    exit 1
}

$arguments = @(
    'upgrade', '--all', '--include-unknown', '--silent',
    '--accept-package-agreements', '--accept-source-agreements',
    '--disable-interactivity'
)
Write-Log ('Executable: {0}' -f $command.Source)
Write-Log ('Arguments: {0}' -f ($arguments -join ' '))

try {
    # Use a native process with redirected output so Task Scheduler receives the exit code.
    $outputFile = Join-Path $env:TEMP ('tabarc-winget-{0}.out' -f [guid]::NewGuid().ToString('N'))
    $errorFile = Join-Path $env:TEMP ('tabarc-winget-{0}.err' -f [guid]::NewGuid().ToString('N'))
    try {
        $process = Start-Process -FilePath $command.Source -ArgumentList $arguments `
            -Wait -PassThru -NoNewWindow -RedirectStandardOutput $outputFile -RedirectStandardError $errorFile
        foreach ($file in @($outputFile, $errorFile)) {
            if (Test-Path -LiteralPath $file) {
                Get-Content -LiteralPath $file | ForEach-Object { Write-Log $_ }
            }
        }
        Write-Log ('WinGet exit code: {0}' -f $process.ExitCode)
        exit $process.ExitCode
    }
    finally {
        Remove-Item -LiteralPath $outputFile, $errorFile -Force -ErrorAction SilentlyContinue
    }
}
catch {
    Write-Log ('ERROR: {0}' -f $_.Exception.Message)
    exit 1
}
