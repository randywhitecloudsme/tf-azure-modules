# Terraform Module Validation Script
# Validates all modules in the modules/ directory

param(
    [string]$ModulePath = "modules",
    [switch]$Fix,
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$results = @()

function Write-Status {
    param($Message, $Type = "Info")
    $color = switch ($Type) {
        "Success" { "Green" }
        "Error" { "Red" }
        "Warning" { "Yellow" }
        default { "White" }
    }
    Write-Host $Message -ForegroundColor $color
}

function Test-TerraformModule {
    param(
        [string]$Path,
        [string]$ModuleName
    )

    $result = [PSCustomObject]@{
        Module = $ModuleName
        Init = "Not Run"
        Validate = "Not Run"
        Format = "Not Run"
        Errors = @()
    }

    Write-Status "`n========================================" "Info"
    Write-Status "Validating: $ModuleName" "Info"
    Write-Status "========================================" "Info"

    Push-Location $Path

    try {
        # Terraform Init
        Write-Status "Running terraform init..." "Info"
        $initOutput = terraform init -backend=false 2>&1
        if ($LASTEXITCODE -eq 0) {
            $result.Init = "✓ Pass"
            Write-Status "  ✓ Init successful" "Success"
        } else {
            $result.Init = "✗ Fail"
            $result.Errors += "Init failed: $initOutput"
            Write-Status "  ✗ Init failed" "Error"
            if ($Verbose) { Write-Host $initOutput }
        }

        # Terraform Validate
        Write-Status "Running terraform validate..." "Info"
        $validateOutput = terraform validate 2>&1
        if ($LASTEXITCODE -eq 0) {
            $result.Validate = "✓ Pass"
            Write-Status "  ✓ Validation successful" "Success"
        } else {
            $result.Validate = "✗ Fail"
            $result.Errors += "Validation failed: $validateOutput"
            Write-Status "  ✗ Validation failed" "Error"
            if ($Verbose) { Write-Host $validateOutput }
        }

        # Terraform Format Check
        Write-Status "Running terraform fmt -check..." "Info"
        $fmtOutput = terraform fmt -check -recursive 2>&1
        if ($LASTEXITCODE -eq 0) {
            $result.Format = "✓ Pass"
            Write-Status "  ✓ Format check passed" "Success"
        } else {
            $result.Format = "⚠ Needs formatting"
            Write-Status "  ⚠ Files need formatting" "Warning"
            if ($Fix) {
                Write-Status "  Fixing formatting..." "Info"
                terraform fmt -recursive
                $result.Format = "✓ Fixed"
                Write-Status "  ✓ Formatting applied" "Success"
            }
        }

    } catch {
        $result.Errors += "Exception: $_"
        Write-Status "  ✗ Exception occurred: $_" "Error"
    } finally {
        Pop-Location
    }

    return $result
}

# Main execution
Write-Status "`n╔════════════════════════════════════════╗" "Info"
Write-Status "║  Terraform Module Validation Report   ║" "Info"
Write-Status "╚════════════════════════════════════════╝`n" "Info"

# Get all module directories
$moduleDirs = Get-ChildItem -Path $ModulePath -Directory | Where-Object { 
    Test-Path (Join-Path $_.FullName "main.tf") 
}

if ($moduleDirs.Count -eq 0) {
    Write-Status "No modules found in $ModulePath" "Error"
    exit 1
}

Write-Status "Found $($moduleDirs.Count) modules to validate`n" "Info"

# Validate each module
foreach ($moduleDir in $moduleDirs) {
    $result = Test-TerraformModule -Path $moduleDir.FullName -ModuleName $moduleDir.Name
    $results += $result
}

# Summary Report
Write-Status "`n`n╔════════════════════════════════════════╗" "Info"
Write-Status "║         Validation Summary             ║" "Info"
Write-Status "╚════════════════════════════════════════╝`n" "Info"

$results | Format-Table -AutoSize Module, Init, Validate, Format

# Error Details
$failedModules = $results | Where-Object { $_.Errors.Count -gt 0 }
if ($failedModules.Count -gt 0) {
    Write-Status "`n╔════════════════════════════════════════╗" "Error"
    Write-Status "║           Error Details                ║" "Error"
    Write-Status "╚════════════════════════════════════════╝`n" "Error"
    
    foreach ($module in $failedModules) {
        Write-Status "`nModule: $($module.Module)" "Error"
        foreach ($error in $module.Errors) {
            Write-Status "  $error" "Error"
        }
    }
}

# Final Summary
$passCount = ($results | Where-Object { $_.Validate -eq "✓ Pass" }).Count
$failCount = ($results | Where-Object { $_.Validate -eq "✗ Fail" }).Count
$totalCount = $results.Count

Write-Status "`n`n========================================" "Info"
Write-Status "Results: $passCount/$totalCount modules passed" $(if ($failCount -eq 0) { "Success" } else { "Error" })
Write-Status "========================================`n" "Info"

if ($failCount -gt 0) {
    exit 1
}
