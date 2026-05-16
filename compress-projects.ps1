$root = Get-Location
$failed = @()

Get-ChildItem -Path $root -Directory | ForEach-Object {
    $dir = $_
    $zipName = "$($dir.Name).zip"
    $zipPath = Join-Path $root $zipName

    if (Test-Path $zipPath) {
        Write-Host "Exists, skipping compression: $zipName" -ForegroundColor Yellow
    } else {
        Write-Host "Compressing: $($dir.Name) ..."
        Push-Location $dir.FullName
        7za a -tzip -mx=0 -bsp1 -bso0 "$zipPath" .
        Pop-Location
    }

    Write-Host "Testing:     $zipName ..."
    7za t -bsp1 -bso0 "$zipPath"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [FAIL] $($dir.Name)" -ForegroundColor Red
        $failed += $dir.Name
    } else {
        Write-Host "  [OK]   $zipName" -ForegroundColor Green
    }
}

Write-Host ""
if ($failed.Count -gt 0) {
    Write-Host "Failed projects:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
} else {
    Write-Host "All projects compressed successfully." -ForegroundColor Green
}