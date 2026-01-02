# Projects and dependencies analysis

This document provides a comprehensive overview of the projects and their dependencies in the context of upgrading to .NETCoreApp,Version=v9.0.

## Table of Contents

- [Executive Summary](#executive-Summary)
  - [Highlevel Metrics](#highlevel-metrics)
  - [Projects Compatibility](#projects-compatibility)
  - [Package Compatibility](#package-compatibility)
  - [API Compatibility](#api-compatibility)
- [Aggregate NuGet packages details](#aggregate-nuget-packages-details)
- [Top API Migration Challenges](#top-api-migration-challenges)
  - [Technologies and Features](#technologies-and-features)
  - [Most Frequent API Issues](#most-frequent-api-issues)
- [Projects Relationship Graph](#projects-relationship-graph)
- [Project Details](#project-details)

  - [src\eShopLite.StoreFx\eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj)


## Executive Summary

### Highlevel Metrics

| Metric | Count | Status |
| :--- | :---: | :--- |
| Total Projects | 1 | All require upgrade |
| Total NuGet Packages | 24 | 5 need upgrade |
| Total Code Files | 16 |  |
| Total Code Files with Incidents | 3 |  |
| Total Lines of Code | 512 |  |
| Total Number of Issues | 19 |  |
| Estimated LOC to modify | 0+ | at least 0.0% of codebase |

### Projects Compatibility

| Project | Target Framework | Difficulty | Package Issues | API Issues | Est. LOC Impact | Description |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| [src\eShopLite.StoreFx\eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | net48 | 🔴 High | 15 | 0 |  | Wap, Sdk Style = False |

### Package Compatibility

| Status | Count | Percentage |
| :--- | :---: | :---: |
| ✅ Compatible | 19 | 79.2% |
| ⚠️ Incompatible | 2 | 8.3% |
| 🔄 Upgrade Recommended | 3 | 12.5% |
| ***Total NuGet Packages*** | ***24*** | ***100%*** |

### API Compatibility

| Category | Count | Impact |
| :--- | :---: | :--- |
| 🔴 Binary Incompatible | 0 | High - Require code changes |
| 🟡 Source Incompatible | 0 | Medium - Needs re-compilation and potential conflicting API error fixing |
| 🔵 Behavioral change | 0 | Low - Behavioral changes that may require testing at runtime |
| ✅ Compatible | 0 |  |
| ***Total APIs Analyzed*** | ***0*** |  |

## Aggregate NuGet packages details

| Package | Current Version | Suggested Version | Projects | Description |
| :--- | :---: | :---: | :--- | :--- |
| Antlr | 3.5.0.2 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | Needs to be replaced with Replace with new package Antlr4=4.6.6 |
| Autofac | 8.3.0 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ✅Compatible |
| Autofac.Mvc5 | 6.1.0 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ⚠️NuGet package is incompatible |
| bootstrap | 5.3.7 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ✅Compatible |
| EntityFramework | 6.5.1 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ✅Compatible |
| jQuery | 3.7.1 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ✅Compatible |
| jQuery.Validation | 1.21.0 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ✅Compatible |
| Microsoft.AspNet.Mvc | 5.3.0 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package functionality is included with framework reference |
| Microsoft.AspNet.Razor | 3.3.0 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package functionality is included with framework reference |
| Microsoft.AspNet.Web.Optimization | 1.1.3 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ⚠️NuGet package is incompatible |
| Microsoft.AspNet.WebPages | 3.3.0 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package functionality is included with framework reference |
| Microsoft.Bcl.AsyncInterfaces | 9.0.7 | 9.0.11 | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package upgrade is recommended |
| Microsoft.CodeDom.Providers.DotNetCompilerPlatform | 4.1.0 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package functionality is included with framework reference |
| Microsoft.jQuery.Unobtrusive.Validation | 4.0.0 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ✅Compatible |
| Microsoft.Web.Infrastructure | 2.0.0 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package functionality is included with framework reference |
| Modernizr | 2.8.3 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ✅Compatible |
| Newtonsoft.Json | 13.0.3 | 13.0.4 | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package upgrade is recommended |
| System.Buffers | 4.6.1 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package functionality is included with framework reference |
| System.Diagnostics.DiagnosticSource | 9.0.7 | 9.0.11 | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package upgrade is recommended |
| System.Memory | 4.6.3 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package functionality is included with framework reference |
| System.Numerics.Vectors | 4.6.1 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package functionality is included with framework reference |
| System.Runtime.CompilerServices.Unsafe | 6.1.2 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ✅Compatible |
| System.Threading.Tasks.Extensions | 4.6.3 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | NuGet package functionality is included with framework reference |
| WebGrease | 1.6.0 |  | [eShopLite.StoreFx.csproj](#srceshoplitestorefxeshoplitestorefxcsproj) | ✅Compatible |

## Top API Migration Challenges

### Technologies and Features

| Technology | Issues | Percentage | Migration Path |
| :--- | :---: | :---: | :--- |

### Most Frequent API Issues

| API | Count | Percentage | Category |
| :--- | :---: | :---: | :--- |

## Projects Relationship Graph

Legend:
📦 SDK-style project
⚙️ Classic project

```mermaid
flowchart LR
    P1["<b>⚙️&nbsp;eShopLite.StoreFx.csproj</b><br/><small>net48</small>"]
    click P1 "#srceshoplitestorefxeshoplitestorefxcsproj"

```

## Project Details

<a id="srceshoplitestorefxeshoplitestorefxcsproj"></a>
### src\eShopLite.StoreFx\eShopLite.StoreFx.csproj

#### Project Info

- **Current Target Framework:** net48
- **Proposed Target Framework:** net9.0
- **SDK-style**: False
- **Project Kind:** Wap
- **Dependencies**: 0
- **Dependants**: 0
- **Number of Files**: 87
- **Number of Files with Incidents**: 3
- **Lines of Code**: 512
- **Estimated LOC to modify**: 0+ (at least 0.0% of the project)

#### Dependency Graph

Legend:
📦 SDK-style project
⚙️ Classic project

```mermaid
flowchart TB
    subgraph current["eShopLite.StoreFx.csproj"]
        MAIN["<b>⚙️&nbsp;eShopLite.StoreFx.csproj</b><br/><small>net48</small>"]
        click MAIN "#srceshoplitestorefxeshoplitestorefxcsproj"
    end

```

### API Compatibility

| Category | Count | Impact |
| :--- | :---: | :--- |
| 🔴 Binary Incompatible | 0 | High - Require code changes |
| 🟡 Source Incompatible | 0 | Medium - Needs re-compilation and potential conflicting API error fixing |
| 🔵 Behavioral change | 0 | Low - Behavioral changes that may require testing at runtime |
| ✅ Compatible | 0 |  |
| ***Total APIs Analyzed*** | ***0*** |  |

