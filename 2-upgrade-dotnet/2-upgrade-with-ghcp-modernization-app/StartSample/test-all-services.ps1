# Test eShopLite Microservices APIs
# Verifies that all APIs are responding correctly

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing eShopLite Microservices" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true

# Test 1: Products API
Write-Host "🔍 Testing Products API (https://localhost:7001)..." -ForegroundColor Yellow
try {
    $productsResponse = Invoke-RestMethod -Uri "https://localhost:7001/api/products" -Method Get -SkipCertificateCheck -TimeoutSec 5
    if ($productsResponse -and $productsResponse.Count -gt 0) {
        Write-Host "   ✅ Products API: OK - Found $($productsResponse.Count) products" -ForegroundColor Green
        Write-Host "      Sample: $($productsResponse[0].Name) - `$$($productsResponse[0].Price)" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠️  Products API: Responding but no products found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Products API: FAILED - $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "      Make sure the Products API is running on port 7001" -ForegroundColor Gray
    $allPassed = $false
}

Write-Host ""

# Test 2: StoreInfo API
Write-Host "🔍 Testing StoreInfo API (https://localhost:7002)..." -ForegroundColor Yellow
try {
    $storesResponse = Invoke-RestMethod -Uri "https://localhost:7002/api/stores" -Method Get -SkipCertificateCheck -TimeoutSec 5
    if ($storesResponse -and $storesResponse.Count -gt 0) {
        Write-Host "   ✅ StoreInfo API: OK - Found $($storesResponse.Count) stores" -ForegroundColor Green
        Write-Host "      Sample: $($storesResponse[0].Name) in $($storesResponse[0].City), $($storesResponse[0].State)" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠️  StoreInfo API: Responding but no stores found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ StoreInfo API: FAILED - $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "      Make sure the StoreInfo API is running on port 7002" -ForegroundColor Gray
    $allPassed = $false
}

Write-Host ""

# Test 3: Store UI
Write-Host "🔍 Testing Store UI (http://localhost:63769)..." -ForegroundColor Yellow
try {
    $uiResponse = Invoke-WebRequest -Uri "http://localhost:63769" -Method Get -TimeoutSec 5 -UseBasicParsing
    if ($uiResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Store UI: OK - Status $($uiResponse.StatusCode)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Store UI: Status $($uiResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Store UI: FAILED - $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "      Make sure the Store UI is running on port 63769" -ForegroundColor Gray
    $allPassed = $false
}

Write-Host ""

# Test 4: Check individual product endpoint
Write-Host "🔍 Testing Individual Product Endpoint..." -ForegroundColor Yellow
try {
    $singleProduct = Invoke-RestMethod -Uri "https://localhost:7001/api/products/1" -Method Get -SkipCertificateCheck -TimeoutSec 5
    if ($singleProduct) {
        Write-Host "   ✅ Product Details: OK - Product #$($singleProduct.Id): $($singleProduct.Name)" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Product Details: FAILED - $($_.Exception.Message)" -ForegroundColor Red
    $allPassed = $false
}

Write-Host ""

# Test 5: Check individual store endpoint
Write-Host "🔍 Testing Individual Store Endpoint..." -ForegroundColor Yellow
try {
    $singleStore = Invoke-RestMethod -Uri "https://localhost:7002/api/stores/1" -Method Get -SkipCertificateCheck -TimeoutSec 5
    if ($singleStore) {
        Write-Host "   ✅ Store Details: OK - Store #$($singleStore.Id): $($singleStore.Name)" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Store Details: FAILED - $($_.Exception.Message)" -ForegroundColor Red
    $allPassed = $false
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($allPassed) {
    Write-Host "✅ ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "All microservices are running correctly!" -ForegroundColor Green
    Write-Host "You can now access the Store UI at: http://localhost:63769" -ForegroundColor Cyan
} else {
    Write-Host "❌ SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Make sure all services are running: .\start-all-services.ps1" -ForegroundColor Gray
    Write-Host "  2. Check that ports 7001, 7002, and 63769 are not blocked" -ForegroundColor Gray
    Write-Host "  3. Review the console output in each service window" -ForegroundColor Gray
    Write-Host "  4. Check firewall settings for localhost connections" -ForegroundColor Gray
}

Write-Host ""
