$Destination = "dep/LuaJIT"

$Output = "out"

function Invoke-Patch {
    Copy-Item -Path $Destination/README -Destination $Destination/README.md
}

function Invoke-Build {
    if (Test-Path -Path "$Destination/out/x86" -ErrorAction SilentlyContinue) {
        Remove-Item -Path "$Destination/out/x86" -Recurse
    }
    if (Test-Path -Path "$Destination/out/x64" -ErrorAction SilentlyContinue) {
        Remove-Item -Path "$Destination/out/x64" -Recurse
    }

    New-Item -Name $Destination/out/x86 -ItemType directory
    New-Item -Name $Destination/out/x64 -ItemType directory

    & $PSScriptRoot/build-x86.bat
    Move-Item -Path "$Destination/src/*.dll" -Destination "$Destination/out/x86/"
    Move-Item -Path "$Destination/src/*.lib" -Destination "$Destination/out/x86/"
    Move-Item -Path "$Destination/src/*.exp" -Destination "$Destination/out/x86/"

    & $PSScriptRoot/build-x64.bat
    Move-Item -Path "$Destination/src/*.dll" -Destination "$Destination/out/x64/"
    Move-Item -Path "$Destination/src/*.lib" -Destination "$Destination/out/x64/"
    Move-Item -Path "$Destination/src/*.exp" -Destination "$Destination/out/x64/"
}

function Invoke-Pack {
    nuget pack $PSScriptRoot\metapackage.nuspec -OutputDirectory $Output

    nuget pack $PSScriptRoot\runtimes.nuspec -OutputDirectory $Output
    nuget pack $PSScriptRoot\runtimes.win-x64.nuspec -OutputDirectory $Output
    nuget pack $PSScriptRoot\runtimes.win-x86.nuspec -OutputDirectory $Output
}

function Invoke-Actions {
    Invoke-Patch
    Invoke-Build
    Invoke-Pack
}

Invoke-Actions
