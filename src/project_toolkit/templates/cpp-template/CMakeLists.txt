# ==============================================================================
# Project Configuration
# ==============================================================================
# Specify the minimum CMake version required to build this project
cmake_minimum_required(VERSION 3.26)

# Define the project name
project(template-cpp)

# ==============================================================================
# C++ Standard Settings
# ==============================================================================
# Set the C++ language standard to C++17
set(CMAKE_CXX_STANDARD 17)

# Require the specified C++ standard (do not allow fallback)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Disable compiler-specific extensions (use strict ISO C++)
set(CMAKE_CXX_EXTENSIONS OFF)

# ==============================================================================
# MSVC Runtime Library Configuration
# ==============================================================================
# Use the static multithreaded runtime library in Debug configuration
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

# Use the static multithreaded runtime library in Release configuration
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Release>:Release>")

# ==============================================================================
# Compiler Flags
# ==============================================================================
# Check if the compiler is Microsoft Visual C++
if(MSVC)

  # Add high warning level and treat warnings as errors for MSVC
  add_compile_options(/W4 /WX)

  # Otherwise, assume GCC/Clang/MinGW
else()

  # Enable common warnings, extra warnings, pedantic mode, and treat warnings as errors
  add_compile_options(-Wall -Wextra -Wpedantic -Werror)

endif()

# ==============================================================================
# Build Configuration
# ==============================================================================
# Generate compile_commands.json for tooling (clangd, clang-tidy, etc.)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set the output directory for executable files
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Set the output directory for static libraries
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Set the output directory for shared libraries
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# ==============================================================================
# Third-party Libraries
# ==============================================================================
# Add Thirdparty library subdirectory
add_subdirectory("lib/fakelib")

# ==============================================================================
# Source Files
# ==============================================================================
# Collect all .cpp source files from the src directory
file(GLOB SOURCES "${CMAKE_SOURCE_DIR}/src/*.cpp")

# ==============================================================================
# Executable Target
# ==============================================================================
# Create an executable using the project name and source files
add_executable(${PROJECT_NAME} ${SOURCES})

# ==============================================================================
# Target Properties
# ==============================================================================
# Add the include directory so headers can be found by the compiler
target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include/
)

# Release only: embed relative path to resources (portable / for release)
# target_compile_definitions(${PROJECT_NAME} PUBLIC
#     RESOURCES_PATH="./resources/"
# )

# Development only: embed absolute path to resources (not portable / not for release)
target_compile_definitions(${PROJECT_NAME} PRIVATE
    RESOURCES_PATH="${CMAKE_CURRENT_SOURCE_DIR}/resources/"
)


# Link internal or third-party libraries to the executable
# target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
#     fakelib
# )

# ==============================================================================
# Windows-specific Configuration
# ==============================================================================
# Check if the target platform is Windows
if(WIN32)

  # Optionally mark the application as a GUI app (no console window)
  # set_target_properties(${PROJECT_NAME} PROPERTIES WIN32_EXECUTABLE TRUE)

  # Link required Windows system libraries
  target_link_libraries(${PROJECT_NAME} PRIVATE
        ole32
        shell32
        shlwapi
        user32
        version
        advapi32
    )

endif()
