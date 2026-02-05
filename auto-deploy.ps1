# ============================================
# 자동 배포 스크립트 (파일 변경 감지 → 자동 push)
# ============================================
# 사용법: 이 파일을 우클릭 → "PowerShell에서 실행"
# 종료: Ctrl+C 또는 창 닫기

$repoPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoPath

Write-Host ""
Write-Host "  ====================================" -ForegroundColor Cyan
Write-Host "  자동 배포 모드 실행 중" -ForegroundColor Cyan
Write-Host "  ====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  감시 폴더: $repoPath" -ForegroundColor Gray
Write-Host "  파일 저장하면 5초 후 자동 배포됩니다." -ForegroundColor Gray
Write-Host "  종료하려면 Ctrl+C 를 누르세요." -ForegroundColor Yellow
Write-Host ""

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repoPath
$watcher.IncludeSubdirectories = $true
$watcher.Filter = "*.html"
$watcher.EnableRaisingEvents = $false

$lastDeploy = [datetime]::MinValue
$debounceSeconds = 5

Write-Host "  [대기중] 파일 변경을 기다리는 중..." -ForegroundColor DarkGray

while ($true) {
    $result = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::Changed -bor [System.IO.WatcherChangeTypes]::Created, 1000)

    if (-not $result.TimedOut) {
        $now = Get-Date
        $elapsed = ($now - $lastDeploy).TotalSeconds

        if ($elapsed -lt $debounceSeconds) {
            continue
        }

        # 디바운스: 추가 변경 대기
        Write-Host ""
        Write-Host "  [감지] 파일 변경됨: $($result.Name)" -ForegroundColor Yellow
        Write-Host "  [대기] ${debounceSeconds}초 후 배포..." -ForegroundColor DarkGray
        Start-Sleep -Seconds $debounceSeconds

        # git add + commit + push
        try {
            $timestamp = Get-Date -Format "MM/dd HH:mm"

            git add -A 2>$null
            $status = git status --porcelain 2>$null

            if ($status) {
                git commit -m "auto-deploy: $timestamp" 2>$null | Out-Null

                Write-Host "  [배포] GitHub에 push 중..." -ForegroundColor Cyan
                $pushResult = git push 2>&1

                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  [완료] 배포 성공! ($timestamp)" -ForegroundColor Green
                    Write-Host "  [링크] 1~2분 후 Vercel에 반영됩니다." -ForegroundColor DarkGray
                } else {
                    Write-Host "  [오류] push 실패: $pushResult" -ForegroundColor Red
                }

                $lastDeploy = Get-Date
            } else {
                Write-Host "  [스킵] 변경사항 없음" -ForegroundColor DarkGray
            }
        } catch {
            Write-Host "  [오류] $($_.Exception.Message)" -ForegroundColor Red
        }

        Write-Host ""
        Write-Host "  [대기중] 파일 변경을 기다리는 중..." -ForegroundColor DarkGray
    }
}
