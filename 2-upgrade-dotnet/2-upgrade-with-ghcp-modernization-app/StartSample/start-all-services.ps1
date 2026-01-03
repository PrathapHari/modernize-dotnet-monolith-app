# Start all eShopLite microservices
# This script starts Products API, StoreInfo API, and Store UI in separate windows

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting eShopLite Microservices" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Function to check if a port is in use
function Test-PortInUse {
    param([int]$Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return $null -ne $connection
}

# Check if ports are already in use
$portsToCheck = @{
    "7001" = "Products API"
    "7002" = "StoreInfo API"
    "63769" = "Store UI"
}

$portsInUse = @()
foreach ($port in $portsToCheck.Keys) {
    if (Test-PortInUse -Port $port) {
        $portsInUse += "$port ($($portsToCheck[$port]))"
    }
}

if ($portsInUse.Count -gt 0) {
    Write-Host "⚠️  Warning: The following ports are already in use:" -ForegroundColor Yellow
    foreach ($port in $portsInUse) {
        Write-Host "   - $port" -ForegroundColor Yellow
    }
    Write-Host ""
    $response = Read-Host "Continue anyway? (yes/no)"
    if ($response -ne "yes") {
        Write-Host "Cancelled." -ForegroundColor Red
        exit 0
    }
    Write-Host ""
}

# Start Products API
Write-Host "🚀 Starting Products API on https://localhost:7001..." -ForegroundColor Green
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd 'src\eShopLite.Products'; Write-Host '========================================' -ForegroundColor Cyan; Write-Host 'Products API' -ForegroundColor Cyan; Write-Host '========================================' -ForegroundColor Cyan; dotnet run --launch-profile https"
)
Start-Sleep -Seconds 3

# Start StoreInfo API
Write-Host "🚀 Starting StoreInfo API on https://localhost:7002..." -ForegroundColor Green
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd 'src\eShopLite.StoreInfo'; Write-Host '========================================' -ForegroundColor Cyan; Write-Host 'StoreInfo API' -ForegroundColor Cyan; Write-Host '========================================' -ForegroundColor Cyan; dotnet run --launch-profile https"
)
Start-Sleep -Seconds 3

# Start Store UI
Write-Host "🚀 Starting Store UI on http://localhost:63769..." -ForegroundColor Green
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd 'src\eShopLite.StoreFx'; Write-Host '========================================' -ForegroundColor Cyan; Write-Host 'Store UI (Blazor)' -ForegroundColor Cyan; Write-Host '========================================' -ForegroundColor Cyan; dotnet run"
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All Services Starting..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 Service URLs:" -ForegroundColor Yellow
Write-Host "   Products API:  https://localhost:7001/api/products" -ForegroundColor Cyan
Write-Host "   StoreInfo API: https://localhost:7002/api/stores" -ForegroundColor Cyan
Write-Host "   Store UI:      http://localhost:63769" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏳ Please wait 10-15 seconds for all services to initialize..." -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Yellow
Write-Host "   - Check each PowerShell window for startup logs" -ForegroundColor Gray
Write-Host "   - Test APIs: .\test-apis.ps1" -ForegroundColor Gray
Write-Host "   - Close all windows to stop services" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to open the Store UI in browser..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Start-Process "http://localhost:63769"

Write-Host ""
Write-Host "✅ Browser opened. Services are running in separate windows." -ForegroundColor Green
Write-Host ""
