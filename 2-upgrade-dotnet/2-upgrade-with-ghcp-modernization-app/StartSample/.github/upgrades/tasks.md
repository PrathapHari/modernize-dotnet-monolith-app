# Migration Tasks: Newtonsoft.Json to System.Text.Json

**Status:** Ready for Execution  
**Project:** eShopLite.StoreFx  
**Target:** Migrate from Newtonsoft.Json 13.0.3 to System.Text.Json  
**Estimated Time:** 4 hours

---

## Progress Dashboard

| Phase | Status | Tasks Complete | Time Spent |
|-------|--------|----------------|------------|
| Phase 1: Preparation | ? Not Started | 0/3 | 0 min |
| Phase 2: Model Migration | ? Not Started | 0/2 | 0 min |
| Phase 3: Service Migration | ? Not Started | 0/2 | 0 min |
| Phase 4: Package Cleanup | ? Not Started | 0/2 | 0 min |
| Phase 5: Testing & Validation | ? Not Started | 0/4 | 0 min |
| **Total** | **? Not Started** | **0/13** | **0 min** |

**Legend:**
- ? Not Started
- ?? In Progress
- ? Complete
- ? Failed
- ? Skipped

---

## Phase 1: Preparation & Setup

### Task 1.1: Create Migration Branch
**Status:** [ ] Not Started  
**Estimated Time:** 5 minutes  
**Priority:** High

**Actions:**
1. Ensure all current changes are committed or stashed
2. Create new branch: `feature/migrate-to-system-text-json`
3. Push branch to remote (optional)

**Commands:**
```bash
git status
git checkout -b feature/migrate-to-system-text-json
git push -u origin feature/migrate-to-system-text-json
```

**Verification:**
- [ ] New branch created successfully
- [ ] Working on new branch (not main)
- [ ] No uncommitted changes blocking work

**Success Criteria:**
- Git branch `feature/migrate-to-system-text-json` exists
- Current branch is the new feature branch

---

### Task 1.2: Backup Current JSON Samples
**Status:** [ ] Not Started  
**Estimated Time:** 10 minutes  
**Priority:** Medium

**Actions:**
1. Document current Product JSON output
2. Document current StoreInfo JSON output
3. Save samples for comparison

**Sample Collection:**

Run application and capture JSON responses:
- Navigate to `/Home/Products` and inspect JSON
- Navigate to `/Home/Stores` and inspect JSON

**Expected Product JSON:**
```json
{
  "id": 1,
  "name": "Hiking Backpack",
  "description": "Durable 40L hiking backpack",
  "price": 89.99,
  "imageUrl": "product1.png"
}
```

**Expected Store JSON:**
```json
{
  "id": 1,
  "name": "Mountain Gear Seattle",
  "city": "Seattle",
  "state": "WA",
  "hours": "9 AM - 6 PM"
}
```

**Verification:**
- [ ] JSON samples captured and saved
- [ ] Property names documented (case sensitivity)
- [ ] Decimal precision documented (price values)

---

### Task 1.3: Search for All Newtonsoft.Json Usage
**Status:** [ ] Not Started  
**Estimated Time:** 15 minutes  
**Priority:** High

**Actions:**
1. Search codebase for `Newtonsoft.Json` using statements
2. Search for `JsonConvert` usage
3. Search for `JObject`, `JArray`, `JToken` usage
4. Document findings

**Search Commands:**
```bash
# PowerShell
Get-ChildItem -Path . -Include *.cs -Recurse | Select-String "using Newtonsoft.Json"
Get-ChildItem -Path . -Include *.cs -Recurse | Select-String "JsonConvert"
Get-ChildItem -Path . -Include *.cs -Recurse | Select-String "JObject|JArray|JToken"
```

**Known Files to Check:**
- `src/eShopLite.StoreFx/Models/Product.cs` ?
- `src/eShopLite.StoreFx/Models/StoreInfo.cs` ?
- `src/eShopLite.StoreFx/Services/StoreService.cs`
- `src/eShopLite.StoreFx/Controllers/HomeController.cs`
- `src/eShopLite.StoreFx/Controllers/DiagnosticsController.cs`

**Verification:**
- [ ] All Newtonsoft.Json usage documented
- [ ] No missed files with JSON operations
- [ ] Custom converters identified (if any)

---

## Phase 2: Model Migration

### Task 2.1: Migrate Product.cs
**Status:** [ ] Not Started  
**Estimated Time:** 15 minutes  
**Priority:** High

**File:** `src/eShopLite.StoreFx/Models/Product.cs`

**Current Code:**
```csharp
using Newtonsoft.Json;

namespace eShopLite.StoreFx.Models
{
    public class Product
    {
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; } = string.Empty;

        [JsonProperty("description")]
        public string Description { get; set; } = string.Empty;

        [JsonProperty("price")]
        public decimal Price { get; set; }

        [JsonProperty("imageUrl")]
        public string ImageUrl { get; set; } = string.Empty;
    }
}
```

**Migration Steps:**

1. **Replace using statement:**
   ```csharp
   // REMOVE: using Newtonsoft.Json;
   // ADD: using System.Text.Json.Serialization;
   ```

2. **Replace all JsonProperty attributes:**
   - Replace `[JsonProperty("id")]` ? `[JsonPropertyName("id")]`
   - Replace `[JsonProperty("name")]` ? `[JsonPropertyName("name")]`
   - Replace `[JsonProperty("description")]` ? `[JsonPropertyName("description")]`
   - Replace `[JsonProperty("price")]` ? `[JsonPropertyName("price")]`
   - Replace `[JsonProperty("imageUrl")]` ? `[JsonPropertyName("imageUrl")]`

**Updated Code:**
```csharp
using System.Text.Json.Serialization;

namespace eShopLite.StoreFx.Models
{
    public class Product
    {
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [JsonPropertyName("name")]
        public string Name { get; set; } = string.Empty;

        [JsonPropertyName("description")]
        public string Description { get; set; } = string.Empty;

        [JsonPropertyName("price")]
        public decimal Price { get; set; }

        [JsonPropertyName("imageUrl")]
        public string ImageUrl { get; set; } = string.Empty;
    }
}
```

**Verification:**
- [ ] File compiles without errors
- [ ] All 5 properties have `[JsonPropertyName]` attributes
- [ ] Property names match exactly (case-sensitive)
- [ ] No remaining `Newtonsoft.Json` references

**Build Test:**
```bash
dotnet build src/eShopLite.StoreFx/eShopLite.StoreFx.csproj
```

---

### Task 2.2: Migrate StoreInfo.cs
**Status:** [ ] Not Started  
**Estimated Time:** 15 minutes  
**Priority:** High

**File:** `src/eShopLite.StoreFx/Models/StoreInfo.cs`

**Current Code:**
```csharp
using Newtonsoft.Json;

namespace eShopLite.StoreFx.Models
{
    public class StoreInfo
    {
        [JsonProperty("id")]
        public int Id { get; set; }
        [JsonProperty("name")]
        public string Name { get; set; }
        [JsonProperty("city")]
        public string City { get; set; }
        [JsonProperty("state")]
        public string State { get; set; }
        [JsonProperty("hours")]
        public string Hours { get; set; }
    }
}
```

**Migration Steps:**

1. **Replace using statement:**
   ```csharp
   // REMOVE: using Newtonsoft.Json;
   // ADD: using System.Text.Json.Serialization;
   ```

2. **Replace all JsonProperty attributes:**
   - Replace `[JsonProperty("id")]` ? `[JsonPropertyName("id")]`
   - Replace `[JsonProperty("name")]` ? `[JsonPropertyName("name")]`
   - Replace `[JsonProperty("city")]` ? `[JsonPropertyName("city")]`
   - Replace `[JsonProperty("state")]` ? `[JsonPropertyName("state")]`
   - Replace `[JsonProperty("hours")]` ? `[JsonPropertyName("hours")]`

3. **Add null-safety initializers (recommended):**
   ```csharp
   public string Name { get; set; } = string.Empty;
   ```

**Updated Code:**
```csharp
using System.Text.Json.Serialization;

namespace eShopLite.StoreFx.Models
{
    public class StoreInfo
    {
        [JsonPropertyName("id")]
        public int Id { get; set; }
        
        [JsonPropertyName("name")]
        public string Name { get; set; } = string.Empty;
        
        [JsonPropertyName("city")]
        public string City { get; set; } = string.Empty;
        
        [JsonPropertyName("state")]
        public string State { get; set; } = string.Empty;
        
        [JsonPropertyName("hours")]
        public string Hours { get; set; } = string.Empty;
    }
}
```

**Verification:**
- [ ] File compiles without errors
- [ ] All 5 properties have `[JsonPropertyName]` attributes
- [ ] String properties initialized to `string.Empty`
- [ ] No remaining `Newtonsoft.Json` references

**Build Test:**
```bash
dotnet build src/eShopLite.StoreFx/eShopLite.StoreFx.csproj
```

---

## Phase 3: Service & Controller Migration

### Task 3.1: Audit StoreService.cs for JSON Operations
**Status:** [ ] Not Started  
**Estimated Time:** 20 minutes  
**Priority:** High

**File:** `src/eShopLite.StoreFx/Services/StoreService.cs`

**Actions:**
1. Open `StoreService.cs`
2. Search for any of these patterns:
   - `JsonConvert.SerializeObject`
   - `JsonConvert.DeserializeObject`
   - `JsonSerializerSettings`
   - `JObject`, `JArray`, `JToken`

**If Found - Migration Required:**

**Pattern 1: Serialization**
```csharp
// BEFORE (Newtonsoft.Json)
var json = JsonConvert.SerializeObject(product);

// AFTER (System.Text.Json)
var json = JsonSerializer.Serialize(product);
```

**Pattern 2: Deserialization**
```csharp
// BEFORE (Newtonsoft.Json)
var product = JsonConvert.DeserializeObject<Product>(json);

// AFTER (System.Text.Json)
var product = JsonSerializer.Deserialize<Product>(json);
```

**Pattern 3: With Settings**
```csharp
// BEFORE (Newtonsoft.Json)
var json = JsonConvert.SerializeObject(product, new JsonSerializerSettings
{
    ContractResolver = new CamelCasePropertyNamesContractResolver()
});

// AFTER (System.Text.Json)
var options = new JsonSerializerOptions
{
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
};
var json = JsonSerializer.Serialize(product, options);
```

**Required Using Statements:**
```csharp
using System.Text.Json;
using System.Text.Json.Serialization; // if using JsonSerializerOptions
```

**Verification:**
- [ ] All `JsonConvert` calls replaced
- [ ] All `JsonSerializerSettings` replaced with `JsonSerializerOptions`
- [ ] File compiles without errors
- [ ] No remaining `Newtonsoft.Json` references

**Notes:**
If no JSON operations found, mark task as "No Changes Required" and proceed.

---

### Task 3.2: Audit Controllers for JSON Operations
**Status:** [ ] Not Started  
**Estimated Time:** 20 minutes  
**Priority:** Medium

**Files to Check:**
- `src/eShopLite.StoreFx/Controllers/HomeController.cs`
- `src/eShopLite.StoreFx/Controllers/DiagnosticsController.cs`

**Actions:**
1. Open each controller file
2. Search for JSON operations
3. Look for:
   - Explicit `JsonConvert` usage
   - `Json()` method calls (ASP.NET Core handles these automatically)
   - Custom JSON responses

**Common Patterns:**

**Pattern 1: Returning JSON from Controller**
```csharp
// ASP.NET Core uses System.Text.Json by default for this
return Json(products); // No change needed
```

**Pattern 2: Explicit JSON Serialization**
```csharp
// BEFORE
var json = JsonConvert.SerializeObject(products);
return Content(json, "application/json");

// AFTER
var json = JsonSerializer.Serialize(products);
return Content(json, "application/json");
```

**Verification:**
- [ ] All controllers checked
- [ ] Any explicit JSON operations migrated
- [ ] Controllers compile without errors
- [ ] No remaining `Newtonsoft.Json` references

**Notes:**
Most ASP.NET Core controllers won't need changes as the framework uses System.Text.Json by default.

---

## Phase 4: Package Cleanup

### Task 4.1: Remove Newtonsoft.Json Package Reference
**Status:** [ ] Not Started  
**Estimated Time:** 10 minutes  
**Priority:** High

**File:** `src/eShopLite.StoreFx/eShopLite.StoreFx.csproj`

**Actions:**

1. **Locate and remove PackageReference:**
   ```xml
   <!-- REMOVE THIS LINE -->
   <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
   ```

2. **If using packages.config (legacy):**
   Remove from `packages.config`:
   ```xml
   <!-- REMOVE THIS LINE -->
   <package id="Newtonsoft.Json" version="13.0.3" targetFramework="net48" />
   ```

**Commands:**
```bash
# Using dotnet CLI (recommended)
dotnet remove src/eShopLite.StoreFx/eShopLite.StoreFx.csproj package Newtonsoft.Json

# Or manually edit .csproj file
```

**Verification:**
- [ ] Newtonsoft.Json removed from .csproj
- [ ] Newtonsoft.Json removed from packages.config (if exists)
- [ ] No PackageReference to Newtonsoft.Json remains

---

### Task 4.2: Clean and Restore Project
**Status:** [ ] Not Started  
**Estimated Time:** 10 minutes  
**Priority:** High

**Actions:**

1. **Clean the project:**
   ```bash
   dotnet clean src/eShopLite.StoreFx/eShopLite.StoreFx.csproj
   ```

2. **Restore packages:**
   ```bash
   dotnet restore src/eShopLite.StoreFx/eShopLite.StoreFx.csproj
   ```

3. **Rebuild project:**
   ```bash
   dotnet build src/eShopLite.StoreFx/eShopLite.StoreFx.csproj --no-incremental
   ```

**Verification:**
- [ ] Clean completed successfully
- [ ] Restore completed successfully
- [ ] Build completed with ZERO errors
- [ ] Build completed with ZERO warnings related to JSON

**Expected Output:**
```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

**If Build Fails:**
- Document all errors
- Check for missed Newtonsoft.Json references
- Verify all using statements updated
- Mark task as failed and await assistance

---

## Phase 5: Testing & Validation

### Task 5.1: Compilation Verification
**Status:** [ ] Not Started  
**Estimated Time:** 10 minutes  
**Priority:** Critical

**Actions:**

1. **Full Solution Build:**
   ```bash
   dotnet build eShopLiteFx.sln --no-incremental
   ```

2. **Check for Warnings:**
   ```bash
   dotnet build eShopLiteFx.sln -warnaserror
   ```

**Verification Checklist:**
- [ ] Solution builds successfully
- [ ] Zero compilation errors
- [ ] Zero JSON-related warnings
- [ ] All projects in solution compile
- [ ] No missing using statements

**Success Criteria:**
```
Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:XX.XX
```

---

### Task 5.2: Runtime Testing - Products Page
**Status:** [ ] Not Started  
**Estimated Time:** 20 minutes  
**Priority:** Critical

**Actions:**

1. **Start the application:**
   ```bash
   dotnet run --project src/eShopLite.StoreFx/eShopLite.StoreFx.csproj
   ```

2. **Navigate to Products page:**
   - URL: `https://localhost:[port]/Home/Products`

3. **Visual Inspection:**
   - [ ] Page loads without errors
   - [ ] Products display correctly
   - [ ] Product names visible
   - [ ] Product descriptions visible
   - [ ] Prices display correctly (e.g., $89.99)
   - [ ] Images display or fallback works

4. **Browser DevTools Check:**
   - Open F12 Developer Tools
   - Check Console for errors
   - Check Network tab for JSON responses

5. **JSON Response Validation:**
   If API endpoint exists, verify JSON structure:
   ```json
   {
     "id": 1,
     "name": "Hiking Backpack",
     "description": "Durable 40L hiking backpack",
     "price": 89.99,
     "imageUrl": "product1.png"
   }
   ```

**Verification:**
- [ ] No runtime exceptions
- [ ] No console errors
- [ ] Products render correctly
- [ ] Prices format correctly
- [ ] JSON structure matches expected format
- [ ] Property names correct (case-sensitive)

**Data Integrity Checks:**
- [ ] Decimal values serialize correctly
- [ ] String values serialize correctly
- [ ] Null values handled properly
- [ ] Empty strings handled properly

---

### Task 5.3: Runtime Testing - Stores Page
**Status:** [ ] Not Started  
**Estimated Time:** 20 minutes  
**Priority:** Critical

**Actions:**

1. **Navigate to Stores page:**
   - URL: `https://localhost:[port]/Home/Stores`

2. **Visual Inspection:**
   - [ ] Page loads without errors
   - [ ] Stores display correctly
   - [ ] Store names visible
   - [ ] City and state visible
   - [ ] Hours visible

3. **Browser DevTools Check:**
   - Open F12 Developer Tools
   - Check Console for errors
   - Check Network tab for JSON responses

4. **JSON Response Validation:**
   If API endpoint exists, verify JSON structure:
   ```json
   {
     "id": 1,
     "name": "Mountain Gear Seattle",
     "city": "Seattle",
     "state": "WA",
     "hours": "9 AM - 6 PM"
   }
   ```

**Verification:**
- [ ] No runtime exceptions
- [ ] No console errors
- [ ] Stores render correctly
- [ ] JSON structure matches expected format
- [ ] Property names correct (case-sensitive)

**Data Integrity Checks:**
- [ ] All string values serialize correctly
- [ ] Integer IDs serialize correctly
- [ ] No data corruption

---

### Task 5.4: Comparison with Baseline
**Status:** [ ] Not Started  
**Estimated Time:** 15 minutes  
**Priority:** High

**Actions:**

1. **Compare JSON Outputs:**
   - Compare current JSON with saved baseline (from Task 1.2)
   - Verify structure is identical
   - Verify property names match exactly
   - Verify data types match

2. **Performance Check (Optional):**
   - Note application responsiveness
   - Check for any performance degradation
   - Expected: Same or better performance

**Verification:**
- [ ] JSON structure matches baseline
- [ ] Property names unchanged
- [ ] Data types unchanged
- [ ] No functional regressions
- [ ] Performance acceptable

**Acceptable Differences:**
- Minor whitespace formatting differences
- Number precision may be slightly different (should still be correct)

---

## Phase 6: Finalization

### Task 6.1: Final Code Review
**Status:** [ ] Not Started  
**Estimated Time:** 15 minutes  
**Priority:** Medium

**Review Checklist:**

**Code Quality:**
- [ ] No `Newtonsoft.Json` references remain
- [ ] All using statements updated
- [ ] Code follows project conventions
- [ ] No commented-out code
- [ ] No debug statements left in

**Files Changed:**
- [ ] `Product.cs` - using statement and attributes updated
- [ ] `StoreInfo.cs` - using statement and attributes updated
- [ ] `.csproj` - Newtonsoft.Json removed
- [ ] Any service/controller files with JSON operations

**Search Commands for Final Check:**
```bash
# PowerShell - Should return NO results
Get-ChildItem -Path ./src -Include *.cs -Recurse | Select-String "Newtonsoft.Json" -SimpleMatch
Get-ChildItem -Path ./src -Include *.cs -Recurse | Select-String "JsonConvert" -SimpleMatch
Get-ChildItem -Path ./src -Include *.csproj -Recurse | Select-String "Newtonsoft.Json" -SimpleMatch
```

**Verification:**
- [ ] No Newtonsoft.Json references found
- [ ] All searches return empty results
- [ ] Code review passed

---

### Task 6.2: Commit Changes
**Status:** [ ] Not Started  
**Estimated Time:** 10 minutes  
**Priority:** High

**Actions:**

1. **Stage all changes:**
   ```bash
   git add .
   ```

2. **Review staged changes:**
   ```bash
   git status
   git diff --staged
   ```

3. **Commit with descriptive message:**
   ```bash
   git commit -m "Migrate from Newtonsoft.Json to System.Text.Json

- Replace [JsonProperty] with [JsonPropertyName] in Product.cs
- Replace [JsonProperty] with [JsonPropertyName] in StoreInfo.cs
- Remove Newtonsoft.Json package dependency
- Update all JSON serialization to use System.Text.Json
- Add null-safety initializers to string properties
- All tests passing, no functional changes"
   ```

4. **Push to remote:**
   ```bash
   git push origin feature/migrate-to-system-text-json
   ```

**Verification:**
- [ ] All changes committed
- [ ] Commit message is descriptive
- [ ] Changes pushed to remote
- [ ] Branch visible on GitHub/remote

**Files Expected in Commit:**
- `src/eShopLite.StoreFx/Models/Product.cs`
- `src/eShopLite.StoreFx/Models/StoreInfo.cs`
- `src/eShopLite.StoreFx/eShopLite.StoreFx.csproj`
- Any service/controller files modified
- `packages.config` (if applicable)

---

### Task 6.3: Create Pull Request (Optional)
**Status:** [ ] Not Started  
**Estimated Time:** 10 minutes  
**Priority:** Low

**Actions:**

1. **Navigate to repository on GitHub**

2. **Create Pull Request:**
   - Title: `Migrate from Newtonsoft.Json to System.Text.Json`
   - Base branch: `main`
   - Compare branch: `feature/migrate-to-system-text-json`

3. **PR Description Template:**
   ```markdown
   ## Migration Summary
   
   This PR migrates the project from Newtonsoft.Json to System.Text.Json.
   
   ### Changes Made
   - ? Updated `Product.cs` - replaced `[JsonProperty]` with `[JsonPropertyName]`
   - ? Updated `StoreInfo.cs` - replaced `[JsonProperty]` with `[JsonPropertyName]`
   - ? Removed Newtonsoft.Json package dependency
   - ? Added null-safety initializers to string properties
   
   ### Testing
   - ? All compilation tests passed
   - ? Products page tested and verified
   - ? Stores page tested and verified
   - ? JSON output matches expected format
   - ? No runtime errors
   
   ### Benefits
   - ?? Improved performance (1.5-2x faster serialization)
   - ?? Lower memory allocation
   - ?? Reduced deployment size
   - ?? Better security updates (part of .NET runtime)
   
   ### Risk Assessment
   - **Risk Level:** Low
   - **Breaking Changes:** None
   - **Rollback Plan:** Documented in plan.md
   
   Closes #[issue-number]
   ```

**Verification:**
- [ ] PR created successfully
- [ ] Description is comprehensive
- [ ] Reviewers assigned (if applicable)
- [ ] CI/CD pipeline triggered (if configured)

---

## Post-Migration Checklist

### Immediate Actions (Day 1)

- [ ] Monitor application logs for errors
- [ ] Check error tracking (e.g., Application Insights)
- [ ] Verify all pages load correctly
- [ ] Test all JSON endpoints
- [ ] Collect user feedback

### Week 1 Monitoring

- [ ] Monitor performance metrics
- [ ] Check for any JSON-related exceptions
- [ ] Verify data integrity
- [ ] Review production logs
- [ ] Update documentation

### Success Metrics

**Technical Metrics:**
- Zero JSON-related exceptions
- Build time same or faster
- Runtime performance same or better
- Memory usage same or lower

**Functional Metrics:**
- All features working as before
- No user-reported issues
- No data corruption
- API contracts maintained

---

## Rollback Procedure (If Needed)

### Emergency Rollback

**If critical issues discovered:**

1. **Revert to main branch:**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Delete feature branch (optional):**
   ```bash
   git branch -D feature/migrate-to-system-text-json
   ```

3. **Restore Newtonsoft.Json:**
   ```bash
   dotnet add package Newtonsoft.Json --version 13.0.3
   ```

4. **Rebuild and redeploy:**
   ```bash
   dotnet build
   dotnet run
   ```

### Rollback Indicators

Rollback immediately if:
- ? Critical functionality broken
- ? JSON deserialization failures
- ? Data corruption detected
- ? Severe performance degradation
- ? Unable to fix within 2 hours

---

## Notes & Observations

### Migration Notes
_Add notes during execution here_

### Issues Encountered
_Document any issues and resolutions here_

### Performance Observations
_Note any performance changes here_

---

## Summary

**Total Tasks:** 13  
**Estimated Total Time:** 4 hours  
**Critical Path:** Phase 2 ? Phase 4 ? Phase 5

**Dependencies:**
- Phase 2 must complete before Phase 4
- Phase 4 must complete before Phase 5
- Phase 5 must complete before Phase 6

**Success Criteria:**
- All tasks marked ? Complete
- Zero compilation errors
- Zero runtime errors
- JSON output matches expected format
- All tests passing

---

**Task List Version:** 1.0  
**Last Updated:** [Auto-generated]  
**Status:** Ready for Execution
