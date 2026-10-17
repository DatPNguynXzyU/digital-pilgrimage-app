[CmdletBinding()]
param(
    [string]$Repository = 'DatPNguynXzyU/digital-pilgrimage-app',
    [string]$EnvFile = (Join-Path $PSScriptRoot '../backend/.env'),
    [string]$StateDirectory = (Join-Path $PSScriptRoot '../.local-cd'),
    [switch]$CheckOnly
)
$ErrorActionPreference = 'Stop'
if ($Repository -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { throw 'Invalid repository.' }
$headers = @{ Accept = 'application/vnd.github+json'; 'User-Agent' = 'digital-pilgrimage-local-cd' }
$api = "https://api.github.com/repos/$Repository"
# Only the current main commit with a successful image-publishing workflow is eligible.
$commit = Invoke-RestMethod -Uri "$api/commits/main" -Headers $headers
$sha = $commit.sha
if ($sha -notmatch '^[a-f0-9]{40}$') { throw 'Invalid commit SHA.' }
$runs = Invoke-RestMethod -Uri "$api/actions/workflows/cd.yml/runs?head_sha=$sha&status=success&per_page=10" -Headers $headers
$eligible = @($runs.workflow_runs | Where-Object {
    $_.head_sha -eq $sha -and $_.head_branch -eq 'main' -and
    $_.event -eq 'workflow_run' -and $_.conclusion -eq 'success' -and
    $_.head_repository.full_name -eq $Repository
})
if ($eligible.Count -eq 0) { Write-Output 'No published deployment for current main yet.'; exit 0 }
$published = $false
foreach ($run in $eligible) {
    $jobs = Invoke-RestMethod -Uri "$api/actions/runs/$($run.id)/jobs" -Headers $headers
    if (@($jobs.jobs | Where-Object { $_.name -eq 'publish' -and $_.conclusion -eq 'success' }).Count -gt 0) {
        $published = $true
        break
    }
}
if (-not $published) { Write-Output 'Image publication was skipped; nothing to deploy.'; exit 0 }
$image = 'ghcr.io/' + $Repository.ToLowerInvariant() + '/backend:sha-' + $sha
if ($CheckOnly) { Write-Output "Eligible image: $image"; exit 0 }

$env:BACKEND_ENV_FILE = (Resolve-Path -LiteralPath $EnvFile).Path
$compose = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../backend/compose.cd.yaml')).Path
New-Item -ItemType Directory -Force -Path $StateDirectory | Out-Null
$lockPath = Join-Path $StateDirectory 'deploy.lock'
$lock = $null
try {
    # Also prevents overlapping manual and scheduled invocations.
    $lock = [IO.File]::Open($lockPath, 'OpenOrCreate', 'ReadWrite', 'None')
} catch { throw 'Another local deployment is running.' }

function Invoke-Docker {
    & docker @args
    if ($LASTEXITCODE -ne 0) { throw "Docker command failed (exit $LASTEXITCODE)." }
}
function Wait-Backend {
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        try {
            $result = Invoke-RestMethod -Uri 'http://127.0.0.1:3000/api/temples' -TimeoutSec 5
            if ($result.success -eq $true) { return }
        } catch { }
        Start-Sleep -Seconds 2
    }
    throw 'Backend health check failed.'
}
try {
    $current = Invoke-Docker inspect hanh-huong-backend | ConvertFrom-Json
    if ($current[0].Config.Labels.'com.docker.compose.project' -ne 'backend') {
        throw 'Existing backend does not belong to expected Compose project backend.'
    }
    $volume = @($current[0].Mounts | Where-Object { $_.Destination -eq '/app/img/avatars' })
    if ($volume.Count -ne 1 -or $volume[0].Name -ne 'backend_avatar_data') {
        throw 'Avatar volume differs from expected backend_avatar_data; stop to preserve data.'
    }
    $runningRevision = $current[0].Config.Labels.'org.opencontainers.image.revision'
    if ($runningRevision -eq $sha -and $current[0].State.Running) {
        Write-Output "Already deployed $sha"; exit 0
    }
    Invoke-Docker pull $image
    $downloaded = Invoke-Docker image inspect $image | ConvertFrom-Json
    if ($downloaded[0].Config.Labels.'org.opencontainers.image.revision' -ne $sha) {
        throw 'Downloaded image revision does not match tested commit.'
    }
    # Recheck after the download: never deploy an obsolete main commit.
    $latest = Invoke-RestMethod -Uri "$api/commits/main" -Headers $headers
    if ($latest.sha -ne $sha) { Write-Output 'Main changed; defer deployment to next poll.'; exit 0 }
    $previousImage = $current[0].Image
    $rollbackTag = 'hanh-huong-backend:rollback-local-cd'
    Invoke-Docker tag $previousImage $rollbackTag
    $env:DEPLOY_IMAGE = $image
    try {
        Invoke-Docker compose -p backend -f $compose up -d --no-deps --pull never backend
        Wait-Backend
    } catch {
        $deployError = $_
        $env:DEPLOY_IMAGE = $rollbackTag
        Invoke-Docker compose -p backend -f $compose up -d --no-deps --pull never backend
        Wait-Backend
        throw "New version failed; restored previous image. $deployError"
    }
    @{ sha = $sha; image = $image; previousImage = $previousImage; deployedAt = (Get-Date).ToUniversalTime().ToString('o') } |
        ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $StateDirectory 'last-deployment.json')
    Write-Output "Deployed $sha; backend health check passed."
} finally {
    $lock.Dispose()
}

