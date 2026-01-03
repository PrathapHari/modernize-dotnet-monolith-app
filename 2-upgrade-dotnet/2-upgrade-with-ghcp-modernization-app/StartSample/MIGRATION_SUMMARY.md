# eShopLite Migration: StoreFx → Store

## 📋 Quick Start Guide

### Option 1: Automated Migration (Recommended)

```powershell
# Navigate to workspace root
cd "C:\Users\prath\OneDrive\Documents\GitHub Copilot\Source\2-upgrade-dotnet\2-upgrade-with-ghcp-modernization-app\StartSample"

# Run migration script (dry run first)
.\Migrate-eShopLite.ps1 -WhatIf

# If dry run looks good, run actual migration
.\Migrate-eShopLite.ps1

# Follow prompts and verify at each step
```

### Option 2: Manual Migration

Follow the detailed guide in: **`MIGRATION_PLAN_STOREFX_TO_STORE.md`**

---

## 🎯 Migration Goals

✅ **Rename project**: `eShopLite.StoreFx` → `eShopLite.Store`  
✅ **Update namespaces**: `eShopLite.StoreFx` → `eShopLite.Store`  
❌ **No layout changes**: MainLayout.razor stays identical  
❌ **No CSS changes**: site.css and Bootstrap CSS stay identical  
❌ **No JS changes**: Bootstrap JS stays identical  
❌ **No functionality changes**: All features work the same  

---

## 📚 Documentation Files Created

### 1. Migration Plan
**File**: `MIGRATION_PLAN_STOREFX_TO_STORE.md`

**Contents**:
- 9 phases of migration
- Step-by-step instructions
- Verification checklists
- Troubleshooting guide
- Rollback procedures

### 2. Migration Script
**File**: `Migrate-eShopLite.ps1`

**Features**:
- Automated backup
- File copying with exclusions
- Namespace updates
- Package restoration
- Build verification
- Solution file updates

**Usage**:
```powershell
# Dry run (no changes)
.\Migrate-eShopLite.ps1 -WhatIf

# Full migration with backup
.\Migrate-eShopLite.ps1

# Skip backup (if already backed up)
.\Migrate-eShopLite.ps1 -SkipBackup

# Keep old project after migration
.\Migrate-eShopLite.ps1 -KeepOldProject
```

---

## 🔍 What Will Change

### File/Directory Names
```
Before: src\eShopLite.StoreFx\
After:  src\eShopLite.Store\

Before: eShopLite.StoreFx.csproj
After:  eShopLite.Store.csproj

Before: eShopLite.StoreFx.dll
After:  eShopLite.Store.dll
```

### Namespaces
```csharp
// Before
namespace eShopLite.StoreFx.Models;
using eShopLite.StoreFx.Services;

// After
namespace eShopLite.Store.Models;
using eShopLite.Store.Services;
```

### Assembly Names
```xml
<!-- Before -->
<AssemblyName>eShopLite.StoreFx</AssemblyName>
<RootNamespace>eShopLite.StoreFx</RootNamespace>

<!-- After -->
<AssemblyName>eShopLite.Store</AssemblyName>
<RootNamespace>eShopLite.Store</RootNamespace>
```

---

## 🚫 What Will NOT Change

### Layout Files (Exact Copy)
- ✅ `Components/App.razor` - Same CSS/JS references
- ✅ `Components/Layout/MainLayout.razor` - Same structure
- ✅ `Components/Pages/*.razor` - Same page layouts

### Styling Files (Exact Copy)
- ✅ `wwwroot/css/site.css` - All custom styles preserved
- ✅ `wwwroot/lib/bootstrap/css/bootstrap.min.css` - Same version
- ✅ `libman.json` - Same library configuration

### JavaScript Files (Exact Copy)
- ✅ `wwwroot/lib/bootstrap/js/bootstrap.bundle.min.js` - Same version
- ✅ All JavaScript interactions preserved

### Functionality
- ✅ All pages work the same
- ✅ Database operations identical
- ✅ Navigation unchanged
- ✅ Forms behave the same

---

## ✅ Pre-Migration Checklist

Before starting migration:

- [ ] **Backup created**: Run script with `-WhatIf` first
- [ ] **Git committed**: Commit current state to Git
- [ ] **Screenshots taken**: Capture all pages for comparison
- [ ] **Build successful**: Current project builds without errors
- [ ] **Application runs**: Current app starts and works
- [ ] **Dependencies verified**: All NuGet packages restored

---

## 🎬 Migration Process

### Phase 1: Preparation (5 min)
1. Create backup of current project
2. Commit to Git
3. Take screenshots

### Phase 2: Project Copy (10 min)
1. Create new directory structure
2. Copy all files (excluding obj/bin)
3. Rename .csproj file

### Phase 3: Namespace Updates (15 min)
1. Update all `.cs` files
2. Update all `.razor` files
3. Update `.csproj` file
4. Verify with search

### Phase 4: Build & Test (20 min)
1. Restore NuGet packages
2. Restore LibMan packages
3. Build project
4. Run application
5. Test all pages

### Phase 5: Verification (15 min)
1. Compare with screenshots
2. Check browser console (F12)
3. Test navbar toggle
4. Verify database operations

**Total Time**: ~1-1.5 hours

---

## 🧪 Testing Checklist

### Functionality Tests
- [ ] Home page loads
- [ ] Products page displays card grid
- [ ] Stores page displays cards with icons
- [ ] Database Status page shows data
- [ ] Navigation menu works
- [ ] Error page handles 404s

### Styling Tests
- [ ] Bootstrap CSS loaded (F12 → Network)
- [ ] Bootstrap Icons display correctly
- [ ] Custom site.css styles applied
- [ ] Layout matches original (compare screenshots)
- [ ] Responsive design works (test mobile view)
- [ ] Colors/fonts match original

### JavaScript Tests
- [ ] Bootstrap JS loaded (F12 → Network)
- [ ] Navbar toggle works (mobile view)
- [ ] No console errors (F12 → Console)
- [ ] All JavaScript interactions work

### Performance Tests
- [ ] Page load time similar
- [ ] No new warnings
- [ ] Database queries perform the same

---

## 🐛 Common Issues & Solutions

### Issue: Build Errors

**Symptom**: Namespace not found errors

**Solution**:
```powershell
# Find remaining old namespace references
Get-ChildItem -Path "src\eShopLite.Store" -Include *.cs,*.razor -Recurse | 
    Select-String "eShopLite.StoreFx"
```

### Issue: Static Files 404

**Symptom**: CSS/JS not loading

**Solution**:
```powershell
# Re-run libman restore
cd src\eShopLite.Store
libman restore

# Verify files exist
Test-Path wwwroot\lib\bootstrap\css\bootstrap.min.css
Test-Path wwwroot\lib\bootstrap\js\bootstrap.bundle.min.js
```

### Issue: Layout Looks Different

**Symptom**: Styling doesn't match

**Solution**:
1. Compare `App.razor` files
2. Compare `site.css` files
3. Hard refresh browser (Ctrl+Shift+R)
4. Check F12 Console for errors

### Issue: Database Not Found

**Symptom**: SQLite errors

**Solution**:
```powershell
# Copy database from old project
Copy-Item "src\eShopLite.StoreFx\eShopLite.db" "src\eShopLite.Store\eShopLite.db"

# Or update connection string to use shared database
```

---

## 🔄 Rollback Procedure

If migration fails:

```powershell
# Option 1: Remove new project and restore backup
Remove-Item -Path "src\eShopLite.Store" -Recurse -Force
Copy-Item -Path "src\eShopLite.StoreFx.backup" -Destination "src\eShopLite.StoreFx" -Recurse

# Option 2: Git reset
git reset --hard HEAD~1

# Rebuild original project
dotnet build src\eShopLite.StoreFx\eShopLite.StoreFx.csproj
```

---

## 📊 Migration Comparison Matrix

| Aspect | Before | After | Changed? |
|--------|--------|-------|----------|
| **Project Name** | eShopLite.StoreFx | eShopLite.Store | ✅ Yes |
| **Namespace** | eShopLite.StoreFx | eShopLite.Store | ✅ Yes |
| **Directory** | src\eShopLite.StoreFx | src\eShopLite.Store | ✅ Yes |
| **Layout** | MainLayout.razor | MainLayout.razor | ❌ No |
| **Root Component** | App.razor | App.razor | ❌ No |
| **CSS Files** | site.css, Bootstrap | site.css, Bootstrap | ❌ No |
| **JavaScript** | Bootstrap bundle | Bootstrap bundle | ❌ No |
| **Pages** | Home, Products, Stores | Home, Products, Stores | ❌ No |
| **Models** | Product, StoreInfo | Product, StoreInfo | ❌ No |
| **Services** | ProductService, StoreService | ProductService, StoreService | ❌ No |
| **Database** | SQLite (eShopLite.db) | SQLite (eShopLite.db) | ❌ No |
| **Functionality** | All features | All features | ❌ No |

---

## 🎯 Success Criteria

Migration is successful when ALL of these are true:

### Build & Run
- ✅ Project builds without errors
- ✅ No warnings related to namespaces
- ✅ Application starts successfully
- ✅ No startup errors in console

### Visual Comparison
- ✅ Layout looks identical to original
- ✅ All pages render correctly
- ✅ Styling matches original (compare screenshots)
- ✅ Responsive design works

### Functionality
- ✅ All pages load and display data
- ✅ Navigation works
- ✅ Database operations work
- ✅ Forms work (if any)

### Browser Console
- ✅ No JavaScript errors (F12 → Console)
- ✅ All CSS files load (200 OK)
- ✅ All JS files load (200 OK)
- ✅ No 404 errors

### Interactive Features
- ✅ Navbar toggle works on mobile
- ✅ Bootstrap JavaScript functions work
- ✅ All clicks and interactions work

---

## 📁 File Structure Comparison

### Before: eShopLite.StoreFx
```
src\eShopLite.StoreFx\
├── Components\
│   ├── App.razor                          ← Root component
│   ├── Routes.razor
│   ├── Layout\
│   │   └── MainLayout.razor               ← Layout component
│   ├── Pages\
│   │   ├── Home.razor
│   │   ├── Products.razor
│   │   ├── Stores.razor
│   │   ├── DatabaseStatus.razor
│   │   └── Error.razor
│   └── _Imports.razor
├── Data\
│   └── StoreDbContext.cs
├── Models\
│   ├── Product.cs
│   └── StoreInfo.cs
├── Services\
│   ├── ProductService.cs
│   └── StoreService.cs
├── wwwroot\
│   ├── css\
│   │   └── site.css                       ← Custom styles
│   ├── lib\
│   │   ├── bootstrap\                     ← Bootstrap files
│   │   ├── bootstrap-icons\               ← Icon fonts
│   │   └── jquery\
│   └── images\                             ← Product images
├── Program.cs
├── appsettings.json
├── libman.json                             ← Client library config
└── eShopLite.StoreFx.csproj
```

### After: eShopLite.Store
```
src\eShopLite.Store\
├── Components\
│   ├── App.razor                          ← SAME
│   ├── Routes.razor                       ← SAME
│   ├── Layout\
│   │   └── MainLayout.razor               ← SAME
│   ├── Pages\
│   │   ├── Home.razor                     ← SAME
│   │   ├── Products.razor                 ← SAME
│   │   ├── Stores.razor                   ← SAME
│   │   ├── DatabaseStatus.razor           ← SAME
│   │   └── Error.razor                    ← SAME
│   └── _Imports.razor                     ← Updated namespace
├── Data\
│   └── StoreDbContext.cs                  ← Updated namespace
├── Models\
│   ├── Product.cs                         ← Updated namespace
│   └── StoreInfo.cs                       ← Updated namespace
├── Services\
│   ├── ProductService.cs                  ← Updated namespace
│   └── StoreService.cs                    ← Updated namespace
├── wwwroot\
│   ├── css\
│   │   └── site.css                       ← EXACT COPY
│   ├── lib\
│   │   ├── bootstrap\                     ← EXACT COPY
│   │   ├── bootstrap-icons\               ← EXACT COPY
│   │   └── jquery\                        ← EXACT COPY
│   └── images\                             ← EXACT COPY
├── Program.cs                              ← Updated namespace
├── appsettings.json                        ← SAME
├── libman.json                             ← SAME
└── eShopLite.Store.csproj                 ← Updated project name
```

---

## 🚀 Post-Migration Tasks

### Immediate Tasks (Do Right After Migration)

1. **Test Application Thoroughly**
   ```powershell
   dotnet run --project src\eShopLite.Store\eShopLite.Store.csproj
   ```

2. **Compare with Screenshots**
   - Open original screenshots
   - Navigate to each page in new app
   - Verify they look identical

3. **Check Browser Console**
   - Press F12
   - Verify no errors in Console tab
   - Check Network tab - all files 200 OK

4. **Test All Features**
   - Navigate to all pages
   - Test database operations
   - Test responsive design (mobile view)
   - Test navbar toggle

### Update Documentation

1. **Update README.md**
   - Replace `eShopLite.StoreFx` with `eShopLite.Store`

2. **Update MCP Configuration**
   - Update database path in `eShopLite-mcp-config.json`:
     ```json
     {
       "sqlite": {
         "configuration": {
           "databasePath": "./src/eShopLite.Store/eShopLite.db"
         }
       }
     }
     ```

3. **Update Architecture Docs**
   - Update any architecture diagrams
   - Update project references

### Git Commit

```powershell
# Stage new project
git add src\eShopLite.Store

# Commit
git commit -m "Migrate eShopLite.StoreFx to eShopLite.Store

- Renamed project from eShopLite.StoreFx to eShopLite.Store
- Updated all namespaces
- Preserved layout, CSS, and JavaScript unchanged
- All functionality preserved
- Build and tests passing"

# Optional: Remove old project
git rm -r src\eShopLite.StoreFx
git commit -m "Remove old eShopLite.StoreFx project after migration"
```

---

## 📞 Need Help?

### If Migration Fails

1. **Check the logs**: Look at script output for errors
2. **Review the checklist**: Ensure all steps completed
3. **Use rollback**: Restore from backup
4. **Consult troubleshooting**: See Common Issues section

### If Application Doesn't Look Right

1. **Compare files**: Use file comparison tool
2. **Check browser cache**: Hard refresh (Ctrl+Shift+R)
3. **Verify static files**: Check F12 → Network tab
4. **Compare with backup**: Open backup in parallel

### If Functionality is Broken

1. **Check namespaces**: Search for old namespace
2. **Rebuild clean**: `dotnet clean && dotnet build`
3. **Check database**: Verify database exists and has data
4. **Review console**: Look for errors in Output window

---

## 🎓 Lessons Learned

### What Worked Well

✅ Automated namespace updates via PowerShell  
✅ Preserving wwwroot directory exactly  
✅ Creating backup before migration  
✅ Testing with WhatIf mode first  
✅ Step-by-step verification  

### What to Watch Out For

⚠️ Case sensitivity in paths (use consistent casing)  
⚠️ Build artifacts (exclude obj/bin directories)  
⚠️ Git line endings (ensure consistent CRLF/LF)  
⚠️ Database path references (update if needed)  
⚠️ Browser cache (clear after migration)  

---

## 📝 Summary

**Migration Type**: Project Rename  
**Scope**: Name and namespace only  
**Preserved**: Layout, CSS, JS, functionality  
**Risk Level**: Low (with backup)  
**Time Required**: 1-1.5 hours  
**Rollback**: Easy (restore from backup)  

**Status**: ✅ Ready to Execute  

---

## 🎯 Final Checklist

Before proceeding:

- [ ] Read complete migration plan
- [ ] Understand what will change
- [ ] Understand what will NOT change
- [ ] Have backup strategy ready
- [ ] Have 1-2 hours available
- [ ] Application currently working
- [ ] Git repository clean
- [ ] Ready to test thoroughly

**Ready? Execute migration using one of the methods above!** 🚀
