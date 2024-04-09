destination="dep/LuaJIT"

output="out"

root="../../.."

invoke_patch() {
    cp $destination/README $destination/README.md
}

invoke_build() {
    cd $destination
    make
    cd ../..
}

fix_runpath() {
    cd $destination/src
    patchelf --set-rpath '$ORIGIN' libluajit.so
    cd $root
}

invoke_pack() {
    script_root=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cd $script_root
    mono ~/nuget.exe pack runtimes.linux-x64.nuspec -OutputDirectory $root/$output
}

invoke_actions() {
    invoke_patch
    invoke_build
    fix_runpath
    invoke_pack
}

invoke_actions
