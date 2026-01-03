# Quick Check and Start Script for eShopLite Services

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "eShopLite Services Status Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check which ports are in use
Write-Host "Checking service status..." -ForegroundColor Yellow
$ports = @{
    7001 = "Products API"
    7002 = "StoreInfo API"
    63769 = "Store UI"
}

$runningServices = @()
$missingServices = @()

foreach ($port in $ports.Keys) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "  ✅ $($ports[$port]) is RUNNING on port $port" -ForegroundColor Green
        $runningServices += $ports[$port]
    } else {
        Write-Host "  ❌ $($ports[$port]) is NOT running on port $port" -ForegroundColor Red
        $missingServices += @{Name = $ports[$port]; Port = $port}
    }
}

Write-Host ""

if ($missingServices.Count -eq 0) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ ALL SERVICES ARE RUNNING!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can access:" -ForegroundColor Yellow
    Write-Host "  Store UI:      http://localhost:63769" -ForegroundColor Cyan
    Write-Host "  Products API:  https://localhost:7001/api/products" -ForegroundColor Cyan
    Write-Host "  StoreInfo API: https://localhost:7002/api/stores" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "⚠️  MISSING SERVICES DETECTED" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "The following services need to be started:" -ForegroundColor Yellow
foreach ($service in $missingServices) {
    Write-Host "  - $($service.Name) (port $($service.Port))" -ForegroundColor Red
}
Write-Host ""

$response = Read-Host "Would you like to start the missing services now? (yes/no)"

if ($response -ne "yes") {
    Write-Host ""
    Write-Host "Services NOT started. To start manually, run:" -ForegroundColor Yellow
    Write-Host "  .\start-all-services.ps1" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "Starting missing services..." -ForegroundColor Green
Write-Host ""

# Start Products API if not running
if ($missingServices | Where-Object { $_.Port -eq 7001 }) {
    Write-Host "🚀 Starting Products API..." -ForegroundColor Green
    Start-Process powershell -ArgumentList @(
        "-NoExit",
        "-Command",
        "cd 'src\eShopLite.Products'; Write-Host '========================================' -ForegroundColor Cyan; Write-Host 'Products API' -ForegroundColor Cyan; Write-Host '========================================' -ForegroundColor Cyan; Write-Host ''; Write-Host 'Starting Products API on https://localhost:7001...' -ForegroundColor Yellow; Write-Host ''; dotnet run --launch-profile https"
    )
    Start-Sleep -Seconds 2
}

# Start StoreInfo API if not running
if ($missingServices | Where-Object { $_.Port -eq 7002 }) {
    Write-Host "🚀 Starting StoreInfo API..." -ForegroundColor Green
    Start-Process powershell -ArgumentList @(
        "-NoExit",
        "-Command",
        "cd 'src\eShopLite.StoreInfo'; Write-Host '========================================' -ForegroundColor Cyan; Write-Host 'StoreInfo API' -ForegroundColor Cyan; Write-Host '========================================' -ForegroundColor Cyan; Write-Host ''; Write-Host 'Starting StoreInfo API on https://localhost:7002...' -ForegroundColor Yellow; Write-Host ''; dotnet run --launch-profile https"
    )
    Start-Sleep -Seconds 2
}

# Start Store UI if not running
if ($missingServices | Where-Object { $_.Port -eq 63769 }) {
    Write-Host "🚀 Starting Store UI..." -ForegroundColor Green
    Start-Process powershell -ArgumentList @(
        "-NoExit",
        "-Command",
        "cd 'src\eShopLite.StoreFx'; Write-Host '========================================' -ForegroundColor Cyan; Write-Host 'Store UI (Blazor)' -ForegroundColor Cyan; Write-Host '========================================' -ForegroundColor Cyan; Write-Host ''; Write-Host 'Starting Store UI on http://localhost:63769...' -ForegroundColor Yellow; Write-Host ''; dotnet run"
    )
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Services are starting..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏳ Please wait 10-15 seconds for all services to initialize..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Once started, you can access:" -ForegroundColor Yellow
Write-Host "  Store UI:      http://localhost:63769" -ForegroundColor Cyan
Write-Host "  Products API:  https://localhost:7001/api/products" -ForegroundColor Cyan
Write-Host "  StoreInfo API: https://localhost:7002/api/stores" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Tip: Run '.\test-all-services.ps1' to verify all services are working" -ForegroundColor Gray
Write-Host ""

# Wait and verify
Start-Sleep -Seconds 15

Write-Host "Verifying services..." -ForegroundColor Yellow
$allStarted = $true

foreach ($port in $ports.Keys) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "  ✅ $($ports[$port]) is now running" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $($ports[$port]) may still be starting..." -ForegroundColor Yellow
        $allStarted = $false
    }
}

Write-Host ""

if ($allStarted) {
    Write-Host "✅ All services started successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some services may still be initializing. Check the PowerShell windows for details." -ForegroundColor Yellow
}

Write-Host ""
