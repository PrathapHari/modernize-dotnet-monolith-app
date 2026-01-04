# PowerShell Script to Migrate Static Content to wwwroot
# Run this script from the src\eShopLite.StoreFx directory

Write-Host "Starting migration of static content to wwwroot..." -ForegroundColor Green

# Get the script directory
$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Create wwwroot structure
Write-Host "`nCreating wwwroot directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$projectPath\wwwroot" | Out-Null
New-Item -ItemType Directory -Force -Path "$projectPath\wwwroot\css" | Out-Null
New-Item -ItemType Directory -Force -Path "$projectPath\wwwroot\js" | Out-Null
New-Item -ItemType Directory -Force -Path "$projectPath\wwwroot\images" | Out-Null
Write-Host "Directory structure created successfully." -ForegroundColor Green

# Move Content to css
if (Test-Path "$projectPath\Content") {
    Write-Host "`nMoving Content folder to wwwroot\css..." -ForegroundColor Yellow
    $contentFiles = Get-ChildItem -Path "$projectPath\Content\*" -File
    foreach ($file in $contentFiles) {
        Move-Item -Path $file.FullName -Destination "$projectPath\wwwroot\css" -Force
        Write-Host "  Moved: $($file.Name)" -ForegroundColor Gray
    }
    Write-Host "Content files moved successfully." -ForegroundColor Green
} else {
    Write-Host "`nContent folder not found, skipping..." -ForegroundColor DarkYellow
}

# Move Scripts to js
if (Test-Path "$projectPath\Scripts") {
    Write-Host "`nMoving Scripts folder to wwwroot\js..." -ForegroundColor Yellow
    $scriptFiles = Get-ChildItem -Path "$projectPath\Scripts\*" -File
    foreach ($file in $scriptFiles) {
        Move-Item -Path $file.FullName -Destination "$projectPath\wwwroot\js" -Force
        Write-Host "  Moved: $($file.Name)" -ForegroundColor Gray
    }
    Write-Host "Script files moved successfully." -ForegroundColor Green
} else {
    Write-Host "`nScripts folder not found, skipping..." -ForegroundColor DarkYellow
}

# Move Images
if (Test-Path "$projectPath\Images") {
    Write-Host "`nMoving Images folder to wwwroot\images..." -ForegroundColor Yellow
    $imageFiles = Get-ChildItem -Path "$projectPath\Images\*" -File
    foreach ($file in $imageFiles) {
        Move-Item -Path $file.FullName -Destination "$projectPath\wwwroot\images" -Force
        Write-Host "  Moved: $($file.Name)" -ForegroundColor Gray
    }
    Write-Host "Image files moved successfully." -ForegroundColor Green
} else {
    Write-Host "`nImages folder not found, skipping..." -ForegroundColor DarkYellow
}

# Move favicon
if (Test-Path "$projectPath\favicon.ico") {
    Write-Host "`nMoving favicon.ico to wwwroot..." -ForegroundColor Yellow
    Move-Item -Path "$projectPath\favicon.ico" -Destination "$projectPath\wwwroot\" -Force
    Write-Host "favicon.ico moved successfully." -ForegroundColor Green
} else {
    Write-Host "`nfavicon.ico not found, skipping..." -ForegroundColor DarkYellow
}

# Clean up empty directories
Write-Host "`nCleaning up empty source directories..." -ForegroundColor Yellow
$dirsToRemove = @("Content", "Scripts", "Images")
foreach ($dir in $dirsToRemove) {
    $dirPath = "$projectPath\$dir"
    if (Test-Path $dirPath) {
        $itemCount = (Get-ChildItem -Path $dirPath -File).Count
        if ($itemCount -eq 0) {
            Remove-Item -Path $dirPath -Recurse -Force
            Write-Host "  Removed empty directory: $dir" -ForegroundColor Gray
        } else {
            Write-Host "  $dir still contains files, not removing." -ForegroundColor DarkYellow
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Migration Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Update your view files (_Layout.cshtml, etc.) to use new paths:" -ForegroundColor White
Write-Host "   - ~/Content/... -> ~/css/..." -ForegroundColor Gray
Write-Host "   - ~/Scripts/... -> ~/js/..." -ForegroundColor Gray
Write-Host "   - ~/Images/... -> ~/images/..." -ForegroundColor Gray
Write-Host "2. Rebuild your solution" -ForegroundColor White
Write-Host "3. Test the application" -ForegroundColor White
Write-Host "`nPress any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
