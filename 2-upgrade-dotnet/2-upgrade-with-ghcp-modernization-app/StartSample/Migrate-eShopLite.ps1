# eShopLite.StoreFx to eShopLite.Store - Automated Migration Script
# This script performs the complete migration while preserving layout, CSS, and JS

param(
    [switch]$WhatIf = $false,  # Dry run mode
    [switch]$SkipBackup = $false,  # Skip backup creation
    [switch]$KeepOldProject = $true  # Keep old project after migration
)

$ErrorActionPreference = "Stop"

# Configuration
$workspaceRoot = "C:\Users\prath\OneDrive\Documents\GitHub Copilot\Source\2-upgrade-dotnet\2-upgrade-with-ghcp-modernization-app\StartSample"
$sourceProject = "src\eShopLite.StoreFx"
$targetProject = "src\eShopLite.Store"
$backupProject = "src\eShopLite.StoreFx.backup"

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "eShopLite Migration Script" -ForegroundColor Cyan
Write-Host "StoreFx → Store" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Change to workspace root
Set-Location $workspaceRoot
Write-Host "✓ Changed to workspace root: $workspaceRoot" -ForegroundColor Green
Write-Host ""

# Phase 1: Backup
if (-not $SkipBackup) {
    Write-Host "Phase 1: Creating Backup..." -ForegroundColor Yellow
    
    if (Test-Path $backupProject) {
        Write-Host "  Removing old backup..." -ForegroundColor Gray
        Remove-Item $backupProject -Recurse -Force
    }
    
    if (-not $WhatIf) {
        Copy-Item $sourceProject $backupProject -Recurse
        Write-Host "  ✓ Backup created at: $backupProject" -ForegroundColor Green
    } else {
        Write-Host "  [WHATIF] Would create backup at: $backupProject" -ForegroundColor Gray
    }
    Write-Host ""
}

# Phase 2: Create Target Directory
Write-Host "Phase 2: Creating Target Project Structure..." -ForegroundColor Yellow

if (Test-Path $targetProject) {
    Write-Host "  ⚠ Target project already exists!" -ForegroundColor Red
    $response = Read-Host "  Delete existing target project? (yes/no)"
    if ($response -eq "yes") {
        if (-not $WhatIf) {
            Remove-Item $targetProject -Recurse -Force
            Write-Host "  ✓ Removed existing target project" -ForegroundColor Green
        } else {
            Write-Host "  [WHATIF] Would remove: $targetProject" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ✗ Migration cancelled" -ForegroundColor Red
        exit 1
    }
}

if (-not $WhatIf) {
    New-Item -ItemType Directory -Path $targetProject -Force | Out-Null
    Write-Host "  ✓ Created target directory: $targetProject" -ForegroundColor Green
} else {
    Write-Host "  [WHATIF] Would create: $targetProject" -ForegroundColor Gray
}
Write-Host ""

# Phase 3: Copy Files (excluding build artifacts)
Write-Host "Phase 3: Copying Project Files..." -ForegroundColor Yellow

$excludePatterns = @('obj', 'bin', '.vs', '*.user', '*.suo', '.backup')

if (-not $WhatIf) {
    Get-ChildItem -Path $sourceProject -Recurse | 
        Where-Object { 
            $exclude = $false
            foreach ($pattern in $excludePatterns) {
                if ($_.FullName -like "*$pattern*") {
                    $exclude = $true
                    break
                }
            }
            -not $exclude
        } | 
        ForEach-Object {
            $targetPath = $_.FullName.Replace($sourceProject, $targetProject)
            $targetDir = Split-Path $targetPath -Parent
            
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            
            if ($_.PSIsContainer) {
                # Skip directories (they're created as needed)
            } else {
                Copy-Item $_.FullName -Destination $targetPath -Force
            }
        }
    
    $fileCount = (Get-ChildItem -Path $targetProject -Recurse -File).Count
    Write-Host "  ✓ Copied $fileCount files to target project" -ForegroundColor Green
} else {
    $fileCount = (Get-ChildItem -Path $sourceProject -Recurse -File | 
        Where-Object { 
            $exclude = $false
            foreach ($pattern in $excludePatterns) {
                if ($_.FullName -like "*$pattern*") {
                    $exclude = $true
                    break
                }
            }
            -not $exclude
        }).Count
    Write-Host "  [WHATIF] Would copy $fileCount files" -ForegroundColor Gray
}
Write-Host ""

# Phase 4: Rename Project File
Write-Host "Phase 4: Renaming Project File..." -ForegroundColor Yellow

$oldCsproj = "$targetProject\eShopLite.StoreFx.csproj"
$newCsproj = "$targetProject\eShopLite.Store.csproj"

if (-not $WhatIf) {
    if (Test-Path $oldCsproj) {
        Rename-Item $oldCsproj -NewName "eShopLite.Store.csproj"
        Write-Host "  ✓ Renamed .csproj file" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ .csproj file not found at expected location" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [WHATIF] Would rename: $oldCsproj → $newCsproj" -ForegroundColor Gray
}
Write-Host ""

# Phase 5: Update Namespaces in All Files
Write-Host "Phase 5: Updating Namespaces..." -ForegroundColor Yellow

$filesToUpdate = Get-ChildItem -Path $targetProject -Include *.cs,*.razor,*.csproj,*.json -Recurse | 
    Where-Object { 
        $exclude = $false
        foreach ($pattern in $excludePatterns) {
            if ($_.FullName -like "*$pattern*") {
                $exclude = $true
                break
            }
        }
        -not $exclude
    }

$updateCount = 0

if (-not $WhatIf) {
    foreach ($file in $filesToUpdate) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -and $content -match 'eShopLite\.StoreFx') {
            $newContent = $content -replace 'eShopLite\.StoreFx', 'eShopLite.Store'
            Set-Content -Path $file.FullName -Value $newContent -NoNewline
            $updateCount++
        }
    }
    Write-Host "  ✓ Updated namespaces in $updateCount files" -ForegroundColor Green
} else {
    foreach ($file in $filesToUpdate) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -and $content -match 'eShopLite\.StoreFx') {
            $updateCount++
        }
    }
    Write-Host "  [WHATIF] Would update $updateCount files" -ForegroundColor Gray
}
Write-Host ""

# Phase 6: Update launchSettings.json Profile Names
Write-Host "Phase 6: Updating Launch Settings..." -ForegroundColor Yellow

$launchSettings = "$targetProject\Properties\launchSettings.json"

if (-not $WhatIf) {
    if (Test-Path $launchSettings) {
        $content = Get-Content $launchSettings -Raw
        $content = $content -replace '"eShopLite\.StoreFx"', '"eShopLite.Store"'
        Set-Content -Path $launchSettings -Value $content -NoNewline
        Write-Host "  ✓ Updated launch settings" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ launchSettings.json not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [WHATIF] Would update launch settings" -ForegroundColor Gray
}
Write-Host ""

# Phase 7: Verify Critical Files (wwwroot, CSS, JS)
Write-Host "Phase 7: Verifying Critical Files (Layout/CSS/JS)..." -ForegroundColor Yellow

$criticalFiles = @(
    "$targetProject\Components\App.razor",
    "$targetProject\Components\Layout\MainLayout.razor",
    "$targetProject\wwwroot\css\site.css",
    "$targetProject\wwwroot\lib\bootstrap\css\bootstrap.min.css",
    "$targetProject\wwwroot\lib\bootstrap\js\bootstrap.bundle.min.js",
    "$targetProject\wwwroot\lib\bootstrap-icons\font\bootstrap-icons.min.css",
    "$targetProject\libman.json"
)

$allExist = $true
foreach ($file in $criticalFiles) {
    $exists = Test-Path $file
    if (-not $WhatIf) {
        if ($exists) {
            Write-Host "  ✓ $($file.Replace($targetProject + '\', ''))" -ForegroundColor Green
        } else {
            Write-Host "  ✗ MISSING: $($file.Replace($targetProject + '\', ''))" -ForegroundColor Red
            $allExist = $false
        }
    } else {
        Write-Host "  [WHATIF] Would verify: $($file.Replace($targetProject + '\', ''))" -ForegroundColor Gray
    }
}

if (-not $allExist -and -not $WhatIf) {
    Write-Host ""
    Write-Host "  ⚠ Some critical files are missing!" -ForegroundColor Yellow
    Write-Host "  This may affect styling and functionality." -ForegroundColor Yellow
}
Write-Host ""

# Phase 8: Restore NuGet and LibMan Packages
Write-Host "Phase 8: Restoring Packages..." -ForegroundColor Yellow

if (-not $WhatIf) {
    Push-Location $targetProject
    
    Write-Host "  Restoring NuGet packages..." -ForegroundColor Gray
    dotnet restore 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ NuGet packages restored" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ NuGet restore had warnings" -ForegroundColor Yellow
    }
    
    if (Test-Path "libman.json") {
        Write-Host "  Restoring LibMan packages..." -ForegroundColor Gray
        libman restore 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ LibMan packages restored" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ LibMan restore had warnings" -ForegroundColor Yellow
        }
    }
    
    Pop-Location
} else {
    Write-Host "  [WHATIF] Would restore NuGet and LibMan packages" -ForegroundColor Gray
}
Write-Host ""

# Phase 9: Build New Project
Write-Host "Phase 9: Building New Project..." -ForegroundColor Yellow

if (-not $WhatIf) {
    Push-Location $targetProject
    
    $buildOutput = dotnet build 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Build successful!" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Build failed!" -ForegroundColor Red
        Write-Host "  Build output:" -ForegroundColor Gray
        $buildOutput | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    }
    
    Pop-Location
} else {
    Write-Host "  [WHATIF] Would build project" -ForegroundColor Gray
}
Write-Host ""

# Phase 10: Update Solution File
Write-Host "Phase 10: Updating Solution File..." -ForegroundColor Yellow

$slnFiles = Get-ChildItem -Path . -Filter *.sln

if ($slnFiles.Count -gt 0) {
    $slnFile = $slnFiles[0].Name
    Write-Host "  Found solution file: $slnFile" -ForegroundColor Gray
    
    if (-not $WhatIf) {
        # Remove old project from solution
        dotnet sln $slnFile remove "$sourceProject\eShopLite.StoreFx.csproj" 2>&1 | Out-Null
        
        # Add new project to solution
        dotnet sln $slnFile add "$targetProject\eShopLite.Store.csproj" 2>&1 | Out-Null
        
        Write-Host "  ✓ Solution file updated" -ForegroundColor Green
    } else {
        Write-Host "  [WHATIF] Would update solution file" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ No solution file found" -ForegroundColor Yellow
    if (-not $WhatIf) {
        $createSln = Read-Host "  Create new solution? (yes/no)"
        if ($createSln -eq "yes") {
            dotnet new sln -n eShopLite 2>&1 | Out-Null
            dotnet sln add "$targetProject\eShopLite.Store.csproj" 2>&1 | Out-Null
            Write-Host "  ✓ Created new solution and added project" -ForegroundColor Green
        }
    }
}
Write-Host ""

# Phase 11: Summary Report
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Migration Complete!" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Source:  $sourceProject" -ForegroundColor Gray
Write-Host "  Target:  $targetProject" -ForegroundColor Gray
if (-not $SkipBackup) {
    Write-Host "  Backup:  $backupProject" -ForegroundColor Gray
}
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Review the migrated project at: $targetProject" -ForegroundColor Gray
Write-Host "  2. Run the application:" -ForegroundColor Gray
Write-Host "     dotnet run --project $targetProject\eShopLite.Store.csproj" -ForegroundColor Cyan
Write-Host "  3. Test all pages (Home, Products, Stores)" -ForegroundColor Gray
Write-Host "  4. Verify styling and JavaScript work" -ForegroundColor Gray
Write-Host "  5. Compare with original using screenshots" -ForegroundColor Gray
Write-Host ""

Write-Host "Verification Checklist:" -ForegroundColor Yellow
Write-Host "  [ ] Application starts without errors" -ForegroundColor Gray
Write-Host "  [ ] All pages load correctly" -ForegroundColor Gray
Write-Host "  [ ] Bootstrap CSS applied (check with F12)" -ForegroundColor Gray
Write-Host "  [ ] Bootstrap Icons display" -ForegroundColor Gray
Write-Host "  [ ] Custom styles from site.css applied" -ForegroundColor Gray
Write-Host "  [ ] JavaScript works (navbar toggle)" -ForegroundColor Gray
Write-Host "  [ ] Database operations work" -ForegroundColor Gray
Write-Host "  [ ] No console errors (F12)" -ForegroundColor Gray
Write-Host ""

if (-not $WhatIf) {
    Write-Host "To rollback if needed:" -ForegroundColor Yellow
    Write-Host "  Remove-Item '$targetProject' -Recurse -Force" -ForegroundColor Cyan
    Write-Host "  Copy-Item '$backupProject' '$sourceProject' -Recurse" -ForegroundColor Cyan
    Write-Host ""
    
    $runNow = Read-Host "Run the new application now? (yes/no)"
    if ($runNow -eq "yes") {
        Write-Host ""
        Write-Host "Starting eShopLite.Store..." -ForegroundColor Green
        Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
        Write-Host ""
        Set-Location $targetProject
        dotnet run
    }
} else {
    Write-Host "[WHATIF MODE] No changes were made. Run without -WhatIf to perform migration." -ForegroundColor Yellow
}
