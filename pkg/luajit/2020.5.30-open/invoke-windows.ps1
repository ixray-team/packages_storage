$Source      = "https://github.com/LuaJIT/LuaJIT.git"
$Commit      = "f0e865dd4861520258299d0f2a56491bd9d602e1"
$Destination = "dep/LuaJIT/LuaJIT/$Commit"

$Root   = "../../../.."
$Output = "out"

function Invoke-Get {
    if (!(Test-Path -Path "$Destination" -ErrorAction SilentlyContinue)) {
        git clone $Source $Destination
    }
}

function Invoke-Patch {
    Copy-Item -Path $Destination/README -Destination $Destination/README.md

    Set-Location $Destination
    git reset --hard $Commit
    git am --3way --ignore-space-change --keep-cr $PSScriptRoot\0001-Fixed-LuaJit-for-Vanilla.patch
    Set-Location $Root
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
    Invoke-Get
    Invoke-Patch
    Invoke-Build
    Invoke-Pack
}

Invoke-Actions
