cmake_minimum_required(VERSION 3.14)
project(db-writer)

set(CMAKE_CXX_STANDARD 20)

find_package(Boost REQUIRED COMPONENTS system)
find_package(PkgConfig REQUIRED)
pkg_check_modules(PQXX REQUIRED libpqxx)

add_executable(db-writer src/main.cpp)
target_include_directories(db-writer PRIVATE ${PQXX_INCLUDE_DIRS})
target_link_libraries(db-writer PRIVATE Boost::boost ${PQXX_LIBRARIES})
