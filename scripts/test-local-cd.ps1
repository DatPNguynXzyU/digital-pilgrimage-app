# Offline deployment tests: no network, Docker, production .env, or database access.
$ErrorActionPreference = 'Stop'
$global:cdTestSha = 'a' * 40
$global:cdTestMode = 'success'
$global:cdTestCalls = [Collections.Generic.List[string]]::new()
function global:Invoke-RestMethod {
    param($Uri, $Headers, $TimeoutSec)
    if ($Uri -like '*/commits/main') { return @{ sha = $global:cdTestSha } }
    if ($Uri -match '/runs\?') {
        return @{workflow_runs = @(@{ id=1; head_sha=$global:cdTestSha; head_branch='main'; event='workflow_run'; conclusion='success'; head_repository=@{full_name='owner/repo'} })}
    }
    if ($Uri -like '*/jobs') {
        $conclusion = if ($global:cdTestMode -eq 'skipped') {'skipped'} else {'success'}
        return @{jobs=@(@{name='publish';conclusion=$conclusion})}
    }
    if ($Uri -like 'http://127.0.0.1:*') {
        if ($global:cdTestMode -eq 'rollback' -and $env:DEPLOY_IMAGE -notlike '*rollback*') { throw 'simulated unhealthy API' }
        return @{success=$true}
    }
    throw "Unexpected URL: $Uri"
}
function global:Start-Sleep { param($Seconds) }
function global:docker {
    $global:LASTEXITCODE = 0
    $global:cdTestCalls.Add(($args -join ' '))
    if ($args[0] -eq 'inspect') {
        $volume = if ($global:cdTestMode -eq 'wrong-volume') {'unexpected'} else {'backend_avatar_data'}
        return (@{Config=@{Labels=@{'com.docker.compose.project'='backend'}}; Mounts=@(@{Destination='/app/img/avatars';Name=$volume});Image='sha256:old';State=@{Running=$true}} | ConvertTo-Json -Depth 6)
    }
    if ($args[0] -eq 'image') {
        return (@{Config=@{Labels=@{'org.opencontainers.image.revision'=$global:cdTestSha}}} | ConvertTo-Json -Depth 5)
    }
}
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('local-cd-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot | Out-Null
$envPath = Join-Path $testRoot 'test.env'
Set-Content -LiteralPath $envPath -Value 'TEST_ONLY=true'
$deploy = Join-Path $PSScriptRoot 'deploy-local.ps1'
foreach ($mode in @('success', 'skipped', 'wrong-volume', 'rollback')) {
    $global:cdTestMode = $mode
    $global:cdTestCalls.Clear()
    $failed = $false
    try {
        & $deploy -Repository owner/repo -EnvFile $envPath -StateDirectory (Join-Path $testRoot $mode)
    } catch { $failed = $true }
    $updates = @($global:cdTestCalls | Where-Object { $_ -like 'compose *' }).Count
    switch ($mode) {
        success { if ($failed -or $updates -ne 1) { throw 'Successful deployment test failed' } }
        skipped { if ($failed -or $global:cdTestCalls.Count -ne 0) { throw 'Skipped publish must never deploy' } }
        wrong-volume { if (-not $failed -or $updates -ne 0) { throw 'Volume mismatch must stop deployment' } }
        rollback { if (-not $failed -or $updates -ne 2 -or $env:DEPLOY_IMAGE -notlike '*rollback*') { throw 'Rollback test failed' } }
    }
    Write-Output "PASS: $mode"
}

