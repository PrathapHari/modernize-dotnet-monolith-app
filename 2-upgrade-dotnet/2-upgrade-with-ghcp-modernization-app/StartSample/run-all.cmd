@echo off
echo Starting eShopLite Microservices...
echo.

start "Products API" cmd /k "cd src\eShopLite.Products && dotnet run"
timeout /t 2 /nobreak > nul

start "StoreInfo API" cmd /k "cd src\eShopLite.StoreInfo && dotnet run"
timeout /t 2 /nobreak > nul

start "Store UI" cmd /k "cd src\eShopLite.StoreFx && dotnet run"

echo.
echo All services are starting...
echo   Products API:  https://localhost:7001
echo   StoreInfo API: https://localhost:7002
echo   Store UI:      https://localhost:5001
echo.
pause
