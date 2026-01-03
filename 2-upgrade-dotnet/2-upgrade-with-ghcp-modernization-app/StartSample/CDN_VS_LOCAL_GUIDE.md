# Hybrid CDN/Local Configuration Guide

## Overview
This guide demonstrates a hybrid approach for loading static assets in Blazor applications.

## Strategy: CDN with Local Fallback

### Benefits
- ✅ CDN speed for online users
- ✅ Local fallback for offline/CDN failure
- ✅ Best of both worlds

### Implementation

#### Option 1: JavaScript Fallback Pattern

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <base href="/" />
    <title>eShopLite</title>
    
    <!-- Try CDN first -->
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" 
          integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" 
          crossorigin="anonymous"
          onerror="this.onerror=null;this.href='/lib/bootstrap/css/bootstrap.min.css';" />
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css"
          onerror="this.onerror=null;this.href='/lib/bootstrap-icons/font/bootstrap-icons.min.css';" />
    
    <!-- Site CSS (Always local) -->
    <link rel="stylesheet" href="/css/site.css" />
    
    <HeadOutlet />
</head>
<body>
    <Routes />
    
    <!-- Bootstrap JS with Fallback -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" 
            integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" 
            crossorigin="anonymous"
            onerror="this.onerror=null;this.src='/lib/bootstrap/js/bootstrap.bundle.min.js';"></script>
    
    <script src="_framework/blazor.web.js"></script>
    
    <!-- Verify Bootstrap loaded -->
    <script>
        // Check if Bootstrap loaded from CDN
        if (typeof bootstrap === 'undefined') {
            console.warn('Bootstrap CDN failed, loading local version...');
            var script = document.createElement('script');
            script.src = '/lib/bootstrap/js/bootstrap.bundle.min.js';
            document.body.appendChild(script);
        } else {
            console.log('Bootstrap loaded from CDN successfully');
        }
    </script>
</body>
</html>
```

#### Option 2: Environment-Based Configuration

Create different App.razor files for different environments:

**App.Development.razor** (Local):
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" href="/lib/bootstrap/css/bootstrap.min.css" />
    <link rel="stylesheet" href="/lib/bootstrap-icons/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="/css/site.css" />
</head>
<body>
    <Routes />
    <script src="/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script src="_framework/blazor.web.js"></script>
</body>
</html>
```

**App.Production.razor** (CDN):
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" 
          integrity="sha384-..." 
          crossorigin="anonymous" />
    <!-- ... other CDN links ... -->
</head>
<body>
    <Routes />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" 
            integrity="sha384-..." 
            crossorigin="anonymous"></script>
    <script src="_framework/blazor.web.js"></script>
</body>
</html>
```

**Configure in .csproj**:
```xml
<ItemGroup Condition="'$(Configuration)' == 'Debug'">
  <Content Remove="Components/App.Production.razor" />
  <Content Include="Components/App.Development.razor" Link="Components/App.razor" />
</ItemGroup>

<ItemGroup Condition="'$(Configuration)' == 'Release'">
  <Content Remove="Components/App.Development.razor" />
  <Content Include="Components/App.Production.razor" Link="Components/App.razor" />
</ItemGroup>
```

#### Option 3: Configuration-Based (Most Flexible)

**appsettings.json**:
```json
{
  "StaticAssets": {
    "UseLocal": true,
    "BootstrapCssUrl": "/lib/bootstrap/css/bootstrap.min.css",
    "BootstrapJsUrl": "/lib/bootstrap/js/bootstrap.bundle.min.js",
    "BootstrapIconsUrl": "/lib/bootstrap-icons/font/bootstrap-icons.min.css"
  }
}
```

**appsettings.Production.json**:
```json
{
  "StaticAssets": {
    "UseLocal": false,
    "BootstrapCssUrl": "https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css",
    "BootstrapJsUrl": "https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js",
    "BootstrapIconsUrl": "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css"
  }
}
```

**Create AssetConfiguration.cs**:
```csharp
public class StaticAssetConfiguration
{
    public bool UseLocal { get; set; }
    public string BootstrapCssUrl { get; set; } = string.Empty;
    public string BootstrapJsUrl { get; set; } = string.Empty;
    public string BootstrapIconsUrl { get; set; } = string.Empty;
}
```

**Register in Program.cs**:
```csharp
builder.Services.Configure<StaticAssetConfiguration>(
    builder.Configuration.GetSection("StaticAssets"));
```

**Create ViewComponent or Service**:
```csharp
public class AssetUrlService
{
    private readonly StaticAssetConfiguration _config;

    public AssetUrlService(IOptions<StaticAssetConfiguration> config)
    {
        _config = config.Value;
    }

    public string GetBootstrapCssUrl() => _config.BootstrapCssUrl;
    public string GetBootstrapJsUrl() => _config.BootstrapJsUrl;
    public string GetBootstrapIconsUrl() => _config.BootstrapIconsUrl;
}
```

**Update App.razor**:
```razor
@inject IOptions<StaticAssetConfiguration> AssetConfig

<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" href="@AssetConfig.Value.BootstrapCssUrl" />
    <link rel="stylesheet" href="@AssetConfig.Value.BootstrapIconsUrl" />
    <link rel="stylesheet" href="/css/site.css" />
</head>
<body>
    <Routes />
    <script src="@AssetConfig.Value.BootstrapJsUrl"></script>
    <script src="_framework/blazor.web.js"></script>
</body>
</html>
```

## Performance Comparison

### Metrics for Your Consideration

| Metric | Local | CDN | CDN + Fallback |
|--------|-------|-----|----------------|
| First Load (Cold Cache) | ~200ms | ~300-500ms | ~300-500ms |
| First Load (Warm Cache) | ~200ms | ~50ms | ~50ms |
| Offline Support | ✅ Yes | ❌ No | ✅ Yes |
| Privacy | ✅ High | ❌ Low | ⚠️ Medium |
| Reliability | ✅ High | ⚠️ Medium | ✅ High |
| Maintenance | ⚠️ Manual updates | ✅ Auto | ⚠️ Manual |

## Security Considerations

### Subresource Integrity (SRI)

When using CDN, ALWAYS use SRI hashes:

```html
<link rel="stylesheet" 
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
      integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN"
      crossorigin="anonymous">
```

Generate SRI hashes:
```bash
# Using OpenSSL
curl -s https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css | \
  openssl dgst -sha384 -binary | \
  openssl base64 -A

# Using online tool
# Visit: https://www.srihash.org/
```

### Content Security Policy (CSP)

**For Local Assets**:
```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("Content-Security-Policy", 
        "default-src 'self'; " +
        "script-src 'self' 'unsafe-inline'; " +
        "style-src 'self' 'unsafe-inline';");
    await next();
});
```

**For CDN Assets**:
```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("Content-Security-Policy", 
        "default-src 'self'; " +
        "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; " +
        "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; " +
        "font-src 'self' https://cdn.jsdelivr.net;");
    await next();
});
```

## Decision Tree

```
Are you building for:
├─ Public website with global audience?
│  ├─ Yes → Consider CDN with local fallback
│  └─ No → Continue
│
├─ Need offline support?
│  ├─ Yes → Use LOCAL ✅
│  └─ No → Continue
│
├─ Enterprise/Internal app?
│  ├─ Yes → Use LOCAL ✅
│  └─ No → Continue
│
├─ Privacy-sensitive?
│  ├─ Yes → Use LOCAL ✅
│  └─ No → Continue
│
├─ High bandwidth costs?
│  ├─ Yes → Consider CDN
│  └─ No → Use LOCAL ✅
│
└─ Default → Use LOCAL for Blazor Server ✅
```

## Recommendation for eShopLite

**Keep your current LOCAL configuration** because:

1. ✅ Blazor Server app (persistent connection already)
2. ✅ Enterprise/demo application
3. ✅ SQLite database (suggests local/on-premise)
4. ✅ Simplicity and reliability
5. ✅ Offline capability
6. ✅ Full version control
7. ✅ No external dependencies
8. ✅ Better for development workflow

## Summary

| Aspect | Local | CDN |
|--------|-------|-----|
| **For Your App** | ✅ Recommended | ❌ Not needed |
| **Complexity** | Low | Medium-High |
| **Reliability** | High | Medium |
| **Privacy** | High | Low |
| **Offline** | Yes | No |
| **Cost** | Low | Very Low |
| **Performance** | Good | Excellent* |

*Only for globally distributed users with warm cache

## Keep Your Current Setup ✅

Your current configuration is **optimal** for your use case:
```html
<!-- Perfect for eShopLite! -->
<link rel="stylesheet" href="/lib/bootstrap/css/bootstrap.min.css" />
<link rel="stylesheet" href="/lib/bootstrap-icons/font/bootstrap-icons.min.css" />
<link rel="stylesheet" href="/css/site.css" />
<script src="/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
```

No changes needed! 🎉
