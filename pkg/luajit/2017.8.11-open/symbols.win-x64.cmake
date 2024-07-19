if($<CONFIG> STREQUAL "Debug")
    set(LUAJIT_CONFIG "Debug")
elseif($<CONFIG> STREQUAL "Release" OR $<CONFIG> STREQUAL "MinSizeRel" OR $<CONFIG> STREQUAL "RelWithDebInfo")
    set(LUAJIT_CONFIG "Release")
endif()

set(LUAJIT_ROOT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../..")
set(LUAJIT_RUNTIME_ID "win-x64")
set(LUAJIT_RUNTIME_PATH "${LUAJIT_ROOT_PATH}/runtimes/${LUAJIT_RUNTIME_ID}/native/${LUAJIT_CONFIG}")

if(LUAJIT_CONFIG STREQUAL "Debug")
    add_custom_command(TARGET ${PROJECT_NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LUAJIT_RUNTIME_PATH}/lua51.pdb ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/
    )
endif()
