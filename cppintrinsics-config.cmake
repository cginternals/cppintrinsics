
# Exports:
# cppintrinsics::SSE
# cppintrinsics::AVX
# cppintrinsics::AVX2
# cppintrinsics::AVX512
#
# * When linking against these targets, associated CPPINTRINSICS_{MODULE}_ENABLED
#   macros are passed as compile-time definitions and the required compiler flags
#   are added.
# * If the current compiler and architecture doesn't support an intrinsic set,
#   the according target is not defined.

include(${CMAKE_CURRENT_LIST_DIR}/cmake/CheckIntrinsics.cmake)


# List of modules
set(MODULE_NAMES
    SSE
    AVX
    AVX2
    AVX512
)


# Macro to search for a specific module
macro(find_module FILENAME MODULE_NAME)
    if(EXISTS "${FILENAME}" AND "${${MODULE_NAME}_ENABLED}")
        set(MODULE_FOUND TRUE)
        include("${FILENAME}")
        
        if (TARGET cppintrinsics::${MODULE_NAME})
            set_target_properties(cppintrinsics::${MODULE_NAME} PROPERTIES
                INTERFACE_COMPILE_DEFINITIONS "CPPINTRINSICS_${MODULE_NAME}_ENABLED"
                INTERFACE_COMPILE_OPTIONS "${${MODULE_NAME}_FLAGS}"
            )
        endif()
    endif()
endmacro()


# Macro to search for all modules
macro(find_modules PREFIX)
    foreach(module_name ${MODULE_NAMES})
        if(TARGET ${module_name})
            set(MODULE_FOUND TRUE)
        else()
            find_module("${CMAKE_CURRENT_LIST_DIR}/${PREFIX}/${module_name}/${module_name}-export.cmake" ${module_name})
        endif()
    endforeach(module_name)
endmacro()


# Try install location
set(MODULE_FOUND FALSE)
find_modules("cmake")

if(MODULE_FOUND)
    return()
endif()


# Try common build locations
if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    find_modules("build-debug/cmake")
    find_modules("build/cmake")
else()
    find_modules("build/cmake")
    find_modules("build-debug/cmake")
endif()


# Signal success/failure to CMake
set(cppintrinsics_FOUND ${MODULE_FOUND})
