function Find-NuGetPackagesLocation {
    $output = & ".\nuget.exe" locals global-packages -list
    $location = ($output -replace "global-packages:").Trim()

    Write-Verbose "NuGet Global Packages: $location"
    
    return $location
}

function New-EntityFrameworkCoreDatabaseScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] 
        $StartupAssemblyPath,

        [Parameter(Mandatory = $true)]
        [string] 
        $MigrationsAssemblyPath,
        
        [Parameter(Mandatory = $true)]
        [string]
        $Version,
    
        [Parameter(Mandatory = $true)]
        [string] 
        $OutputPath,

        [Parameter(Mandatory = $false)]
        [switch]
        $Immutable
    )

    $cmd = "migrations script -o `"$OutputPath`""

    if ($Immutable) {
        $cmd += " -i"
    }

    Start-EntityFrameworkCoreOperation -StartupAssemblyPath $StartupAssemblyPath -MigrationsAssemblyPath $MigrationsAssemblyPath -Command $cmd -Version $Version
}

function Update-EntityFrameworkCoreDatabase {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] 
        $StartupAssemblyPath,

        [Parameter(Mandatory = $true)]
        [string] 
        $MigrationsAssemblyPath,

        [Parameter(Mandatory = $true)]
        [string]
        $Version
    )

    $cmd = "database update"
    
    Start-EntityFrameworkCoreOperation -StartupAssemblyPath $StartupAssemblyPath -MigrationsAssemblyPath $MigrationsAssemblyPath -Command $cmd -Version $Version
}

function Start-EntityFrameworkCoreOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] 
        $StartupAssemblyPath,

        [Parameter(Mandatory = $true)]
        [string] 
        $MigrationsAssemblyPath,

        [Parameter(Mandatory = $true)]
        [string]
        $Version,

        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $PackagesDirectory = Find-NuGetPackagesLocation
    $efCoreDllFilePath = ([System.IO.Path]::Combine($PackagesDirectory, "Microsoft.EntityFrameworkCore.Tools", $Version, "tools", "netcoreapp*", "**", "ef.dll") | Resolve-Path).Path
    $dependenciesFilePath = [System.IO.Path]::ChangeExtension($StartupAssemblyPath, ".deps.json")
    $runtimeConfigFilePath = [System.IO.Path]::ChangeExtension($StartupAssemblyPath, ".runtimeconfig.json")

    $efCoreCommand = "dotnet exec --depsfile `"$dependenciesFilePath`" --additionalprobingpath `"$PackagesDirectory`" --runtimeconfig `"$runtimeConfigFilePath`" `"$efCoreDllFilePath`" $Command --assembly `"$MigrationsAssemblyPath`" --startup-assembly `"$StartupAssemblyPath`" --verbose"

    Write-Verbose "Entity Framework Core: $efCoreCommand"
    Invoke-Expression -Command $efCoreCommand
}

Export-ModuleMember -Function Update-EntityFrameworkCoreDatabase, New-EntityFrameworkCoreDatabaseScript
