cmake_minimum_required(VERSION 3.10)
set(BINARY_NAME "supertonic_flutter")
set(CLASS_NAME "SupertonicFlutterPlugin")

# Project-level configuration.
set(PROJECT_NAME "supertonic_flutter")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "supertonic_flutter_plugin")

add_library(${PLUGIN_NAME} SHARED
  "supertonic_flutter_plugin.cc"
)

# Apply a standard set of build settings.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden
  OUTPUT_NAME "supertonic_flutter"
)

target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_BINARY_DIR}"
)

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

set(PLUGIN_BUNDLED_LIBRARIES "${PLUGIN_BUNDLED_LIBRARIES}" PARENT_SCOPE)
