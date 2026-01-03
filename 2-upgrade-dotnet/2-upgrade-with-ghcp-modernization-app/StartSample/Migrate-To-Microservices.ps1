# eShopLite Microservices Migration Script
# This script automates the conversion from monolith to microservices

param(
    [switch]$WhatIf = $false,
    [switch]$SkipTests = $false,
    [switch]$CreateDockerFiles = $false
)

$ErrorActionPreference = "Stop"

# Configuration
$workspaceRoot = Get-Location
$sourceProject = "src\eShopLite.StoreFx"
$productsApiProject = "src\eShopLite.Products"
$storeInfoApiProject = "src\eShopLite.StoreInfo"
$storeUiProject = "src\eShopLite.Store"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "eShopLite Microservices Migration" -ForegroundColor Cyan
Write-Host "Monolith → Microservices Architecture" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Phase 1: Create Products API
Write-Host "Phase 1: Creating Products API..." -ForegroundColor Yellow

if (Test-Path $productsApiProject) {
    Write-Host "  ⚠ Products API project already exists!" -ForegroundColor Yellow
    $response = Read-Host "  Delete and recreate? (yes/no)"
    if ($response -eq "yes") {
        if (-not $WhatIf) {
            Remove-Item $productsApiProject -Recurse -Force
            Write-Host "  ✓ Removed existing Products API project" -ForegroundColor Green
        }
    } else {
        Write-Host "  Skipping Products API creation" -ForegroundColor Gray
    }
}

if (-not (Test-Path $productsApiProject)) {
    if (-not $WhatIf) {
        # Create Products API project
        dotnet new webapi -n eShopLite.Products -o $productsApiProject --no-controllers
        Write-Host "  ✓ Created Products API project" -ForegroundColor Green
        
        # Add to solution
        $slnFiles = Get-ChildItem -Filter "*.sln"
        if ($slnFiles.Count -gt 0) {
            dotnet sln $slnFiles[0].Name add "$productsApiProject\eShopLite.Products.csproj"
            Write-Host "  ✓ Added to solution" -ForegroundColor Green
        }
    } else {
        Write-Host "  [WHATIF] Would create Products API project" -ForegroundColor Gray
    }
}

Write-Host ""

# Phase 2: Create StoreInfo API
Write-Host "Phase 2: Creating StoreInfo API..." -ForegroundColor Yellow

if (Test-Path $storeInfoApiProject) {
    Write-Host "  ⚠ StoreInfo API project already exists!" -ForegroundColor Yellow
    $response = Read-Host "  Delete and recreate? (yes/no)"
    if ($response -eq "yes") {
        if (-not $WhatIf) {
            Remove-Item $storeInfoApiProject -Recurse -Force
            Write-Host "  ✓ Removed existing StoreInfo API project" -ForegroundColor Green
        }
    } else {
        Write-Host "  Skipping StoreInfo API creation" -ForegroundColor Gray
    }
}

if (-not (Test-Path $storeInfoApiProject)) {
    if (-not $WhatIf) {
        # Create StoreInfo API project
        dotnet new webapi -n eShopLite.StoreInfo -o $storeInfoApiProject --no-controllers
        Write-Host "  ✓ Created StoreInfo API project" -ForegroundColor Green
        
        # Add to solution
        $slnFiles = Get-ChildItem -Filter "*.sln"
        if ($slnFiles.Count -gt 0) {
            dotnet sln $slnFiles[0].Name add "$storeInfoApiProject\eShopLite.StoreInfo.csproj"
            Write-Host "  ✓ Added to solution" -ForegroundColor Green
        }
    } else {
        Write-Host "  [WHATIF] Would create StoreInfo API project" -ForegroundColor Gray
    }
}

Write-Host ""

# Phase 3: Verify Store UI Project
Write-Host "Phase 3: Verifying Store UI project..." -ForegroundColor Yellow

if (Test-Path $sourceProject) {
    Write-Host "  ✓ Store UI project found at: $sourceProject" -ForegroundColor Green
    Write-Host "  Note: Manual modifications required (see MICROSERVICES_MIGRATION_PLAN.md)" -ForegroundColor Yellow
} else {
    Write-Host "  ⚠ Store UI project not found at: $sourceProject" -ForegroundColor Red
    Write-Host "  Expected to modify existing eShopLite.StoreFx" -ForegroundColor Red
}

Write-Host ""

# Phase 4: Build All Projects
Write-Host "Phase 4: Building projects..." -ForegroundColor Yellow

if (-not $WhatIf) {
    # Build Products API
    if (Test-Path "$productsApiProject\eShopLite.Products.csproj") {
        Write-Host "  Building Products API..." -ForegroundColor Gray
        $buildResult = dotnet build "$productsApiProject\eShopLite.Products.csproj" --verbosity quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Products API built successfully" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Products API build failed" -ForegroundColor Red
            Write-Host "  $buildResult" -ForegroundColor Gray
        }
    }
    
    # Build StoreInfo API
    if (Test-Path "$storeInfoApiProject\eShopLite.StoreInfo.csproj") {
        Write-Host "  Building StoreInfo API..." -ForegroundColor Gray
        $buildResult = dotnet build "$storeInfoApiProject\eShopLite.StoreInfo.csproj" --verbosity quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ StoreInfo API built successfully" -ForegroundColor Green
        } else {
            Write-Host "  ✗ StoreInfo API build failed" -ForegroundColor Red
            Write-Host "  $buildResult" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "  [WHATIF] Would build all projects" -ForegroundColor Gray
}

Write-Host ""

# Phase 5: Create launch scripts
Write-Host "Phase 5: Creating launch scripts..." -ForegroundColor Yellow

if (-not $WhatIf) {
    # Create run-all.ps1
    $runAllScript = @"
# Run all eShopLite microservices

Write-Host "Starting eShopLite Microservices..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Starting Products API on port 7001..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$productsApiProject'; dotnet run"
Start-Sleep -Seconds 2

Write-Host "Starting StoreInfo API on port 7002..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$storeInfoApiProject'; dotnet run"
Start-Sleep -Seconds 2

Write-Host "Starting Store UI on port 5001..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$sourceProject'; dotnet run"

Write-Host ""
Write-Host "All services starting..." -ForegroundColor Green
Write-Host "  Products API:  https://localhost:7001" -ForegroundColor Cyan
Write-Host "  StoreInfo API: https://localhost:7002" -ForegroundColor Cyan
Write-Host "  Store UI:      https://localhost:5001" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to stop all services..." -ForegroundColor Yellow
`$null = `$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "Stopping services..." -ForegroundColor Red
Get-Process | Where-Object {`$_.MainWindowTitle -like "*dotnet*"} | Stop-Process -Force
"@
    
    Set-Content -Path "run-all.ps1" -Value $runAllScript
    Write-Host "  ✓ Created run-all.ps1" -ForegroundColor Green
    
    # Create test-apis.ps1
    $testApisScript = @"
# Test all eShopLite APIs

Write-Host "Testing eShopLite Microservices..." -ForegroundColor Cyan
Write-Host ""

# Test Products API
Write-Host "Testing Products API..." -ForegroundColor Yellow
try {
    `$productsResponse = Invoke-RestMethod -Uri "https://localhost:7001/api/products" -Method Get -SkipCertificateCheck
    Write-Host "  ✓ Products API: Found `$(`$productsResponse.Count) products" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Products API: Failed - `$(`$_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test StoreInfo API
Write-Host "Testing StoreInfo API..." -ForegroundColor Yellow
try {
    `$storesResponse = Invoke-RestMethod -Uri "https://localhost:7002/api/stores" -Method Get -SkipCertificateCheck
    Write-Host "  ✓ StoreInfo API: Found `$(`$storesResponse.Count) stores" -ForegroundColor Green
} catch {
    Write-Host "  ✗ StoreInfo API: Failed - `$(`$_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test Store UI
Write-Host "Testing Store UI..." -ForegroundColor Yellow
try {
    `$uiResponse = Invoke-WebRequest -Uri "https://localhost:5001" -Method Get -SkipCertificateCheck
    if (`$uiResponse.StatusCode -eq 200) {
        Write-Host "  ✓ Store UI: Responding (Status 200)" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Store UI: Failed - `$(`$_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "API Testing Complete!" -ForegroundColor Cyan
"@
    
    Set-Content -Path "test-apis.ps1" -Value $testApisScript
    Write-Host "  ✓ Created test-apis.ps1" -ForegroundColor Green
} else {
    Write-Host "  [WHATIF] Would create launch scripts" -ForegroundColor Gray
}

Write-Host ""

# Summary
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Migration Script Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Products API:  $productsApiProject" -ForegroundColor Gray
Write-Host "  StoreInfo API: $storeInfoApiProject" -ForegroundColor Gray
Write-Host "  Store UI:      $sourceProject" -ForegroundColor Gray
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Review the migration plan: MICROSERVICES_MIGRATION_PLAN.md" -ForegroundColor Gray
Write-Host "  2. Implement the code changes as detailed in the plan" -ForegroundColor Gray
Write-Host "  3. Run all services: .\run-all.ps1" -ForegroundColor Cyan
Write-Host "  4. Test APIs: .\test-apis.ps1" -ForegroundColor Cyan
Write-Host "  5. Verify functionality matches original monolith" -ForegroundColor Gray
Write-Host ""

Write-Host "Important:" -ForegroundColor Yellow
Write-Host "  This script creates the project structure." -ForegroundColor Gray
Write-Host "  You must manually implement the code as per the migration plan." -ForegroundColor Gray
Write-Host "  Refer to MICROSERVICES_MIGRATION_PLAN.md for detailed instructions." -ForegroundColor Gray
Write-Host ""

if (-not $WhatIf) {
    $proceed = Read-Host "Open migration plan now? (yes/no)"
    if ($proceed -eq "yes") {
        Start-Process "MICROSERVICES_MIGRATION_PLAN.md"
    }
}
