# eShopLiteFx .NET 9.0 Upgrade Tasks

## Overview

Upgrade the `eShopLite.StoreFx` web project from .NET Framework to `net9.0` and convert the project file to SDK-style in a single coordinated atomic operation, followed by automated test execution and a final commit. Tasks follow the plan's prerequisites, atomic upgrade, testing, and commit sequencing.

**Progress**: 0/4 tasks complete (0%) ![0%](https://progress-bar.xyz/0)

---

## Tasks

### [▶] TASK-001: Verify prerequisites
**References**: Plan §2, Plan §4

- [✓] (1) Verify .NET 9.0 SDK is installed on the build machine (`dotnet --list-sdks` contains `9.0.x`) per Plan §2
- [✓] (2) Runtime/SDK version meets minimum requirements (**Verify**)
- [ ] (3) If present, verify `global.json` references .NET 9.0 or is compatible with target SDK per Plan §2 (adjust only configuration if required) 
- [ ] (4) Verify required tooling for client asset management (LibMan/npm) and `dotnet` CLI availability per Plan §5 and Plan §7 (**Verify**)

### [ ] TASK-002: Atomic framework and package upgrade with compilation fixes
**References**: Plan §4, Plan §5, Plan §6

- [ ] (1) Convert `src\eShopLite.StoreFx\eShopLite.StoreFx.csproj` to SDK-style and set `<TargetFramework>net9.0</TargetFramework>` per Plan §4
- [ ] (2) Apply package reference changes (remove incompatible packages, replace or update packages) per Plan §5 (focus: remove `Autofac.Mvc5`, `Microsoft.AspNet.*` packages, replace with ASP.NET Core equivalents, update keepable packages) 
- [ ] (3) Restore dependencies (`dotnet restore`) for solution per Plan §5
- [ ] (4) Build solution to identify compilation errors (`dotnet build`) per Plan §4 and Plan §6
- [ ] (5) Fix all compilation errors arising from framework and package changes (reference Plan §6 Breaking Changes Catalog for remediation steps)
- [ ] (6) Rebuild solution to verify fixes applied
- [ ] (7) Solution builds with 0 errors (**Verify**)

### [ ] TASK-003: Run automated tests and validate upgrade
**References**: Plan §7, Plan §6

- [ ] (1) Run discovered test projects using `dotnet test` per Plan §7 (run only if test projects exist)
- [ ] (2) Fix any test failures (reference Plan §6 Breaking Changes Catalog for common issues)
- [ ] (3) Re-run tests after fixes
- [ ] (4) All tests pass with 0 failures (**Verify**)

### [ ] TASK-004: Final commit
**References**: Plan §10

- [ ] (1) Commit all remaining changes with message: "TASK-004: Complete upgrade to net9.0"


