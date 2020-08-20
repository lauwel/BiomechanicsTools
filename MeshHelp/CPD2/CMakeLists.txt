cmake_minimum_required(VERSION 3.8)
project(CPD)

message(STATUS "start running cmake...")

set(CMAKE_CXX_STANDARD 11)

find_package(Matlab REQUIRED MX_LIBRARY)
if(MATLAB_FOUND)
    message("FOUND MATLAB " ${MATLAB_VERSION_STRING})
endif()

include_directories(${Matlab_INCLUDE_DIRS})

add_subdirectory(core)
