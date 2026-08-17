# Check required environment variables
if (-not $env:LAMBDASHARP) {
    Write-Host "ERROR: environment variable `LAMBDASHARP` is not set"
    exit 1
}
if (-not $env:LAMBDASHARP_VERSION) {
    Write-Host "ERROR: environment variable `LAMBDASHARP_VERSION` is not set"
    exit 1
}

# Confirmation prompt
$confirmation = Read-Host -Prompt "Proceed with publishing v{$env:LAMBDASHARP_VERSION}? [y/n]"
if ($confirmation -notin @('y','Y')) {
    Write-Host "Cancelled"
    exit 0
}

function Update {
    Remove-Item "bin\Release\*.nupkg" -Force -ErrorAction SilentlyContinue

    dotnet clean
    dotnet pack --configuration Release

    $nupkgFiles = Get-ChildItem "bin\Release\*.nupkg" -ErrorAction SilentlyContinue
    foreach ($file in $nupkgFiles) {
        dotnet nuget push $file.FullName --skip-duplicate `
            --source "mindtouch-deki/cxe-nuget"
    }
}

# Remove all bin/obj folders from previous builds
Get-ChildItem $env:LAMBDASHARP -Recurse -Directory | Where-Object { $_.Name -in @("bin","obj") } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# List of projects to update
$projects = @(
    "LambdaSharp",
    "LambdaSharp.ApiGateway",
    "LambdaSharp.App",
    "LambdaSharp.CustomResource",
    "LambdaSharp.EventBridge",
    "LambdaSharp.Finalizer",
    "LambdaSharp.Logging",
    "LambdaSharp.Schedule",
    "LambdaSharp.Serialization.NewtonsoftJson",
    "LambdaSharp.SimpleNotificationService",
    "LambdaSharp.SimpleQueueService",
    "LambdaSharp.Slack"
)

foreach ($proj in $projects) {
    Set-Location "$env:LAMBDASHARP\src\$proj"
    Update
}

# LambdaSharp.Tool special handling
Set-Location "$env:LAMBDASHARP\src\LambdaSharp.Tool"
Remove-Item "*.nupkg" -Force -ErrorAction SilentlyContinue

dotnet publish --configuration Release
dotnet pack --configuration Release --output ./

$nupkgFiles = Get-ChildItem "*.nupkg" -ErrorAction SilentlyContinue
foreach ($file in $nupkgFiles) {
    dotnet nuget push $file.FullName --skip-duplicate `
        --source "mindtouch-deki/cxe-nuget"
}