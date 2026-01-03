# eShopLite.StoreFx → eShopLite.Store Migration Plan

## 🎯 Migration Overview

**Source Project**: `eShopLite.StoreFx`  
**Target Project**: `eShopLite.Store`  
**Framework**: .NET 10 Blazor Server  
**Database**: SQLite (eShopLite.db)  

**Constraints**:
- ✅ Keep layout unchanged (MainLayout.razor, App.razor)
- ✅ Keep CSS style unchanged (Bootstrap 5, site.css)
- ✅ Keep JS interaction unchanged (Bootstrap bundle)
- ✅ Preserve all functionality
- ✅ Maintain database compatibility

---

## 📋 Pre-Migration Checklist

### Step 1: Backup Current State

```powershell
# Navigate to workspace root
cd "C:\Users\prath\OneDrive\Documents\GitHub Copilot\Source\2-upgrade-dotnet\2-upgrade-with-ghcp-modernization-app\StartSample"

# Create backup
Copy-Item -Path "src\eShopLite.StoreFx" -Destination "src\eShopLite.StoreFx.backup" -Recurse

# Commit current changes to Git
git add .
git commit -m "Pre-migration backup: eShopLite.StoreFx"
```

### Step 2: Verify Current State

```powershell
# Build current project
dotnet build src\eShopLite.StoreFx\eShopLite.StoreFx.csproj

# Run tests (if any)
dotnet test

# Take screenshots of:
# - Home page
# - Products page
# - Stores page
# - Database Status page
```

### Step 3: Document Current Configuration

**Files to preserve exactly**:
- `wwwroot/css/site.css` - Custom styles
- `wwwroot/lib/` - Bootstrap, Bootstrap Icons, jQuery
- `Components/App.razor` - Root component with CSS/JS references
- `Components/Layout/MainLayout.razor` - Layout structure
- `Components/Pages/*.razor` - All page components
- `appsettings.json` - Configuration settings
- `libman.json` - Client-side library config

---

## 🔄 Migration Steps

### Phase 1: Create New Project Structure

#### Step 1.1: Create New Project Directory

```powershell
# Create new project directory
New-Item -ItemType Directory -Path "src\eShopLite.Store" -Force

# Verify
Test-Path "src\eShopLite.Store"
```

#### Step 1.2: Create New .csproj File

**File**: `src\eShopLite.Store\eShopLite.Store.csproj`

Copy from `eShopLite.StoreFx.csproj` and update:
- `<RootNamespace>` → `eShopLite.Store`
- `<AssemblyName>` → `eShopLite.Store`
- Keep all PackageReferences unchanged
- Keep all ItemGroups unchanged

#### Step 1.3: Copy All Source Files

```powershell
# Copy all files preserving structure
$source = "src\eShopLite.StoreFx"
$dest = "src\eShopLite.Store"

# Exclude obj, bin, .vs directories
$excludes = @('obj', 'bin', '.vs', '*.user', '*.suo')

Get-ChildItem -Path $source -Recurse | 
    Where-Object { 
        $exclude = $false
        foreach ($pattern in $excludes) {
            if ($_.FullName -like "*$pattern*") {
                $exclude = $true
                break
            }
        }
        -not $exclude
    } | 
    Copy-Item -Destination { 
        $_.FullName.Replace($source, $dest) 
    } -Force
```

---

### Phase 2: Update Namespaces and References

#### Step 2.1: Update All Namespaces

**Find and Replace**:
```
Find:    eShopLite.StoreFx
Replace: eShopLite.Store
```

**Files to update**:
- All `.cs` files (Services, Models, Data, Program.cs)
- All `.razor` files (Components, Pages, Layout)
- `_Imports.razor`
- `.csproj` file

**PowerShell Script**:
```powershell
$projectPath = "src\eShopLite.Store"

# Update all .cs files
Get-ChildItem -Path $projectPath -Include *.cs -Recurse | 
    ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $content = $content -replace 'eShopLite\.StoreFx', 'eShopLite.Store'
        Set-Content -Path $_.FullName -Value $content -NoNewline
    }

# Update all .razor files
Get-ChildItem -Path $projectPath -Include *.razor -Recurse | 
    ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $content = $content -replace 'eShopLite\.StoreFx', 'eShopLite.Store'
        Set-Content -Path $_.FullName -Value $content -NoNewline
    }

# Update .csproj file
$csprojPath = "$projectPath\eShopLite.Store.csproj"
$content = Get-Content $csprojPath -Raw
$content = $content -replace 'eShopLite\.StoreFx', 'eShopLite.Store'
Set-Content -Path $csprojPath -Value $content -NoNewline
```

#### Step 2.2: Update Database Path (if needed)

**File**: `src\eShopLite.Store\appsettings.json`

Verify connection string points to correct database:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=eShopLite.db;Cache=Shared"
  }
}
```

**Note**: Database file can remain in same location or be copied to new project.

---

### Phase 3: Preserve Styling and Layout

#### Step 3.1: Verify App.razor (Root Component)

**File**: `src\eShopLite.Store\Components\App.razor`

**Must remain exactly**:
```razor
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <base href="/" />
    <title>eShopLite</title>
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="/lib/bootstrap/css/bootstrap.min.css" id="bootstrap-css" />
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="/lib/bootstrap-icons/font/bootstrap-icons.min.css" id="bootstrap-icons-css" />
    
    <!-- Site CSS -->
    <link rel="stylesheet" href="/css/site.css" id="site-css" />
    
    <HeadOutlet />
</head>
<body>
    <Routes />
    
    <!-- Bootstrap JS -->
    <script src="/lib/bootstrap/js/bootstrap.bundle.min.js" id="bootstrap-js"></script>
    
    <!-- Blazor Framework -->
    <script src="_framework/blazor.web.js"></script>
</body>
</html>
```

✅ **No changes to CSS/JS references**

#### Step 3.2: Verify MainLayout.razor

**File**: `src\eShopLite.Store\Components\Layout\MainLayout.razor`

**Must remain exactly**:
```razor
@inherits LayoutComponentBase

<nav class="navbar navbar-expand-sm navbar-toggleable-sm navbar-light bg-white">
    <div class="container">
        <a class="navbar-brand" href="/">eShopLite</a>
        <button type="button" class="navbar-toggler" data-bs-toggle="collapse" data-bs-target=".navbar-collapse">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse d-sm-inline-flex justify-content-between">
            <ul class="navbar-nav flex-grow-1">
                <li class="nav-item">
                    <a class="nav-link text-dark" href="/products">Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="/stores">Stores</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<div class="container body-content">
    @Body
    <hr />
    <footer>
        <p>&copy; @DateTime.Now.Year - eShopLite</p>
    </footer>
</div>
```

✅ **No layout changes**

#### Step 3.3: Verify wwwroot Contents

**Directory**: `src\eShopLite.Store\wwwroot`

**Must contain (unchanged)**:
```
wwwroot/
├── css/
│   └── site.css                          ← Keep exact copy
├── lib/
│   ├── bootstrap/
│   │   ├── css/
│   │   │   ├── bootstrap.min.css        ← Keep exact copy
│   │   │   └── bootstrap.min.css.map
│   │   └── js/
│   │       ├── bootstrap.bundle.min.js  ← Keep exact copy
│   │       └── bootstrap.bundle.min.js.map
│   ├── bootstrap-icons/
│   │   └── font/
│   │       ├── bootstrap-icons.min.css  ← Keep exact copy
│   │       └── fonts/
│   └── jquery/
│       ├── jquery.min.js
│       └── jquery.min.map
├── images/
│   ├── product1.png                      ← Keep all images
│   └── ...
└── diagnostics.html                      ← Keep test file
```

**Verification**:
```powershell
# Compare file sizes to ensure exact copies
$oldPath = "src\eShopLite.StoreFx\wwwroot"
$newPath = "src\eShopLite.Store\wwwroot"

Compare-Object (Get-ChildItem $oldPath -Recurse) (Get-ChildItem $newPath -Recurse) -Property Name, Length
```

#### Step 3.4: Verify libman.json

**File**: `src\eShopLite.Store\libman.json`

**Must remain exactly**:
```json
{
  "version": "1.0", 
  "defaultProvider": "cdnjs",
  "libraries": [
    {
      "library": "bootstrap@5.3.2",
      "destination": "wwwroot/lib/bootstrap/",
      "files": [
        "css/bootstrap.min.css",
        "css/bootstrap.min.css.map",
        "js/bootstrap.bundle.min.js",
        "js/bootstrap.bundle.min.js.map"
      ]
    },
    {
      "library": "bootstrap-icons@1.11.1",
      "destination": "wwwroot/lib/bootstrap-icons/",
      "files": [
        "font/bootstrap-icons.css",
        "font/bootstrap-icons.min.css",
        "font/fonts/bootstrap-icons.woff",
        "font/fonts/bootstrap-icons.woff2"
      ]
    },
    {
      "library": "jquery@3.7.1",
      "destination": "wwwroot/lib/jquery/",
      "files": [
        "jquery.min.js",
        "jquery.min.map"
      ]
    }
  ]
}
```

✅ **No library changes**

---

### Phase 4: Update Solution File

#### Step 4.1: Create/Update .sln File

**Option A: Update existing solution**

```powershell
# Remove old project
dotnet sln remove src\eShopLite.StoreFx\eShopLite.StoreFx.csproj

# Add new project
dotnet sln add src\eShopLite.Store\eShopLite.Store.csproj
```

**Option B: Create new solution**

```powershell
# Create new solution
dotnet new sln -n eShopLite -o .

# Add project
dotnet sln add src\eShopLite.Store\eShopLite.Store.csproj
```

---

### Phase 5: Database Migration

#### Step 5.1: Option A - Shared Database (Recommended)

**Keep database in original location**:
- Database remains at: `src\eShopLite.StoreFx\eShopLite.db`
- Update connection string in new project to point to it

**File**: `src\eShopLite.Store\appsettings.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=../eShopLite.StoreFx/eShopLite.db;Cache=Shared"
  }
}
```

#### Step 5.2: Option B - Copy Database

```powershell
# Copy database to new project
Copy-Item "src\eShopLite.StoreFx\eShopLite.db" "src\eShopLite.Store\eShopLite.db"

# Update connection string to use local db
# (Keep "Data Source=eShopLite.db;Cache=Shared")
```

---

### Phase 6: Build and Test

#### Step 6.1: Clean and Restore

```powershell
# Navigate to new project
cd src\eShopLite.Store

# Restore NuGet packages
dotnet restore

# Restore client-side libraries
libman restore

# Build project
dotnet build
```

#### Step 6.2: Run Application

```powershell
# Run the new project
dotnet run --project src\eShopLite.Store\eShopLite.Store.csproj
```

#### Step 6.3: Verify Functionality

**Test Checklist**:
- [ ] Application starts without errors
- [ ] Home page loads correctly
- [ ] Products page displays card grid layout
- [ ] Stores page displays card layout with icons
- [ ] Database Status page shows data
- [ ] Error page handles 404s correctly
- [ ] Navigation menu works
- [ ] Menu toggle works on mobile (Bootstrap JS)
- [ ] All Bootstrap styles applied correctly
- [ ] Bootstrap Icons display correctly
- [ ] Custom site.css styles applied
- [ ] Product images load
- [ ] Database queries work
- [ ] No console errors (F12)
- [ ] All static files return 200 OK

#### Step 6.4: Visual Comparison

**Compare with screenshots taken in Step 2**:
1. Home page - Should be identical
2. Products page - Should be identical
3. Stores page - Should be identical
4. Layout and navigation - Should be identical

---

### Phase 7: Update Configuration Files

#### Step 7.1: Update launchSettings.json

**File**: `src\eShopLite.Store\Properties\launchSettings.json`

Update profile names:
```json
{
  "profiles": {
    "eShopLite.Store": {  // Changed from eShopLite.StoreFx
      "commandName": "Project",
      "launchBrowser": true,
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      },
      "applicationUrl": "https://localhost:5001;http://localhost:5000"
    }
  }
}
```

#### Step 7.2: Update Program.cs Logging

**File**: `src\eShopLite.Store\Program.cs`

Update log messages:
```csharp
logger.LogInformation("eShopLite.Store Application Starting (Blazor)");
// Changed from: "eShopLite.StoreFx Application Starting (Blazor)"
```

---

### Phase 8: Git Migration

#### Step 8.1: Add New Project to Git

```powershell
# Stage new project
git add src\eShopLite.Store

# Commit
git commit -m "Add eShopLite.Store - migrated from eShopLite.StoreFx"
```

#### Step 8.2: Remove Old Project (Optional)

**⚠️ Only after verifying new project works!**

```powershell
# Remove from Git (but keep backup)
git rm -r src\eShopLite.StoreFx --cached

# Commit
git commit -m "Remove eShopLite.StoreFx (migrated to eShopLite.Store)"

# Keep backup directory
# Don't delete src\eShopLite.StoreFx.backup until fully confident
```

---

### Phase 9: Update Documentation

#### Step 9.1: Update README Files

Search and replace in all documentation:
- `eShopLite.StoreFx` → `eShopLite.Store`

**Files to update**:
- README.md
- ARCHITECTURE_IMPROVEMENT.md
- BLAZOR_CONVERSION_SUMMARY.md
- Any other documentation files

#### Step 9.2: Update MCP Configuration

**File**: `eShopLite-mcp-config.json`

Update database path:
```json
{
  "sqlite": {
    "configuration": {
      "databasePath": "./src/eShopLite.Store/eShopLite.db"  // Updated path
    }
  }
}
```

---

## ✅ Post-Migration Verification

### Checklist

**Functionality**:
- [ ] All pages load correctly
- [ ] Database operations work
- [ ] Navigation functions properly
- [ ] Forms work (if any)
- [ ] Error handling works

**Styling** (Must be identical):
- [ ] Bootstrap CSS loaded: Check F12 → Network → bootstrap.min.css (200 OK)
- [ ] Bootstrap Icons loaded: Check icons display correctly
- [ ] Site.css loaded: Check custom styles applied
- [ ] Layout matches original: Compare screenshots
- [ ] Responsive behavior works: Test mobile view (F12 → Toggle device toolbar)

**JavaScript** (Must be identical):
- [ ] Bootstrap JS loaded: Check F12 → Network → bootstrap.bundle.min.js (200 OK)
- [ ] Navbar toggle works: Click hamburger menu on mobile view
- [ ] No console errors: Check F12 → Console (should be clean)

**Performance**:
- [ ] Page load time similar to original
- [ ] No new warnings in console
- [ ] Database queries perform the same

**Browser Testing**:
- [ ] Chrome/Edge
- [ ] Firefox
- [ ] Mobile view (F12 → Device toolbar)

---

## 🐛 Troubleshooting

### Issue: Build Errors

**Symptom**: Namespace errors, missing references

**Fix**:
```powershell
# Ensure all namespaces updated
Get-ChildItem -Path "src\eShopLite.Store" -Include *.cs,*.razor -Recurse | 
    Select-String "eShopLite.StoreFx"

# Should return no results
```

### Issue: Static Files Not Loading

**Symptom**: 404 errors for CSS/JS files

**Fix**:
```powershell
# Verify wwwroot copied correctly
Test-Path "src\eShopLite.Store\wwwroot\lib\bootstrap\css\bootstrap.min.css"
Test-Path "src\eShopLite.Store\wwwroot\lib\bootstrap\js\bootstrap.bundle.min.js"
Test-Path "src\eShopLite.Store\wwwroot\css\site.css"

# If missing, re-run libman restore
cd src\eShopLite.Store
libman restore
```

### Issue: Database Not Found

**Symptom**: SQLite database errors

**Fix**:
```powershell
# Check database exists
Test-Path "src\eShopLite.Store\eShopLite.db"

# If not, copy from old project
Copy-Item "src\eShopLite.StoreFx\eShopLite.db" "src\eShopLite.Store\eShopLite.db"

# Or update connection string to point to old location
```

### Issue: Layout Looks Different

**Symptom**: Styling doesn't match original

**Fix**:
1. **Compare App.razor**: Ensure CSS links identical
2. **Compare site.css**: Use file comparison tool
3. **Check browser cache**: Hard refresh (Ctrl+Shift+R)
4. **Verify libman**: Compare libman.json files
5. **Check console**: Look for CSS loading errors (F12)

### Issue: JavaScript Not Working

**Symptom**: Navbar toggle doesn't work

**Fix**:
1. **Check Bootstrap JS loaded**: F12 → Network → bootstrap.bundle.min.js
2. **Check console errors**: F12 → Console
3. **Verify App.razor**: Bootstrap JS script tag present
4. **Clear cache**: Ctrl+Shift+R

---

## 📊 Migration Comparison

### Before: eShopLite.StoreFx

```
Project: eShopLite.StoreFx
Path: src\eShopLite.StoreFx\
Namespace: eShopLite.StoreFx
Assembly: eShopLite.StoreFx.dll
Database: src\eShopLite.StoreFx\eShopLite.db
```

### After: eShopLite.Store

```
Project: eShopLite.Store
Path: src\eShopLite.Store\
Namespace: eShopLite.Store
Assembly: eShopLite.Store.dll
Database: src\eShopLite.Store\eShopLite.db (or shared)
```

### What Changed

| Aspect | Changed |
|--------|---------|
| Project Name | ✅ Yes |
| Directory Name | ✅ Yes |
| Namespace | ✅ Yes |
| Assembly Name | ✅ Yes |
| **Layout** | ❌ **No - Preserved** |
| **CSS Styles** | ❌ **No - Preserved** |
| **JavaScript** | ❌ **No - Preserved** |
| **Functionality** | ❌ **No - Preserved** |
| **Database Schema** | ❌ **No - Preserved** |

---

## 🎯 Success Criteria

Migration is successful when:

1. ✅ **Project builds** without errors
2. ✅ **Application runs** without errors
3. ✅ **All pages load** and display correctly
4. ✅ **Layout is identical** to original (compare screenshots)
5. ✅ **CSS styling is identical** to original
6. ✅ **JavaScript works** (navbar toggle, etc.)
7. ✅ **Database operations** work correctly
8. ✅ **No console errors** (F12 → Console clean)
9. ✅ **All static files load** (F12 → Network → All 200 OK)
10. ✅ **Visual comparison passes** (side-by-side with original)

---

## 📝 Rollback Plan

If migration fails:

```powershell
# 1. Stop new application
# 2. Restore from backup
Remove-Item -Path "src\eShopLite.Store" -Recurse -Force
Copy-Item -Path "src\eShopLite.StoreFx.backup" -Destination "src\eShopLite.StoreFx" -Recurse

# 3. Or revert Git
git reset --hard HEAD~1

# 4. Rebuild original
dotnet build src\eShopLite.StoreFx\eShopLite.StoreFx.csproj
dotnet run --project src\eShopLite.StoreFx\eShopLite.StoreFx.csproj
```

---

## 📚 Reference Files

**Files that MUST NOT change**:
- `Components/App.razor` - CSS/JS references
- `Components/Layout/MainLayout.razor` - Layout structure
- `wwwroot/css/site.css` - Custom styles
- `wwwroot/lib/` - All library files
- `libman.json` - Library configuration
- All `.razor` page component layouts

**Files that WILL change**:
- All namespaces (`using eShopLite.Store`)
- `.csproj` file (project name, assembly name)
- `Program.cs` (log messages with project name)
- `launchSettings.json` (profile names)

---

## ⏱️ Estimated Timeline

- **Phase 1** (Project Structure): 10 minutes
- **Phase 2** (Namespaces): 15 minutes
- **Phase 3** (Verify Styling): 10 minutes
- **Phase 4** (Solution Update): 5 minutes
- **Phase 5** (Database): 5 minutes
- **Phase 6** (Build & Test): 20 minutes
- **Phase 7** (Configuration): 10 minutes
- **Phase 8** (Git): 10 minutes
- **Phase 9** (Documentation): 10 minutes

**Total: ~1.5 hours** (including thorough testing)

---

## 🚀 Ready to Start?

Execute migration steps in order. After each phase, verify everything still works before proceeding to the next phase.

**Remember**: The goal is to change only the project name and namespaces while preserving all styling, layout, and functionality.
