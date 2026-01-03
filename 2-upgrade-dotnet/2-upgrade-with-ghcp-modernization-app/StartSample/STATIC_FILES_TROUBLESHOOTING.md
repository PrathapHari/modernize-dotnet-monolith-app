# Static Files Troubleshooting Guide

## Current Issue
CSS and JavaScript files are not loading in the Blazor application, causing:
- Misaligned menu items
- Products displayed as plain list (no styling)
- Missing Bootstrap functionality

## Fixes Applied

### 1. Enhanced Static Files Configuration (`Program.cs`)
Added proper caching headers and debug logging to the static files middleware:
```csharp
var staticFileOptions = new StaticFileOptions
{
    OnPrepareResponse = ctx =>
    {
        // Cache headers for performance
        const int durationInSeconds = 60 * 60 * 24 * 30; // 30 days
        ctx.Context.Response.Headers.Append("Cache-Control", $"public,max-age={durationInSeconds}");
        
        // Debug logging
        if (app.Environment.IsDevelopment())
        {
            logger.LogDebug("Serving static file: {Path}", ctx.Context.Request.Path);
        }
    }
};
app.UseStaticFiles(staticFileOptions);
```

### 2. Diagnostic Features Added

#### Diagnostic Endpoint (Development Only)
Access: `http://localhost:[port]/api/diagnostics/static-files`
- Lists all files in wwwroot
- Shows the physical wwwroot path
- Helps verify file structure

#### Browser Console Diagnostics
The `App.razor` now includes scripts that log:
- Which CSS files are loaded
- Whether Bootstrap CSS loaded successfully
- The base URL being used

### 3. Updated File Paths
All static file references now use absolute paths starting with `/`:
- `/lib/bootstrap/css/bootstrap.min.css` ✅
- `/css/site.css` ✅
- `/lib/bootstrap/js/bootstrap.bundle.min.js` ✅

## Verification Steps

### Step 1: Stop and Restart the Application
The changes require a full restart (Hot Reload may not apply middleware changes):
1. Stop the debugger
2. Clean the solution (optional but recommended)
3. Rebuild the solution
4. Start debugging again

### Step 2: Check Browser Developer Console
Press F12 and check:
1. **Console tab**: Look for the diagnostic messages
   - Should see: "App.razor loaded"
   - Should see CSS links with their load status
2. **Network tab**: Check for 404 errors
   - Filter by CSS and JS files
   - Verify all files return 200 OK status

### Step 3: Test Static Files Directly
Try accessing these URLs directly in your browser:
- `http://localhost:[port]/lib/bootstrap/css/bootstrap.min.css`
- `http://localhost:[port]/css/site.css`
- `http://localhost:[port]/lib/bootstrap/js/bootstrap.bundle.min.js`

Each should download or display the file content.

### Step 4: Check Diagnostic Endpoint
Visit: `http://localhost:[port]/api/diagnostics/static-files`
This will show:
- Physical wwwroot path
- Number of files found
- List of available files

### Step 5: Verify Application Logs
Check the console output for:
```
Static files middleware configured with caching
```

## Common Issues and Solutions

### Issue 1: Files Not Found (404)
**Symptoms**: Network tab shows 404 for CSS/JS files
**Solution**: 
1. Verify files exist in `wwwroot/lib/bootstrap/` and `wwwroot/css/`
2. Check file permissions
3. Ensure libman has restored files: Run `libman restore` in terminal

### Issue 2: MIME Type Issues
**Symptoms**: Files load but browser won't apply them
**Solution**: Already handled by ASP.NET Core's static files middleware

### Issue 3: Browser Caching Old Files
**Symptoms**: Changes not reflected after restart
**Solution**: Hard refresh browser (Ctrl+Shift+R or Ctrl+F5)

### Issue 4: Path Case Sensitivity
**Symptoms**: Files load on Windows but not on Linux
**Solution**: Ensure paths match exact case in `App.razor`

## File Structure Verification

Your wwwroot should look like this:
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
│   └── jquery/
│       ├── jquery.min.js
│       └── jquery.min.map
└── images/
    ├── product1.png
    ├── product2.png
    └── ...
```

## Next Steps if Still Not Working

1. **Check the Output Console**: Look for any errors during static file serving
2. **Clear Browser Cache**: Sometimes aggressive caching causes issues
3. **Check Firewall/Antivirus**: May block local file serving
4. **Try Different Browser**: Rule out browser-specific issues
5. **Check appsettings.json**: Ensure no conflicting configurations

## Manual Testing Commands

Run these in PowerShell from the project directory:

```powershell
# Verify files exist
Test-Path src\eShopLite.StoreFx\wwwroot\lib\bootstrap\css\bootstrap.min.css
Test-Path src\eShopLite.StoreFx\wwwroot\lib\bootstrap\js\bootstrap.bundle.min.js
Test-Path src\eShopLite.StoreFx\wwwroot\css\site.css

# Restore libman packages
cd src\eShopLite.StoreFx
libman restore

# Clean and rebuild
dotnet clean
dotnet build
```

## Expected Behavior After Fix

✅ Navbar should display properly with:
- Logo on the left
- Menu items (Products, Stores) visible
- Responsive toggle button on mobile

✅ Products page should show:
- Styled cards with borders and shadows
- Product images
- Formatted prices
- Hover effects on cards

✅ General styling should include:
- Proper spacing and padding
- Bootstrap typography
- Colored buttons
- Professional appearance

## Still Having Issues?

If after following all steps the files still don't load:
1. Share the browser console output
2. Share the Network tab screenshot showing the requests
3. Share the Output console from Visual Studio
4. Check if the app is running on the expected port
