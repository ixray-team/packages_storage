$Commit      = "6b9769832c43decc53899d7d99801f2bcb1aa92e"
$Destination = "dep/abramcumner/xray16/3rd party/luajit"

$Root   = "../../../../.."
$Output = "out"

function Invoke-Patch {
    Copy-Item -Path $Destination/README -Destination $Destination/README.md

    Set-Location $Destination
    git reset --hard $Commit
    Set-Location $Root
}

function Invoke-Build {
    if (Test-Path -Path "$Destination/out/x64" -ErrorAction SilentlyContinue) {
        Remove-Item -Path "$Destination/out/x64" -Recurse
    }

    New-Item -Name $Destination/out/x64/Debug -ItemType directory
    New-Item -Name $Destination/out/x64/Release -ItemType directory

    & $PSScriptRoot/build-x64-debug.bat
    Move-Item -Path "$Destination/src/*.dll" -Destination "$Destination/out/x64/Debug"
    Move-Item -Path "$Destination/src/*.pdb" -Destination "$Destination/out/x64/Debug"
    Move-Item -Path "$Destination/src/*.lib" -Destination "$Destination/out/x64/Debug"
    Move-Item -Path "$Destination/src/*.exp" -Destination "$Destination/out/x64/Debug"

    & $PSScriptRoot/build-x64-release.bat
    Move-Item -Path "$Destination/src/*.dll" -Destination "$Destination/out/x64/Release"
    Move-Item -Path "$Destination/src/*.lib" -Destination "$Destination/out/x64/Release"
    Move-Item -Path "$Destination/src/*.exp" -Destination "$Destination/out/x64/Release"
}

function Invoke-Pack {
    nuget pack $PSScriptRoot\metapackage.nuspec -OutputDirectory $Output

    nuget pack $PSScriptRoot\runtimes.nuspec -OutputDirectory $Output
    nuget pack $PSScriptRoot\runtimes.win-x64.nuspec -OutputDirectory $Output

    nuget pack $PSScriptRoot\symbols.nuspec -OutputDirectory $Output
    nuget pack $PSScriptRoot\symbols.win-x64.nuspec -OutputDirectory $Output
}

function Invoke-Actions {
    Invoke-Patch
    Invoke-Build
    Invoke-Pack
}

Invoke-Actions
