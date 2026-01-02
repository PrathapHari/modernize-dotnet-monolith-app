# .github/upgrades/plan.md

## Table of contents

- 1 Executive Summary
- 2 Migration Strategy
- 3 Detailed Dependency Analysis
- 4 Project-by-Project Plans
- 5 Package Update Reference
- 6 Breaking Changes Catalog
- 7 Testing & Validation Strategy
- 8 Risk Management
- 9 Complexity & Effort Assessment
- 10 Source Control Strategy
- 11 Success Criteria

---

## 1 Executive Summary

### Scenario
Upgrade the solution `eShopLiteFx.sln` from .NET Framework 4.8 to .NET 9.0 (net9.0). The assessment identified a single project that requires migration: `src\\eShopLite.StoreFx\\eShopLite.StoreFx.csproj` (ASP.NET Web Application project, classic non-SDK WAP).

### High-level metrics (from assessment)
- Projects in scope: 1 (all require upgrade)
- Total NuGet packages: 24 (5 require action: 2 incompatible, 3 recommended updates)
- Lines of code (approx): 512
- Total issues found: 19
- Project style: classic WAP, not SDK-style

### Selected Strategy
**All-At-Once Strategy** — All projects (the single project in this solution) will be upgraded simultaneously in a single atomic operation.

Rationale:
- Single-project solution (meets small-solution criteria for All-At-Once)
- Upgrades affect cross-cutting areas (project file format, framework, packages) that are easier to resolve together
- Assessment shows available package replacements/target versions for flagged packages

Risk note: Project is a classic ASP.NET Web Application using `System.Web`-based APIs (Global.asax, System.Web.Optimization). That raises migration complexity and risk; the plan includes focused mitigation and testing.

---

## 2 Migration Strategy

### Approach
- Convert the project from classic WAP (non-SDK) to an SDK-style project and change its TFM to `net9.0` in a single atomic update.
- Replace or remove incompatible packages and update recommended packages as part of the same atomic change.
- After changes are applied, restore dependencies and build the entire solution to surface compilation errors, then resolve them as part of the same pass.
- After a successful build, run automated tests (if available) and follow validation checklist.

### Task grouping for execution (for executor)
- TASK-000: Prerequisites
  - Commit pending changes on `main` (or chosen action: stash/undo if preferred)
  - Create and switch to branch `upgrade-to-NET9`
  - Ensure .NET 9.0 SDK is installed and available
  - Update `global.json` if present to reference .NET 9.0 SDK

- TASK-001: Atomic framework + package upgrade (single atomic task)
  - Update the project file(s) to SDK-style and TargetFramework `net9.0` for all projects
  - Update or replace NuGet package references per §5 across all projects
  - Restore dependencies
  - Build solution and fix all compilation errors arising from the upgrade
  - Verify solution builds with 0 errors

- TASK-002: Test execution and validation
  - Run all discovered test projects (if any)
  - Address test failures discovered

Notes: This task grouping follows the All-At-Once Task Generation rules — prerequisites are separated, the core upgrade is a single atomic task, and testing is a separate task after the atomic upgrade completes.

### Key constraints and principles
- All project file changes, package updates, and compilation fixes must be applied in one coordinated operation (single atomic upgrade task).
- Respect dependency ordering (bottom-up); with a single project, this constraint means confirm there are no dependent projects that must be migrated first.
- Preserve or record pre-upgrade state (pending changes, branch) before making changes.

### Prerequisites
- Ensure .NET 9.0 SDK is available on the build machine and referenced by `global.json` if present.
- Decide and apply pending-changes action (assessment shows pending changes exist; recommended: commit then create upgrade branch).
- Create and switch to upgrade branch: recommended name `upgrade-to-NET9` (plan uses this branch name).

---

## 3 Detailed Dependency Analysis

### Summary
- Projects discovered (topological order):
  - `src\eShopLite.StoreFx\eShopLite.StoreFx.csproj` (leaf node)
- No project-to-project dependencies; this project can be migrated in isolation.

### Project dependency details
- `eShopLite.StoreFx` has no upstream project dependencies within this solution. It depends only on NuGet packages (listed in §5).

### Critical path and sequencing
- With a single project, the critical path is:
  1. Convert project to SDK-style and set TargetFramework to `net9.0`.
  2. Update/remove incompatible packages and apply recommended updates.
  3. Fix code-level System.Web usages and configuration changes.
  4. Restore and build, then resolve remaining compile errors.

### Circular dependencies
- No cycles detected.

---

## 4 Project-by-Project Plans

### Project: `src\\eShopLite.StoreFx\\eShopLite.StoreFx.csproj`

**Current State**
- TargetFramework: `net48`
- SDK-style: No
- Project kind: Web Application (Global.asax present)
- Packages: 24 (see §5)
- Files: 87 | LOC: 512

**Target State**
- TargetFramework: `net9.0`
- SDK-style: Yes
- ASP.NET Core hosting model adopted (Program.cs/Startup)

**Migration Steps (detailed)**
1. Preconditions
   - Commit pending changes on `main` and push, or follow chosen action (stash/undo)
   - Create branch `upgrade-to-NET9` from `main`
   - Install .NET 9.0 SDK and validate availability
   - Backup project folder or ensure commit can be reverted
2. Convert project to SDK-style
   - Create new SDK-style csproj with `Microsoft.NET.Sdk.Web` Sdk attribute
   - Include content: `<Content Include="**\*.cshtml" />`, static files, wwwroot configuration as applicable
   - Keep original folder layout for Views/Controllers/wwwroot
3. Update TargetFramework to `net9.0`
   - Use `<TargetFramework>net9.0</TargetFramework>` in the new csproj
4. Package updates and replacements (see §5). Apply all package reference changes in the csproj now.
5. Startup/model changes
   - Add `Program.cs` and `Startup.cs` with ASP.NET Core middleware pipeline and DI setup
   - Move Global.asax initializers (Application_Start, Application_End) to `Program.cs` or hosted services
   - Replace any HttpModules/HttpHandlers with middleware or background services
6. Bundling & static assets
   - Remove references to `Microsoft.AspNet.Web.Optimization` and bundling config
   - Adopt static files served from `wwwroot` and use LibMan/npm for asset management
   - Update layout views to reference new static paths
7. Dependency injection
   - Replace `Autofac.Mvc5` integration with `Autofac.Extensions.DependencyInjection` and configure `builder.Host.UseServiceProviderFactory(new AutofacServiceProviderFactory())`
   - Migrate registrations from `containerBuilder.RegisterControllers(...)` to `builder.Services` style or register with Autofac module adapted for ASP.NET Core
8. Views & Razor
   - Review `_ViewStart.cshtml`, `_Layout.cshtml`, and view imports for compatibility
   - Replace any `Html` helpers that rely on System.Web-specific behavior
9. Configuration
   - Migrate `web.config` entries to `appsettings.json` and environment-specific configurations
   - Migrate connection strings to `IConfiguration` and DI
10. Entity Framework
   - If EF6 is used and remains, verify EF6.5.1 compatibility with net9.0; otherwise plan EF Core migration separately
11. Build, fix compilation errors
   - Run `dotnet restore` and `dotnet build` at solution level
   - Fix compile errors due to API and package changes in the same atomic change
12. Tests & validation
   - Run any test projects and resolve failures
   - Run manual smoke startup checks in dev environment

**Validation checklist**
- [ ] Project file is SDK-style and contains `<TargetFramework>net9.0</TargetFramework>`
- [ ] All incompatible NuGet references removed or replaced
- [ ] Solution builds with 0 errors and no package compatibility warnings
- [ ] App starts and default route renders

---

## 5 Package Update Reference

### Summary table

| Package | Current Version | Target Version | Projects Affected | Action |
| :--- | :---: | :---: | :--- | :--- |
| Antlr | 3.5.0.2 | Antlr4 4.6.6+ | `eShopLite.StoreFx` | Replace - Antlr4 runtime
| Autofac | 8.3.0 | 8.3.0 | `eShopLite.StoreFx` | Keep - update integration for ASP.NET Core
| Autofac.Mvc5 | 6.1.0 | N/A | `eShopLite.StoreFx` | Remove - replace with `Autofac.Extensions.DependencyInjection`
| bootstrap | 5.3.7 | 5.3.7 | `eShopLite.StoreFx` | Keep - manage via LibMan/npm
| EntityFramework | 6.5.1 | 6.5.1 or migrate to EF Core later | `eShopLite.StoreFx` | Keep or plan EF migration
| jQuery | 3.7.1 | 3.7.1 | `eShopLite.StoreFx` | Keep - manage via LibMan/npm
| jQuery.Validation | 1.21.0 | 1.21.0 | `eShopLite.StoreFx` | Keep
| Microsoft.AspNet.Mvc | 5.3.0 | N/A | `eShopLite.StoreFx` | Remove - migrate to `Microsoft.AspNetCore.Mvc` equivalents
| Microsoft.AspNet.Razor | 3.3.0 | N/A | `eShopLite.StoreFx` | Remove - migrate to ASP.NET Core Razor
| Microsoft.AspNet.Web.Optimization | 1.1.3 | N/A | `eShopLite.StoreFx` | Remove - replace bundling strategy
| Microsoft.AspNet.WebPages | 3.3.0 | N/A | `eShopLite.StoreFx` | Remove - functionality moved to ASP.NET Core
| Microsoft.Bcl.AsyncInterfaces | 9.0.7 | 9.0.11 | `eShopLite.StoreFx` | Update
| Microsoft.CodeDom.Providers.DotNetCompilerPlatform | 4.1.0 | N/A | `eShopLite.StoreFx` | Remove or review - not required in ASP.NET Core
| Microsoft.jQuery.Unobtrusive.Validation | 4.0.0 | 4.0.0 | `eShopLite.StoreFx` | Keep
| Microsoft.Web.Infrastructure | 2.0.0 | N/A | `eShopLite.StoreFx` | Remove - framework-provided functionality
| Modernizr | 2.8.3 | 2.8.3 | `eShopLite.StoreFx` | Keep
| Newtonsoft.Json | 13.0.3 | 13.0.4 | `eShopLite.StoreFx` | Update
| System.Buffers | 4.6.1 | N/A | `eShopLite.StoreFx` | Remove - use framework
| System.Diagnostics.DiagnosticSource | 9.0.7 | 9.0.11 | `eShopLite.StoreFx` | Update
| System.Memory | 4.6.3 | N/A | `eShopLite.StoreFx` | Remove - use framework
| System.Numerics.Vectors | 4.6.1 | N/A | `eShopLite.StoreFx` | Remove - use framework
| System.Runtime.CompilerServices.Unsafe | 6.1.2 | 6.1.2 | `eShopLite.StoreFx` | Keep
| System.Threading.Tasks.Extensions | 4.6.3 | N/A | `eShopLite.StoreFx` | Remove - use framework
| WebGrease | 1.6.0 | 1.6.0 | `eShopLite.StoreFx` | Keep or replace with modern tooling


### Notes
- For packages marked as `N/A` in Target Version, the package is incompatible with .NET 9.0 or its functionality is provided by ASP.NET Core. Remove references and port code to framework equivalents.
- Client-side assets should be migrated to client asset managers (LibMan, npm) rather than NuGet package references where applicable.
- Record each package change in PR with reason and link to any breaking-change notes.

---

## 6 Breaking Changes Catalog

This catalog consolidates known and likely breaking changes specific to migrating this project from `net48` to `net9.0`.

1. System.Web model removed
   - Affected artifacts: `Global.asax`, HttpModules, HttpHandlers, `System.Web` APIs
   - Migration action: Migrate startup logic to `Program.cs` / `Startup` and replace modules/handlers with middleware or hosted services.

2. Bundling & Optimization removed
   - Affected artifacts: `Microsoft.AspNet.Web.Optimization`, `BundleConfig.cs`, `bundle` references in layout
   - Migration action: Adopt build-time bundling (webpack, rollup) or LibMan-managed static files. Update views to reference compiled assets.

3. MVC and Razor differences
   - Affected artifacts: `Microsoft.AspNet.Mvc`, Razor view engine differences
   - Migration action: Replace references to MVC 5 packages and use ASP.NET Core MVC; update view imports and helpers as needed.

4. Dependency injection changes
   - Affected artifacts: Autofac.Mvc5 registrations
   - Migration action: Use `Autofac.Extensions.DependencyInjection` and configure with HostBuilder; refactor controller registration.

5. Configuration & web.config
   - Affected artifacts: `web.config` sections (authentication, handlers, httpRuntime)
   - Migration action: Move relevant settings to `appsettings.json` and use `IConfiguration` and environment-based configuration.

6. Third-party binary compatibility
   - Affected artifacts: packages built only for .NET Framework
   - Migration action: Replace with .NET Standard/.NET 6+ compatible packages, or remove and re-implement functionality.

7. Entity Framework differences
   - Affected artifacts: EF6 code if migrating to EF Core
   - Migration action: If staying on EF6, verify EF6.5.1 supports .NET 9.0. Otherwise plan EF Core migration in a follow-up.

For each breaking change discovered during build, add a specific remediation entry in the PR and summary in the migration ticket.

---

## 7 Testing & Validation Strategy

(Expanded with explicit automatable checkpoints)

Levels of validation:
1. Local developer build and smoke compile (must succeed before CI runs)
2. CI build (dotnet restore, dotnet build) — must complete with 0 errors
3. Automated unit tests and integration tests (if present) — run and resolve failures
4. Manual/automated smoke test for startup and key pages (documented but not automated in this plan unless test projects exist)

Automatable checks (for CI):
- `dotnet --list-sdks` contains `9.0.x` (or configured SDK via `global.json`)
- `dotnet restore` completes with exit code 0 and no incompatible-package errors
- `dotnet build` completes with exit code 0
- Run unit tests using `dotnet test` for discovered test projects

Non-automatable but required validation (QA):
- Manual UI smoke test for primary user flows (home, login, key pages)
- Visual verification of static assets and layout

Reporting:
- CI job artifact should include build log, test results, and NuGet restore warnings

---

## 8 Risk Management

### High-risk items

| Project | Risk | Mitigation |
| :--- | :--- | :--- |
| `eShopLite.StoreFx` | High - System.Web/Global.asax and bundling packages incompatible with .NET 9.0 | Convert startup to ASP.NET Core hosting, replace bundling, and update DI integration. Keep a pre-upgrade commit to revert if necessary. |

### Contingency
- If the atomic upgrade cannot be completed successfully, revert branch and consider staged approach: (1) Convert project to SDK-style and keep TFM on `net48` while making minimal package changes, (2) Port system.web-critical components, (3) Update TFM to `net9.0`.

---

## 9 Complexity & Effort Assessment

Per-project complexity rating (relative):

| Project | LOC | Files | Complexity | Key drivers |
| :--- | :---: | :---: | :--- | :--- |
| `eShopLite.StoreFx` | 512 | 87 | High | Classic WAP, System.Web usages, incompatible packages (Autofac.Mvc5, Web.Optimization) |

---

## 10 Source Control Strategy

- Preconditions: Commit any pending changes on `main` before creating upgrade branch.
- Create upgrade branch: `upgrade-to-NET9` (based on `main` commit that captured pending changes).
- Single atomic change approach: Prefer a single cohesive commit (or tightly related commits) that contains:
  - SDK-style project file(s) and TargetFramework changes
  - Package reference updates and removals
  - Code changes required to compile against net9.0
- Create a pull request from `upgrade-to-NET9` to `main` and include in PR description:
  - List of package upgrades and replacements
  - Known breaking changes and mitigations
  - Validation checklist and results

Review and approval:
- Require at least one reviewer familiar with ASP.NET Core migration.

Note: If team policies require smaller commits, the plan can be adapted to include a short series of commits that remain logically grouped; however, the All-At-Once strategy expects a single coordinated upgrade branch and PR.

---

## 11 Success Criteria

The migration is complete when all of the following are true:
- Project file(s) target `net9.0` and are SDK-style
- All incompatible NuGet references removed or replaced per §5
- `dotnet restore` and `dotnet build` complete with exit code 0 in CI
- `dotnet test` (if any tests exist) completes with all tests passing
- PR from `upgrade-to-NET9` to `main` created with validation evidence attached


---

- Update the front-end from the MVC to Blazor components
    - Take a look on the current front-end implementation
    - Recreate the components updating the design but keeping the same functionality
    - Ensure proper routing and navigation between components
    - Update any necessary services or APIs to support the new Blazor components
    - Remove any obsolete or unused code related to the old MVC front-end
    - Move scripts, images, and other assets to the new Blazor folder structure
- Transition from SQLExpress to SQLite
    - Update the database connection string in the appsettings.json file to use SQLite
    - Create a new SQLite database file and ensure it is included in the project
    - Migrate any existing data from SQLExpress to SQLite if necessary
    - Update any Entity Framework configurations to work with SQLite

[End of plan.md]
