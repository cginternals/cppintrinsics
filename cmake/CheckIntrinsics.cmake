
include(CheckCSourceRuns)
include(CheckCXXSourceRuns)

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

list(FIND languages "CXX" cxx_enabled)
list(FIND languages "C" c_enabled)
if(cxx_enabled)
  macro(CPPINTRINSICS_CHECK_SOURCE_RUNS code ret_var)
    CHECK_CXX_SOURCE_RUNS("${code}" ${ret_var})
  endmacro()
  set(CPPINTRINSICS_COMPILER_ID ${CMAKE_CXX_COMPILER_ID})
elseif(c_enabled)
  macro(CPPINTRINSICS_CHECK_SOURCE_RUNS code ret_var)
    CHECK_C_SOURCE_RUNS("${code}" ${ret_var})
  endmacro()
  set(CPPINTRINSICS_COMPILER_ID ${CMAKE_C_COMPILER_ID})
else()
  message(WARNING "cppintrinsics are only available when using C or CXX compilers")
  return()
endif()

# save old configuration
set(OLD_CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS})
set(OLD_CMAKE_REQUIRED_QUIET ${CMAKE_REQUIRED_QUIET})

# set flags
set(SSE_FLAGS)
set(AVX_FLAGS)
set(AVX2_FLAGS)
set(AVX512_FLAGS)
if ("${CPPINTRINSICS_COMPILER_ID}" MATCHES "MSVC")
  set(SSE_FLAGS "/arch:SSE")
  set(AVX_FLAGS "/arch:AVX")
  set(AVX2_FLAGS "/arch:AVX2")
  # set(AVX512_FLAGS "/arch:AVX512") found no option for msvc
endif()
if ("${CPPINTRINSICS_COMPILER_ID}" MATCHES "GNU" OR "${CPPINTRINSICS_COMPILER_ID}" MATCHES "Clang")
  set(SSE_FLAGS "-msse")
  set(AVX_FLAGS "-mavx")
  set(AVX2_FLAGS "-mavx2")
  set(AVX512_FLAGS "-mavx512f" "-mavx512cd") # xeon processors have more flags
endif()


#
# Check availability of intrinsics
#

set(CMAKE_REQUIRED_QUIET 1)


# check for SSE
set(SSE_ENABLED 1)
if(NOT SSE_ENABLED)
  set(SSE_FLAGS "")
endif()

# check for AVX
set(CMAKE_REQUIRED_FLAGS ${OLD_CMAKE_REQUIRED_FLAGS} ${AVX_FLAGS})
CPPINTRINSICS_CHECK_SOURCE_RUNS("
    #include <immintrin.h>
    int main(){
      const float src[8] = { 1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f };
      float dst[8];
      __m256 a = _mm256_loadu_ps( src );
      __m256 b = _mm256_add_ps( a, a );
      _mm256_storeu_ps( dst, b );
      for( int i = 0; i < 8; i++ )
        if( ( src[i] + src[i] ) != dst[i] ) return -1;
      return 0;
    }"
    AVX_ENABLED)
# remove flags if cpu does not support AVX
if(NOT AVX_ENABLED)
  set(AVX_FLAGS "")
endif()


# check for AVX2
set(CMAKE_REQUIRED_FLAGS ${OLD_CMAKE_REQUIRED_FLAGS} ${AVX2_FLAGS})
CPPINTRINSICS_CHECK_SOURCE_RUNS("
    #include <immintrin.h>
    int main(){
      const int src[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
      int dst[8];
      __m256i a =  _mm256_loadu_si256( (__m256i*)src );
      __m256i b = _mm256_add_epi32( a, a );
      _mm256_storeu_si256( (__m256i*)dst, b );
      for( int i = 0; i < 8; i++ )
        if( ( src[i] + src[i] ) != dst[i] ) return -1;
      return 0;
    }"
    AVX2_ENABLED)
# remove flags if cpu does not support AVX
if(NOT AVX2_ENABLED)
  set(AVX2_FLAGS "")
endif()


# check for AVX512
set(CMAKE_REQUIRED_FLAGS ${OLD_CMAKE_REQUIRED_FLAGS} ${AVX512_FLAGS})
CPPINTRINSICS_CHECK_SOURCE_RUNS("
    #include <zmmintrin.h>
    int main(){
      const int src[16] = { 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8 };
      int dst[16];
      __m512i a =  _mm512_loadu_si512( (__m512i*)src );
      __m512i b = _mm512_add_epi32( a, a );
      _mm512_storeu_si512( (__m512i*)dst, b );
      for( int i = 0; i < 16; i++ )
        if( ( src[i] + src[i] ) != dst[i] ) return -1;
      return 0;
    }"
    AVX512_ENABLED)
# remove flags if cpu does not support AVX
if(NOT AVX512_ENABLED)
  set(AVX512_FLAGS "")
endif()

# restore previous state of cmake variable
set(CMAKE_REQUIRED_FLAGS ${OLD_CMAKE_REQUIRED_FLAGS})
set(CMAKE_REQUIRED_QUIET ${OLD_CMAKE_REQUIRED_QUIET})

