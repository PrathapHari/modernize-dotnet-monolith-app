# 🔧 Static Files Troubleshooting - Complete Guide

## Current Issue
CSS and JavaScript files are not loading properly, causing pages to display without styling.

## 📋 Step-by-Step Diagnosis

### Step 1: Access Diagnostic HTML Page
**This tests if static files work outside of Blazor**

1. **Stop your application** if it's running
2. **Restart the application**
3. Open browser and navigate to: `http://localhost:[YOUR_PORT]/diagnostics.html`

**Expected Results:**
- ✅ Page displays with Bootstrap styling (cards, buttons, colors)
- ✅ Icons display correctly
- ✅ Test results show all files loaded successfully
- ✅ Console shows no 404 errors

**If diagnostics.html works:** Static files are fine, issue is with Blazor rendering  
**If diagnostics.html fails:** Static files middleware or file structure issue

---

### Step 2: Check Browser Console
Press **F12** → Go to **Console** tab

**Look for:**
```
=== CSS Load Diagnostics ===
✅ Bootstrap CSS: Loaded successfully (X rules)
✅ Bootstrap Icons: Loaded successfully (X rules)
✅ Site CSS: Loaded successfully (X rules)

=== JS Load Diagnostics ===
✅ Bootstrap JS: Loaded successfully
✅ Bootstrap CSS is ACTIVE and working
```

**If you see ❌ errors:** Note which files are failing

---

### Step 3: Check Network Tab
Press **F12** → Go to **Network** tab

1. **Reload the page** (Ctrl+R or F5)
2. **Filter by:** CSS, JS
3. **Check status codes:**
   - ✅ `200 OK` = File loaded successfully
   - ❌ `404 Not Found` = File missing or wrong path
   - ❌ `403 Forbidden` = Permission issue
   - ❌ `500 Server Error` = Server configuration issue

**Look for these specific files:**
```
/lib/bootstrap/css/bootstrap.min.css          → Should be 200 OK
/lib/bootstrap-icons/font/bootstrap-icons.min.css → Should be 200 OK
/css/site.css                                   → Should be 200 OK
/lib/bootstrap/js/bootstrap.bundle.min.js      → Should be 200 OK
```

---

### Step 4: Test Individual Files
Try accessing each file directly in your browser:

```
http://localhost:[PORT]/lib/bootstrap/css/bootstrap.min.css
http://localhost:[PORT]/lib/bootstrap-icons/font/bootstrap-icons.min.css
http://localhost:[PORT]/css/site.css
http://localhost:[PORT]/lib/bootstrap/js/bootstrap.bundle.min.js
```

**Expected:** Each URL should download or display the file content  
**If 404:** File doesn't exist or wrong path

---

### Step 5: Check Application Output Console
In **Visual Studio Output Window**, look for:

```
Static files middleware configured with caching
Web Root: C:\...\wwwroot
```

**Verify:**
- Web Root path is correct
- No errors about static files
- Files are being served (if debug logging enabled)

---

## 🔍 Common Issues and Fixes

### Issue 1: Files Return 404 Not Found

**Cause:** Files not in correct location

**Fix:**
```powershell
# Run from project directory
cd src\eShopLite.StoreFx
libman restore
```

**Verify files exist:**
```powershell
Test-Path wwwroot\lib\bootstrap\css\bootstrap.min.css
Test-Path wwwroot\lib\bootstrap\js\bootstrap.bundle.min.js
Test-Path wwwroot\lib\bootstrap-icons\font\bootstrap-icons.min.css
Test-Path wwwroot\css\site.css
```

All should return `True`

---

### Issue 2: Blazor Page Loads but No Styling

**Symptoms:**
- diagnostics.html works fine
- Blazor pages display but look unstyled
- Console shows files loaded

**Possible Causes:**
1. **Blazor hydration issue** - Styles removed during rehydration
2. **Base href incorrect** - Paths resolve wrong
3. **CSP (Content Security Policy)** - Blocks inline styles

**Fix A: Check base href**
In `App.razor`, verify:
```html
<base href="/" />
```

**Fix B: Clear browser cache**
```
Ctrl + Shift + Delete → Clear cache
Or
Ctrl + Shift + R → Hard refresh
```

**Fix C: Check for JavaScript errors**
Console errors might be blocking Bootstrap JS from initializing

---

### Issue 3: Icons Don't Display

**Symptoms:**
- CSS loads
- Bootstrap styling works
- Icons show as boxes or missing

**Cause:** Font files not loading

**Check:**
1. Open **Network tab** → Filter by **Font**
2. Look for: `bootstrap-icons.woff2` or `bootstrap-icons.woff`
3. Should be **200 OK**

**Fix:**
```powershell
# Verify font files exist
Test-Path wwwroot\lib\bootstrap-icons\font\fonts\bootstrap-icons.woff2
Test-Path wwwroot\lib\bootstrap-icons\font\fonts\bootstrap-icons.woff
```

If missing, restore:
```powershell
cd src\eShopLite.StoreFx
libman restore
```

---

### Issue 4: CSS Loads on First Visit, Then Fails

**Cause:** Aggressive browser caching or cache corruption

**Fix:**
1. **Clear browser cache** completely
2. **Disable cache in DevTools:** F12 → Network tab → Check "Disable cache"
3. **Hard refresh:** Ctrl + Shift + R

---

### Issue 5: Works in Development, Fails in Production

**Cause:** Different static files configuration

**Check:**
1. Verify `wwwroot` folder is deployed
2. Check `appsettings.Production.json` for static files config
3. Verify IIS/web server serves static files

---

### Issue 6: Mixed Content Errors (HTTP/HTTPS)

**Symptoms:**
- Console shows "Mixed Content" warnings
- Some files blocked

**Cause:** Page loaded via HTTPS but files requested via HTTP

**Fix:**
Ensure all paths are relative (starting with `/`):
```html
<!-- ✅ Correct -->
<link rel="stylesheet" href="/lib/bootstrap/css/bootstrap.min.css" />

<!-- ❌ Wrong -->
<link rel="stylesheet" href="http://localhost/lib/bootstrap/css/bootstrap.min.css" />
```

---

## 🛠️ Manual Verification Commands

Run these in PowerShell from project directory:

```powershell
# 1. Check if wwwroot exists
Test-Path src\eShopLite.StoreFx\wwwroot

# 2. List all files in wwwroot
Get-ChildItem src\eShopLite.StoreFx\wwwroot -Recurse -File

# 3. Check Bootstrap files specifically
Test-Path src\eShopLite.StoreFx\wwwroot\lib\bootstrap\css\bootstrap.min.css
Test-Path src\eShopLite.StoreFx\wwwroot\lib\bootstrap\js\bootstrap.bundle.min.js

# 4. Check Bootstrap Icons files
Test-Path src\eShopLite.StoreFx\wwwroot\lib\bootstrap-icons\font\bootstrap-icons.min.css
Test-Path src\eShopLite.StoreFx\wwwroot\lib\bootstrap-icons\font\fonts\bootstrap-icons.woff2

# 5. Check site.css
Test-Path src\eShopLite.StoreFx\wwwroot\css\site.css

# 6. Restore libman packages
cd src\eShopLite.StoreFx
libman restore

# 7. Clean and rebuild
dotnet clean
dotnet build

# 8. Check csproj file includes wwwroot
Get-Content src\eShopLite.StoreFx\eShopLite.StoreFx.csproj | Select-String -Pattern "wwwroot"
```

---

## 📊 Expected File Structure

Your `wwwroot` folder should look exactly like this:

```
wwwroot/
├── css/
│   └── site.css
├── lib/
│   ├── bootstrap/
│   │   ├── css/
│   │   │   ├── bootstrap.min.css
│   │   │   └── bootstrap.min.css.map
│   │   └── js/
│   │       ├── bootstrap.bundle.min.js
│   │       └── bootstrap.bundle.min.js.map
│   ├── bootstrap-icons/
│   │   └── font/
│   │       ├── bootstrap-icons.css
│   │       ├── bootstrap-icons.min.css
│   │       └── fonts/
│   │           ├── bootstrap-icons.woff
│   │           └── bootstrap-icons.woff2
│   └── jquery/
│       ├── jquery.min.js
│       └── jquery.min.map
├── images/
│   ├── product1.png
│   ├── product2.png
│   └── ...
└── diagnostics.html  ← NEW test file
```

---

## 🔥 Nuclear Options (If Nothing Else Works)

### Option 1: Complete Clean and Restore

```powershell
cd src\eShopLite.StoreFx

# 1. Remove all lib files
Remove-Item wwwroot\lib\* -Recurse -Force

# 2. Restore from libman
libman restore

# 3. Clean solution
dotnet clean

# 4. Rebuild
dotnet build

# 5. Restart application
```

### Option 2: Verify .csproj Configuration

Check `eShopLite.StoreFx.csproj` contains:

```xml
<ItemGroup>
  <Content Include="wwwroot\**" CopyToOutputDirectory="PreserveNewest" />
</ItemGroup>
```

If missing, add it and rebuild.

### Option 3: Check for Antivirus/Firewall Blocking

Some antivirus software blocks local file serving:
1. Temporarily disable antivirus
2. Test if files load
3. Add Visual Studio/application to whitelist

---

## ✅ Success Criteria

When everything works correctly, you should see:

**Browser:**
- ✅ Styled navbar with proper spacing
- ✅ Product cards with borders, shadows, hover effects
- ✅ Icons displaying correctly
- ✅ Buttons with Bootstrap colors
- ✅ Responsive layout works

**Console (F12):**
```
✅ Bootstrap CSS: Loaded successfully (5000+ rules)
✅ Bootstrap Icons: Loaded successfully
✅ Site CSS: Loaded successfully
✅ Bootstrap JS: Loaded successfully
✅ Bootstrap CSS is ACTIVE and working
```

**Network Tab:**
```
bootstrap.min.css          200 OK  232 KB
bootstrap-icons.min.css    200 OK   85 KB
site.css                   200 OK    3 KB
bootstrap.bundle.min.js    200 OK   80 KB
bootstrap-icons.woff2      200 OK  130 KB
```

---

## 📞 Still Not Working?

If you've tried everything and it still doesn't work, provide:

1. **Browser Console Output** (full text from F12 Console)
2. **Network Tab Screenshot** showing status codes
3. **Application Output Console** (from Visual Studio)
4. **Results from diagnostics.html** test page
5. **PowerShell verification commands** output

This will help identify the specific issue!

---

## 🎯 Quick Checklist

- [ ] Run `libman restore` in project directory
- [ ] Verify files exist with `Test-Path` commands
- [ ] Access `/diagnostics.html` to test static files
- [ ] Check browser Console (F12) for errors
- [ ] Check Network tab for 404 errors
- [ ] Try hard refresh (Ctrl + Shift + R)
- [ ] Clear browser cache completely
- [ ] Restart application after changes
- [ ] Test individual file URLs in browser
- [ ] Check Visual Studio Output for errors
