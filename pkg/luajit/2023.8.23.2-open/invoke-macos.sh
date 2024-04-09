destination="dep/LuaJIT"

output="out"

root="../../.."

invoke_patch() {
    cp $destination/README $destination/README.md
}

invoke_build() {
    cd $destination
    MACOSX_DEPLOYMENT_TARGET=14.4 make
    cd ../..
}

fix_runpath() {
    cd $destination/src
    mv libluajit.so libluajit.dylib
    install_name_tool -add_rpath @loader_path libluajit.dylib
    install_name_tool -id @rpath/libluajit-5.1.2.dylib libluajit.dylib
    cd $root
}

invoke_pack() {
    script_root=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cd $script_root
    nuget pack runtimes.osx-arm64.nuspec -OutputDirectory $root/$output
}

invoke_actions() {
    invoke_patch
    invoke_build
    fix_runpath
    invoke_pack
}

invoke_actions
