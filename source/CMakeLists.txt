
# 
# Configuration for all sub-projects
# 

include(${PROJECT_SOURCE_DIR}/cmake/CheckIntrinsics.cmake)

# 
# Sub-projects
# 

# Libraries
set(IDE_FOLDER "")
add_subdirectory(SSE)
add_subdirectory(AVX)
add_subdirectory(AVX2)
add_subdirectory(AVX512)


# 
# Deployment
# 

