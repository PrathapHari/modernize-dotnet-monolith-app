# Quick Start: Fix DirectoryNotFoundException

## Steps to Fix the Issue

### 1. Run the Migration Script
Double-click on **`MigrateToWwwroot.bat`** in the `src\eShopLite.StoreFx` directory.

This will:
- Create the `wwwroot` directory structure
- Move all static files from `Content`, `Scripts`, and `Images` folders
- Clean up empty directories

### 2. Files Already Updated
? `Views\Shared\_Layout.cshtml` - Updated to use new paths

### 3. Verify Your Other Views
The following files already use correct paths:
? `Views\Home\Products.cshtml` - Uses `~/images/` ?
? `Views\Home\Index.cshtml` - No static content references ?
? `Views\Home\Stores.cshtml` - Check if needed

### 4. Build and Run
1. **Clean the solution**: Build ? Clean Solution
2. **Rebuild**: Build ? Rebuild Solution
3. **Run the application**: Press F5

### 5. Expected Result
? No DirectoryNotFoundException
? Application starts successfully
? Static files (CSS, JS, images) load correctly

## Verification Checklist

After running the migration:

- [ ] `wwwroot` directory exists
- [ ] `wwwroot\css` contains Bootstrap and Site.css files
- [ ] `wwwroot\js` contains jQuery and Bootstrap scripts
- [ ] `wwwroot\images` contains product images (product1.png through product9.png)
- [ ] `wwwroot\favicon.ico` exists
- [ ] Old `Content`, `Scripts`, `Images` folders are removed or empty
- [ ] Application builds without errors
- [ ] Application runs without DirectoryNotFoundException
- [ ] Website displays with proper styling
- [ ] Product images display correctly

## Troubleshooting

**If you get execution policy errors with PowerShell:**
```powershell
# Run this in PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**If static files don't load after migration:**
1. Check browser DevTools (F12) ? Network tab for 404 errors
2. Verify file paths in the view files
3. Clear browser cache (Ctrl+Shift+Delete)
4. Ensure `app.UseStaticFiles()` is in Program.cs (already present ?)

**If you need to revert:**
The script moves files, so you may want to commit your changes to git before running it.

## Next Steps After Success

Consider these improvements:
1. Remove old `App_Start` folder files (BundleConfig.cs, etc.) - no longer needed
2. Remove `Global.asax` and `Global.asax.cs` - not used in ASP.NET Core
3. Update the project file to modern SDK-style format
4. Consider using LibMan for client-side package management

## Questions?
See `MIGRATION_GUIDE.md` for detailed information about the migration process.
