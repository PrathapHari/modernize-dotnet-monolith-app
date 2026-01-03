# 🚀 Manual Microservices Migration Steps

## Quick Setup Commands

Run these commands in PowerShell from your workspace root:

### Step 1: Create Products API Project

```powershell
# Create the Products API project
dotnet new webapi -n eShopLite.Products -o src\eShopLite.Products --no-controllers

# Add to solution (if solution exists)
dotnet sln add src\eShopLite.Products\eShopLite.Products.csproj

# Build to verify
dotnet build src\eShopLite.Products\eShopLite.Products.csproj
```

### Step 2: Create StoreInfo API Project

```powershell
# Create the StoreInfo API project
dotnet new webapi -n eShopLite.StoreInfo -o src\eShopLite.StoreInfo --no-controllers

# Add to solution (if solution exists)
dotnet sln add src\eShopLite.StoreInfo\eShopLite.StoreInfo.csproj

# Build to verify
dotnet build src\eShopLite.StoreInfo\eShopLite.StoreInfo.csproj
```

### Step 3: Verify Structure

```powershell
# Check that projects were created
Get-ChildItem src -Directory

# Should show:
# - eShopLite.StoreFx
# - eShopLite.Products
# - eShopLite.StoreInfo
```

## Next Steps

After creating the project structure, follow these steps:

1. **Implement Products API** - Follow Phase 1 in MICROSERVICES_MIGRATION_PLAN.md
   - Create Models/Product.cs
   - Create Data/ProductDbContext.cs
   - Implement Program.cs with Minimal API endpoints
   - Configure appsettings.json

2. **Implement StoreInfo API** - Follow Phase 2 in MICROSERVICES_MIGRATION_PLAN.md
   - Create Models/StoreInfo.cs
   - Create Data/StoreInfoDbContext.cs
   - Implement Program.cs with Minimal API endpoints
   - Configure appsettings.json

3. **Transform Store UI** - Follow Phase 3 in MICROSERVICES_MIGRATION_PLAN.md
   - Create ApiClients/ApiClient.cs (base class)
   - Create ApiClients/ProductApiClient.cs
   - Create ApiClients/StoreInfoApiClient.cs
   - Update Components/Pages/Products.razor
   - Update Components/Pages/Stores.razor
   - Update Program.cs with HttpClient configuration
   - Remove old services and DbContext

## Running All Services

Create a simple batch file to start all services:

### run-all.cmd

```batch
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
```

## Testing APIs

Test each API individually:

### Test Products API

```powershell
# Test Products API
Invoke-RestMethod -Uri "https://localhost:7001/api/products" -SkipCertificateCheck

# Or open Swagger
start https://localhost:7001/swagger
```

### Test StoreInfo API

```powershell
# Test StoreInfo API
Invoke-RestMethod -Uri "https://localhost:7002/api/stores" -SkipCertificateCheck

# Or open Swagger
start https://localhost:7002/swagger
```

### Test Store UI

```powershell
# Open the UI
start https://localhost:5001
```

## Troubleshooting

### If "dotnet new" fails

Make sure you have .NET 10 SDK installed:
```powershell
dotnet --version
# Should show 10.x.x
```

### If projects don't build

Check for missing dependencies:
```powershell
cd src\eShopLite.Products
dotnet restore
dotnet build
```

### If ports are in use

Check what's using the ports:
```powershell
netstat -ano | findstr :7001
netstat -ano | findstr :7002
netstat -ano | findstr :5001
```

Kill the process if needed:
```powershell
taskkill /PID <process-id> /F
```

## Quick Reference

- **Documentation**: MICROSERVICES_MIGRATION_PLAN.md (detailed implementation)
- **Quick Start**: MICROSERVICES_QUICK_START.md (quick reference)
- **Summary**: MICROSERVICES_DOCUMENTATION_SUMMARY.md (overview)

## Status Checklist

- [ ] Products API project created
- [ ] StoreInfo API project created
- [ ] Products API code implemented
- [ ] StoreInfo API code implemented
- [ ] Store UI API clients implemented
- [ ] Store UI Razor pages updated
- [ ] All projects build successfully
- [ ] All services run concurrently
- [ ] APIs accessible via Swagger
- [ ] UI displays products correctly
- [ ] UI displays stores correctly

---

**Remember**: This creates the project structure only. You must implement the actual code following the migration plan!
