[CmdletBinding()]
param([switch]$Remove)
$ErrorActionPreference = 'Stop'
$name = 'DigitalPilgrimage-LocalCD'
if ($Remove) {
    Unregister-ScheduledTask -TaskName $name -Confirm:$false
    Write-Output 'Removed local CD task. Running containers are unchanged.'
    exit 0
}
$script = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'deploy-local.ps1')).Path
# Docker Desktop is available in the logged-in user's session.
$user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 10)
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 15) -StartWhenAvailable
Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
Write-Output 'Local CD checks every 10 minutes while this user is logged in. Docker Desktop must be running.'
