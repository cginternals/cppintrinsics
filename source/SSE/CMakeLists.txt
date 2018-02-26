
# 
# External dependencies
# 


# 
# Library name and options
# 

# Target name
set(target SSE)

# Exit here if required dependencies are not met

message(STATUS "Intrinsic ${target}")

# Set API export file and macro
string(MAKE_C_IDENTIFIER ${target} target_id)
string(TOUPPER ${target_id} target_id)


# 
# Create library
# 

# Build library
add_library(${target} INTERFACE)

# Create namespaced alias
add_library(${META_PROJECT_NAME}::${target} ALIAS ${target})

# Export library for downstream projects
export(TARGETS ${target} NAMESPACE ${META_PROJECT_NAME}:: FILE ${PROJECT_BINARY_DIR}/cmake/${target}/${target}-export.cmake)


# 
# Project options
# 

#set_target_properties(${target}
#    PROPERTIES
#    ${DEFAULT_PROJECT_OPTIONS}
#    FOLDER "${IDE_FOLDER}"
#)


# 
# Include directories
# 

target_include_directories(${target}
    INTERFACE
)


# 
# Libraries
# 

target_link_libraries(${target}
    INTERFACE
)

# 
# Compile definitions
# 

target_compile_definitions(${target}
    INTERFACE
)

# 
# Compile options
# 

target_compile_options(${target}
    INTERFACE
)

# 
# Linker options
# 

target_link_libraries(${target}
    INTERFACE
)


# 
# Deployment
# 

# Library
install(TARGETS ${target}
    EXPORT  "${target}-export" COMPONENT dev
)

# CMake config
install(EXPORT ${target}-export
    NAMESPACE   ${META_PROJECT_NAME}::
    DESTINATION ${INSTALL_CMAKE}/${target}
    COMPONENT   dev
)

