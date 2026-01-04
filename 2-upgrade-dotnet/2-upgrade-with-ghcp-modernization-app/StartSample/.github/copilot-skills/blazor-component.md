# Skill: Generate Blazor Component

Creates a new Blazor component following eShopLite patterns and best practices.

## Usage
"Generate a Blazor component for [feature] with [requirements]"
"Create a new page component to display [entity]"

## Component Template Structure
```razor
@page "/[route]"
@inject [ApiClient] ApiClient
@inject ILogger<[ComponentName]> Logger
@attribute [Microsoft.AspNetCore.OutputCaching.OutputCache(Duration = 10)]
@rendermode InteractiveServer
@inject IJSRuntime JSRuntime

<PageTitle>[Title] - eShopLite</PageTitle>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="mb-1">
            <i class="bi bi-[icon] text-primary me-2"></i>[Title]
        </h1>
        <p class="text-muted mb-0">[Subtitle]</p>
    </div>
</div>

@if (!string.IsNullOrEmpty(errorMessage))
{
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        @errorMessage
        <button type="button" class="btn-close" @onclick="ClearError" aria-label="Close"></button>
    </div>
}

@if (isLoading)
{
    <div class="text-center py-5">
        <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;">
            <span class="visually-hidden">Loading...</span>
        </div>
        <p class="mt-3 text-muted">Loading data...</p>
    </div>
}
else if (items == null || !items.Any())
{
    <div class="text-center py-5">
        <i class="bi bi-[icon] display-1 text-muted"></i>
        <h3 class="mt-3">No Items Available</h3>
        <button class="btn btn-primary btn-lg" @onclick="LoadData">
            <i class="bi bi-arrow-clockwise me-2"></i>Try Again
        </button>
    </div>
}
else
{
    <!-- Display items -->
}

@code {
    private List<Item>? items;
    private bool isLoading = true;
    private string? errorMessage;

    protected override async Task OnInitializedAsync()
    {
        await LoadData();
    }

    private async Task LoadData()
    {
        try
        {
            isLoading = true;
            errorMessage = null;
            StateHasChanged();

            Logger.LogInformation("Loading {EntityType} data", nameof(Item));
            items = (await ApiClient.GetItemsAsync()).ToList();
            Logger.LogInformation("Successfully loaded {Count} items", items.Count);
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Error loading {EntityType} data", nameof(Item));
            errorMessage = "Unable to load data at this time. Please check if the service is running and try again.";
            items = new List<Item>();
        }
        finally
        {
            isLoading = false;
            StateHasChanged();
        }
    }

    private void ClearError()
    {
        errorMessage = null;
    }
}
```

## Required Elements
- ✅ `@rendermode InteractiveServer` for interactivity
- ✅ `ILogger<T>` injection for logging
- ✅ Loading state (`isLoading`) with spinner
- ✅ Error state (`errorMessage`) with dismissible alert
- ✅ Empty state with helpful message
- ✅ Bootstrap 5.3+ styling and icons
- ✅ Responsive design
- ✅ Proper exception handling
- ✅ StateHasChanged() calls
- ✅ User-friendly error messages

## Grid View Pattern
```razor
<div class="row g-4">
    @foreach (var item in items)
    {
        <div class="col-xl-3 col-lg-4 col-md-6">
            <div class="card h-100 shadow-sm">
                <!-- Card content -->
            </div>
        </div>
    }
</div>
```

## List View Pattern
```razor
<div class="list-group">
    @foreach (var item in items)
    {
        <div class="list-group-item list-group-item-action">
            <div class="row align-items-center">
                <!-- List item content -->
            </div>
        </div>
    }
</div>
```

## Image Handling
```razor
@if (!string.IsNullOrEmpty(item.ImageUrl))
{
    <img src="/images/@item.ImageUrl"
         alt="@item.Name"
         class="img-fluid"
         loading="lazy"
         @onerror="@((args) => HandleImageError(args, item.Id))">
}
else
{
    <div class="bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-image display-4 text-muted"></i>
    </div>
}

@code {
    private void HandleImageError(Microsoft.AspNetCore.Components.Web.ErrorEventArgs args, int id)
    {
        Logger.LogWarning("Failed to load image for item {Id}", id);
    }
}
```

## Examples

### Input
"Generate a Blazor component to display orders with filtering by status"

### Output
Complete Orders.razor component with:
- Order list display (grid and list views)
- Status filter dropdown
- Loading and error states
- Proper logging
- Bootstrap styling
- Responsive design
