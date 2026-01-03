# Complete Microservices Verification Script
# This script verifies all phases of the migration are complete

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "eShopLite Microservices Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true

# Phase 1: Verify Products API
Write-Host "Phase 1: Verifying Products API..." -ForegroundColor Yellow
$productsFiles = @(
    "src\eShopLite.Products\Models\Product.cs",
    "src\eShopLite.Products\Data\ProductDbContext.cs",
    "src\eShopLite.Products\Program.cs",
    "src\eShopLite.Products\appsettings.json"
)

foreach ($file in $productsFiles) {
    if (Test-Path $file) {
        Write-Host "  OK $file" -ForegroundColor Green
    } else {
        Write-Host "  MISSING $file" -ForegroundColor Red
        $allPassed = $false
    }
}

# Build Products API
Write-Host "`n  Building Products API..." -ForegroundColor Gray
$buildResult = dotnet build src\eShopLite.Products\eShopLite.Products.csproj --verbosity quiet 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK Products API builds successfully" -ForegroundColor Green
} else {
    Write-Host "  FAIL Products API build failed" -ForegroundColor Red
    $allPassed = $false
}

Write-Host ""

# Phase 2: Verify StoreInfo API
Write-Host "Phase 2: Verifying StoreInfo API..." -ForegroundColor Yellow
$storeInfoFiles = @(
    "src\eShopLite.StoreInfo\Models\StoreInfo.cs",
    "src\eShopLite.StoreInfo\Data\StoreInfoDbContext.cs",
    "src\eShopLite.StoreInfo\Program.cs",
    "src\eShopLite.StoreInfo\appsettings.json"
)

foreach ($file in $storeInfoFiles) {
    if (Test-Path $file) {
        Write-Host "  OK $file" -ForegroundColor Green
    } else {
        Write-Host "  MISSING $file" -ForegroundColor Red
        $allPassed = $false
    }
}

# Build StoreInfo API
Write-Host "`n  Building StoreInfo API..." -ForegroundColor Gray
$buildResult = dotnet build src\eShopLite.StoreInfo\eShopLite.StoreInfo.csproj --verbosity quiet 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK StoreInfo API builds successfully" -ForegroundColor Green
} else {
    Write-Host "  FAIL StoreInfo API build failed" -ForegroundColor Red
    $allPassed = $false
}

Write-Host ""

# Phase 3: Verify Store UI Transformation
Write-Host "Phase 3: Verifying Store UI Transformation..." -ForegroundColor Yellow
$storeUiFiles = @(
    "src\eShopLite.StoreFx\ApiClients\ApiClient.cs",
    "src\eShopLite.StoreFx\ApiClients\ProductApiClient.cs",
    "src\eShopLite.StoreFx\ApiClients\StoreInfoApiClient.cs"
)

foreach ($file in $storeUiFiles) {
    if (Test-Path $file) {
        Write-Host "  OK $file" -ForegroundColor Green
    } else {
        Write-Host "  MISSING $file" -ForegroundColor Red
        $allPassed = $false
    }
}

# Build Store UI
Write-Host "`n  Building Store UI..." -ForegroundColor Gray
$buildResult = dotnet build src\eShopLite.StoreFx\eShopLite.Store.csproj --verbosity quiet 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK Store UI builds successfully" -ForegroundColor Green
} else {
    Write-Host "  FAIL Store UI build failed" -ForegroundColor Red
    $allPassed = $false
}

Write-Host ""

# Check NuGet Packages
Write-Host "Verifying NuGet Packages..." -ForegroundColor Yellow
$storeUiCsproj = Get-Content "src\eShopLite.StoreFx\eShopLite.Store.csproj" -Raw
if ($storeUiCsproj -like "*Microsoft.Extensions.Http.Polly*") {
    Write-Host "  ✓ Polly package installed" -ForegroundColor Green
} else {
    Write-Host "  ✗ Polly package missing" -ForegroundColor Red
    $allPassed = $false
}

if ($storeUiCsproj -like "*AspNetCore.HealthChecks.Uris*") {
    Write-Host "  ✓ HealthChecks.Uris package installed" -ForegroundColor Green
} else {
    Write-Host "  ✗ HealthChecks.Uris package missing" -ForegroundColor Red
    $allPassed = $false
}

$productsApiCsproj = Get-Content "src\eShopLite.Products\eShopLite.Products.csproj" -Raw
if ($productsApiCsproj -like "*Microsoft.EntityFrameworkCore.Sqlite*") {
    Write-Host "  ✓ Products API has EF Core SQLite" -ForegroundColor Green
} else {
    Write-Host "  ✗ Products API missing EF Core SQLite" -ForegroundColor Red
    $allPassed = $false
}

$storeInfoApiCsproj = Get-Content "src\eShopLite.StoreInfo\eShopLite.StoreInfo.csproj" -Raw
if ($storeInfoApiCsproj -like "*Microsoft.EntityFrameworkCore.Sqlite*") {
    Write-Host "  ✓ StoreInfo API has EF Core SQLite" -ForegroundColor Green
} else {
    Write-Host "  ✗ StoreInfo API missing EF Core SQLite" -ForegroundColor Red
    $allPassed = $false
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "ALL PHASES COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "All 3 microservices are ready to run!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Run: .\run-all.ps1" -ForegroundColor Cyan
    Write-Host "  2. Test: .\test-apis.ps1" -ForegroundColor Cyan
    Write-Host "  3. Open: https://localhost:5001" -ForegroundColor Cyan
} else {
    Write-Host "VERIFICATION FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Some components are missing or failed to build." -ForegroundColor Red
}
Write-Host ""
