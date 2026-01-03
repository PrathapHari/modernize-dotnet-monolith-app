# eShopLite.Store Project Cleanup Script
# Removes unused folders and files after microservices migration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "eShopLite.Store Project Cleanup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "src\eShopLite.StoreFx"
$itemsRemoved = 0
$errors = 0

# List of folders to remove (old MVC/monolith artifacts)
$foldersToRemove = @(
    "Services",
    "Data",
    "Controllers",
    "Views",
    "App_Start",
    "Content",
    "Images",
    "Scripts"
)

# List of files to remove
$filesToRemove = @(
    "Global.asax",
    "Global.asax.cs",
    "Web.config",
    "Web.Debug.config",
    "Web.Release.config",
    "packages.config"
)

Write-Host "Folders to be removed:" -ForegroundColor Yellow
foreach ($folder in $foldersToRemove) {
    $folderPath = Join-Path $projectRoot $folder
    if (Test-Path $folderPath) {
        Write-Host "  - $folder" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Files to be removed:" -ForegroundColor Yellow
foreach ($file in $filesToRemove) {
    $filePath = Join-Path $projectRoot $file
    if (Test-Path $filePath) {
        Write-Host "  - $file" -ForegroundColor Gray
    }
}

Write-Host ""
$confirm = Read-Host "Proceed with cleanup? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting cleanup..." -ForegroundColor Cyan
Write-Host ""

# Remove folders
foreach ($folder in $foldersToRemove) {
    $folderPath = Join-Path $projectRoot $folder
    if (Test-Path $folderPath) {
        try {
            Remove-Item -Path $folderPath -Recurse -Force
            Write-Host "OK Removed folder: $folder" -ForegroundColor Green
            $itemsRemoved++
        }
        catch {
            Write-Host "FAIL Failed to remove folder: $folder" -ForegroundColor Red
            $errors++
        }
    }
    else {
        Write-Host "SKIP Folder not found: $folder" -ForegroundColor Gray
    }
}

Write-Host ""

# Remove files
foreach ($file in $filesToRemove) {
    $filePath = Join-Path $projectRoot $file
    if (Test-Path $filePath) {
        try {
            Remove-Item -Path $filePath -Force
            Write-Host "OK Removed file: $file" -ForegroundColor Green
            $itemsRemoved++
        }
        catch {
            Write-Host "FAIL Failed to remove file: $file" -ForegroundColor Red
            $errors++
        }
    }
    else {
        Write-Host "SKIP File not found: $file" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cleanup Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Items removed: $itemsRemoved" -ForegroundColor Green
Write-Host "Errors: $errors" -ForegroundColor $(if ($errors -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($itemsRemoved -gt 0) {
    Write-Host "Project cleanup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Rebuild the project" -ForegroundColor Gray
    Write-Host "  2. Verify the application runs" -ForegroundColor Gray
    Write-Host "  3. Check the csproj file for empty folder elements" -ForegroundColor Gray
}
else {
    Write-Host "No items were removed. Project may already be clean." -ForegroundColor Yellow
}

Write-Host ""
