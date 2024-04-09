$Source      = "https://github.com/castano/nvidia-texture-tools.git"
$Commit      = "aeddd65f81d36d8cb7b169b469ef25156666077e"
$Destination = "dep/castano/nvidia-texture-tools/$Commit"

$Root   = "../../../.."
$Output = "out"

function Invoke-Get {
    if (!(Test-Path -Path "$Destination" -ErrorAction SilentlyContinue)) {
        git clone $Source $Destination
    }
}

function Invoke-Patch {
    Set-Location $Destination
    git reset --hard $Commit
    git am --3way --ignore-space-change --keep-cr $PSScriptRoot\0001-Upgrade-toolchain.patch
    git am --3way --ignore-space-change --keep-cr $PSScriptRoot\0002-Delete-conflicting-functions.patch
    Set-Location $Root
}

function Invoke-Build {
    $installer = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    $path      = & $installer -latest -prerelease -property installationPath

    Push-Location "$path\Common7\Tools"
    cmd /c "VsDevCmd.bat&set" |
    ForEach-Object {
        if ($_ -Match "=") {
            $v = $_.Split("=", 2)
            Set-Item -Force -Path "ENV:\$($v[0])" -Value "$($v[1])"
        }
    }
    Pop-Location
    Write-Host "Visual Studio 2022 Command Prompt" -ForegroundColor Yellow

    msbuild $Destination/project/vc2017/nvtt.sln `
        -p:Configuration=Debug `
        -p:Platform=Win32 `
        -maxCpuCount `
        -nologo `
        -v:minimal
    msbuild $Destination/project/vc2017/nvtt.sln `
        -p:Configuration=Release `
        -p:Platform=Win32 `
        -maxCpuCount `
        -nologo `
        -v:minimal
    msbuild $Destination/project/vc2017/nvtt.sln `
        -p:Configuration=Debug `
        -p:Platform=x64 `
        -maxCpuCount `
        -nologo `
        -v:minimal
    msbuild $Destination/project/vc2017/nvtt.sln `
        -p:Configuration=Release `
        -p:Platform=x64 `
        -maxCpuCount `
        -nologo `
        -v:minimal
}

function Invoke-Pack {
    nuget pack $PSScriptRoot\metapackage.nuspec -OutputDirectory $Output

    nuget pack $PSScriptRoot\runtimes.nuspec -OutputDirectory $Output
    nuget pack $PSScriptRoot\runtimes.win-x64.nuspec -OutputDirectory $Output
    nuget pack $PSScriptRoot\runtimes.win-x86.nuspec -OutputDirectory $Output

    nuget pack $PSScriptRoot\symbols.nuspec -OutputDirectory $Output
    nuget pack $PSScriptRoot\symbols.win-x64.nuspec -OutputDirectory $Output
    nuget pack $PSScriptRoot\symbols.win-x86.nuspec -OutputDirectory $Output
}

function Invoke-Actions {
    Invoke-Get
    Invoke-Patch
    Invoke-Build
    Invoke-Pack
}

Invoke-Actions
