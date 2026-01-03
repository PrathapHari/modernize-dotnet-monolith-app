# Bootstrap Icons - Local Installation Guide

## Summary

Bootstrap Icons has been successfully configured to load from local files instead of CDN.

## Changes Made

### 1. Updated `libman.json`
Added Bootstrap Icons library to fetch from CDNJS:
```json
{
  "library": "bootstrap-icons@1.11.1",
  "destination": "wwwroot/lib/bootstrap-icons/",
  "files": [
    "font/bootstrap-icons.css",
    "font/bootstrap-icons.min.css",
    "font/fonts/bootstrap-icons.woff",
    "font/fonts/bootstrap-icons.woff2"
  ]
}
```

### 2. Updated `App.razor`
Changed from CDN to local path:
```html
<!-- Before (CDN) -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" />

<!-- After (Local) -->
<link rel="stylesheet" href="/lib/bootstrap-icons/font/bootstrap-icons.min.css" onerror="console.error('Failed to load Bootstrap Icons')" />
```

### 3. Installed LibMan CLI
```bash
dotnet tool install -g Microsoft.Web.LibraryManager.Cli
```

### 4. Restored Packages
```bash
libman restore
```

## Files Downloaded

The following files are now in `wwwroot/lib/bootstrap-icons/`:
- ✅ `font/bootstrap-icons.css` (98,255 bytes)
- ✅ `font/bootstrap-icons.min.css` (85,875 bytes)
- ✅ `font/fonts/bootstrap-icons.woff` (176,200 bytes)
- ✅ `font/fonts/bootstrap-icons.woff2` (130,608 bytes)

## Benefits of Local Hosting

### Performance
- ✅ **Faster Load Times**: No DNS lookup or external server round trip
- ✅ **Parallel Downloads**: Browser can download multiple assets from same domain
- ✅ **Better Caching**: Full control over cache policies

### Reliability
- ✅ **Offline Support**: App works without internet connection
- ✅ **No CDN Dependency**: No risk of CDN outages
- ✅ **Version Control**: Exact version guaranteed

### Security
- ✅ **No External Requests**: Better privacy for users
- ✅ **No CORS Issues**: Same-origin policy satisfied
- ✅ **Content Security Policy**: Easier to configure CSP headers

## Testing

After restarting the application, verify:

1. **Browser DevTools Network Tab**:
   - Look for `/lib/bootstrap-icons/font/bootstrap-icons.min.css`
   - Should return 200 OK status
   - Check the response is coming from localhost

2. **Icons Display**:
   - All Bootstrap Icons should render correctly
   - Check navbar, buttons, and other UI elements using icons

3. **Console Verification**:
   - Should see: `CSS link: http://localhost:[port]/lib/bootstrap-icons/font/bootstrap-icons.min.css loaded: YES`
   - No error: `Failed to load Bootstrap Icons`

## File Structure

```
wwwroot/
├── lib/
│   ├── bootstrap/
│   │   ├── css/
│   │   │   ├── bootstrap.min.css
│   │   │   └── bootstrap.min.css.map
│   │   └── js/
│   │       ├── bootstrap.bundle.min.js
│   │       └── bootstrap.bundle.min.js.map
│   ├── bootstrap-icons/          ← NEW
│   │   └── font/
│   │       ├── bootstrap-icons.css
│   │       ├── bootstrap-icons.min.css
│   │       └── fonts/
│   │           ├── bootstrap-icons.woff
│   │           └── bootstrap-icons.woff2
│   └── jquery/
│       ├── jquery.min.js
│       └── jquery.min.map
├── css/
│   └── site.css
└── images/
    └── ...
```

## Updating Bootstrap Icons

To update to a newer version in the future:

1. Edit `libman.json`:
   ```json
   {
     "library": "bootstrap-icons@1.12.0",  // Update version here
     "destination": "wwwroot/lib/bootstrap-icons/",
     ...
   }
   ```

2. Run restore:
   ```bash
   libman restore
   ```

3. Test the application to ensure icons work correctly

## LibMan Commands Reference

```bash
# Restore all libraries
libman restore

# Update all libraries to latest versions
libman update

# Clean (remove) all library files
libman clean

# List all installed libraries
libman list

# Install a new library
libman install <library-name> --provider cdnjs --destination wwwroot/lib/<library-name>
```

## Troubleshooting

### Icons Not Showing
1. Clear browser cache (Ctrl+Shift+R)
2. Verify files exist in `wwwroot/lib/bootstrap-icons/font/`
3. Check browser Network tab for 404 errors
4. Ensure `libman restore` completed successfully

### Font Files Not Loading
- The CSS file references `./fonts/bootstrap-icons.woff2`
- Ensure the `fonts` subfolder exists with the font files
- Check browser console for font loading errors

### Version Mismatch
- Always use matching versions in both CSS file and font files
- Run `libman restore` after any version changes
- Clear browser cache after updates

## Next Steps

**Restart the application** to see the changes:
1. Stop the debugger
2. Rebuild the solution
3. Start debugging
4. Open browser DevTools (F12)
5. Check Network tab to confirm local loading
6. Verify all icons display correctly

## Additional Considerations

### .gitignore
The `wwwroot/lib/` folder is typically included in `.gitignore` since libman can restore it:
```gitignore
# LibMan managed files
wwwroot/lib/
```

However, you may choose to commit these files to avoid requiring libman restore during deployment.

### CI/CD Pipeline
Add libman restore to your build pipeline:
```yaml
- name: Restore LibMan packages
  run: dotnet tool install -g Microsoft.Web.LibraryManager.Cli && libman restore
  working-directory: ./src/eShopLite.StoreFx
```

### Production Optimization
Consider using a CDN in production while keeping local files for development:
- Configure different `App.razor` for different environments
- Use conditional compilation or configuration-based switching
- Balance between performance (CDN) and reliability (local)
