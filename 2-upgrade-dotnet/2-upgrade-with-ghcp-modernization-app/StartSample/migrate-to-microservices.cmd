@echo off
REM eShopLite Microservices Migration - Project Setup
REM This script creates the basic project structure

echo ============================================
echo eShopLite Microservices Migration
echo Monolith to Microservices Architecture
echo ============================================
echo.

echo Phase 1: Creating Products API...
if exist "src\eShopLite.Products" (
    echo   WARNING: Products API project already exists!
    set /p DELETE_PRODUCTS="  Delete and recreate? (y/n): "
    if /i "%DELETE_PRODUCTS%"=="y" (
        rmdir /s /q "src\eShopLite.Products"
        echo   Removed existing Products API project
    ) else (
        echo   Skipping Products API creation
        goto STOREINFO
    )
)

dotnet new webapi -n eShopLite.Products -o src\eShopLite.Products --use-minimal-apis
if %ERRORLEVEL% EQU 0 (
    echo   ✓ Created Products API project
    
    REM Add to solution if one exists
    for %%f in (*.sln) do (
        dotnet sln "%%f" add src\eShopLite.Products\eShopLite.Products.csproj
        echo   ✓ Added to solution
    )
) else (
    echo   ✗ Failed to create Products API project
    pause
    exit /b 1
)

echo.

:STOREINFO
echo Phase 2: Creating StoreInfo API...
if exist "src\eShopLite.StoreInfo" (
    echo   WARNING: StoreInfo API project already exists!
    set /p DELETE_STOREINFO="  Delete and recreate? (y/n): "
    if /i "%DELETE_STOREINFO%"=="y" (
        rmdir /s /q "src\eShopLite.StoreInfo"
        echo   Removed existing StoreInfo API project
    ) else (
        echo   Skipping StoreInfo API creation
        goto BUILD
    )
)

dotnet new webapi -n eShopLite.StoreInfo -o src\eShopLite.StoreInfo --use-minimal-apis
if %ERRORLEVEL% EQU 0 (
    echo   ✓ Created StoreInfo API project
    
    REM Add to solution if one exists
    for %%f in (*.sln) do (
        dotnet sln "%%f" add src\eShopLite.StoreInfo\eShopLite.StoreInfo.csproj
        echo   ✓ Added to solution
    )
) else (
    echo   ✗ Failed to create StoreInfo API project
    pause
    exit /b 1
)

echo.

:BUILD
echo Phase 3: Building projects...

if exist "src\eShopLite.Products\eShopLite.Products.csproj" (
    echo   Building Products API...
    dotnet build src\eShopLite.Products\eShopLite.Products.csproj --verbosity quiet
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ Products API built successfully
    ) else (
        echo   ✗ Products API build failed
    )
)

if exist "src\eShopLite.StoreInfo\eShopLite.StoreInfo.csproj" (
    echo   Building StoreInfo API...
    dotnet build src\eShopLite.StoreInfo\eShopLite.StoreInfo.csproj --verbosity quiet
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ StoreInfo API built successfully
    ) else (
        echo   ✗ StoreInfo API build failed
    )
)

echo.

echo Phase 4: Creating helper scripts...

REM Create run-all.cmd
(
echo @echo off
echo echo Starting eShopLite Microservices...
echo echo.
echo.
echo start "Products API" cmd /k "cd src\eShopLite.Products && dotnet run"
echo timeout /t 2 /nobreak ^> nul
echo.
echo start "StoreInfo API" cmd /k "cd src\eShopLite.StoreInfo && dotnet run"
echo timeout /t 2 /nobreak ^> nul
echo.
echo start "Store UI" cmd /k "cd src\eShopLite.StoreFx && dotnet run"
echo.
echo echo.
echo echo All services are starting...
echo echo   Products API:  https://localhost:7001
echo echo   StoreInfo API: https://localhost:7002
echo echo   Store UI:      https://localhost:5001
echo echo.
echo pause
) > run-all.cmd

echo   ✓ Created run-all.cmd

echo.
echo ============================================
echo Migration Script Complete!
echo ============================================
echo.

echo Summary:
echo   Products API:  src\eShopLite.Products
echo   StoreInfo API: src\eShopLite.StoreInfo
echo   Store UI:      src\eShopLite.StoreFx
echo.

echo Next Steps:
echo   1. Review: MICROSERVICES_MIGRATION_PLAN.md
echo   2. Implement code changes as detailed in the plan
echo   3. Run all services: run-all.cmd
echo   4. Test APIs and UI
echo.

echo Important:
echo   This script creates the project structure only.
echo   You must implement the code as per the migration plan.
echo   See MICROSERVICES_MIGRATION_PLAN.md for details.
echo.

set /p OPEN_PLAN="Open migration plan now? (y/n): "
if /i "%OPEN_PLAN%"=="y" (
    start MICROSERVICES_MIGRATION_PLAN.md
)

pause
