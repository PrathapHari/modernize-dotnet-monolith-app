# Static Content Migration Guide

## Migration Completed
The static content has been moved from the old .NET Framework structure to the new ASP.NET Core wwwroot structure.

## Path Mapping Reference

### Old Paths ? New Paths
- `~/Content/` ? `~/css/`
- `~/Scripts/` ? `~/js/`
- `~/Images/` ? `~/images/`
- `~/favicon.ico` ? `~/favicon.ico`

## Files to Update

### 1. Views\Shared\_Layout.cshtml
Update all stylesheet and script references:

**Before:**
```html
<link rel="stylesheet" href="~/Content/bootstrap.min.css" />
<link rel="stylesheet" href="~/Content/Site.css" />
<script src="~/Scripts/jquery-3.7.1.min.js"></script>
<script src="~/Scripts/bootstrap.bundle.min.js"></script>
```

**After:**
```html
<link rel="stylesheet" href="~/css/bootstrap.min.css" />
<link rel="stylesheet" href="~/css/Site.css" asp-append-version="true" />
<script src="~/js/jquery-3.7.1.min.js"></script>
<script src="~/js/bootstrap.bundle.min.js"></script>
```

### 2. All View Files
Update any image references:

**Before:**
```html
<img src="~/Images/product1.png" alt="Product" />
```

**After:**
```html
<img src="~/images/product1.png" alt="Product" />
```

### 3. BundleConfig.cs (if still present)
This file is no longer needed in ASP.NET Core. Remove it and reference files directly, or use:
- LibMan (Library Manager) for client-side libraries
- Link tags with `asp-append-version="true"` for cache busting

## Search and Replace Guide

Use Visual Studio's Find and Replace (Ctrl+Shift+H) with these patterns:

1. **Replace Content paths:**
   - Find: `~/Content/`
   - Replace: `~/css/`

2. **Replace Scripts paths:**
   - Find: `~/Scripts/`
   - Replace: `~/js/`

3. **Replace Images paths:**
   - Find: `~/Images/`
   - Replace: `~/images/`

## Verification Steps

1. **Build the solution** - Ensure no compilation errors
2. **Run the application** - The DirectoryNotFoundException should be resolved
3. **Check browser console** - Verify no 404 errors for static files
4. **Test all pages** - Ensure images, styles, and scripts load correctly

## Additional Notes

- The `asp-append-version="true"` attribute adds a cache-busting query string
- Consider organizing CSS files into subdirectories (e.g., `css/lib/`, `css/site/`)
- Consider using LibMan for managing third-party libraries like Bootstrap and jQuery

## Troubleshooting

If static files aren't loading:
1. Verify files are in the correct wwwroot subdirectories
2. Check that `app.UseStaticFiles()` is called in Program.cs
3. Clear browser cache (Ctrl+Shift+Delete)
4. Check browser DevTools Network tab for 404 errors
