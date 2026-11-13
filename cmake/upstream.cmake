# 上游接入：botan（configure.py）→ <build>/pkg/prefix。

set(PKG_ROOT "${CMAKE_BINARY_DIR}/pkg")
if(NOT DEFINED PKG_PREFIX)
  set(PKG_PREFIX "${PKG_ROOT}/prefix")
  add_custom_target(pkg ALL
    COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/cmake/pkg-build.sh" "${SRC_DIR}" "${PKG_ROOT}"
    COMMENT "构建上游 botan（${SRC_DIR}）"
    VERBATIM)
  set(HAVE_PKG_TARGET TRUE)
endif()

add_executable(botan_harness test/pkg_botan.cpp)
if(HAVE_PKG_TARGET)
  add_dependencies(botan_harness pkg)
endif()
target_include_directories(botan_harness PRIVATE "${PKG_PREFIX}/include/botan-3")
target_link_directories(botan_harness PRIVATE "${PKG_PREFIX}/lib")
target_link_libraries(botan_harness PRIVATE botan-3)
# Botan 3.x 的头文件是 C++20（concepts/requires），探针必须同步到 C++20
target_compile_features(botan_harness PRIVATE cxx_std_20)
target_compile_options(botan_harness PRIVATE ${RVV_FLAGS})

add_test(NAME botan_harness COMMAND botan_harness)
