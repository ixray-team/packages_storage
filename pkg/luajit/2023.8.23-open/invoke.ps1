$Destination = "dep/LuaJIT"

$Output = "out"

function Invoke-Patch {
    Copy-Item -Path $Destination/README -Destination $Destination/README.md
}

function Invoke-Build {
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
    nuget pack $PSScriptRoot\package.nuspec -OutputDirectory $Output
}

function Invoke-Actions {
    Invoke-Patch
    Invoke-Build
    Invoke-Pack
}
