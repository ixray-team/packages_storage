source="https://github.com/LuaJIT/LuaJIT.git"
commit="f0e865dd4861520258299d0f2a56491bd9d602e1"
destination="dep/LuaJIT/LuaJIT/$commit"

root="../../../.."
output="out"

invoke_get() {
    if [ ! -d "$destination" ]; then
        mkdir -p $destination
        git clone $source $destination
    fi
}

invoke_patch() {
    script_root=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    cp $destination/README $destination/README.md

    cd $destination
    git reset --hard $commit
    git am --3way --ignore-space-change --keep-cr $script_root/0001-Fixed-LuaJit-for-Vanilla.patch
    cd $root
}

invoke_build() {
    cd $destination
    make
    cd $root
}

fix_runpath() {
    cd $destination/src
    patchelf --set-rpath '$ORIGIN' libluajit.so
    cd ../../../../..
}

invoke_pack() {
    script_root=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cd $script_root
    mono ~/nuget.exe pack runtimes.linux-x64.nuspec -OutputDirectory ../../../$output
}

invoke_actions() {
    invoke_get
    invoke_patch
    invoke_build
    fix_runpath
    invoke_pack
}

invoke_actions
