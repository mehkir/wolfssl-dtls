cmake_minimum_required(VERSION 3.28.3)
project(wolfssl-dtls)

set(CMAKE_CXX_STANDARD 23)

add_executable(main main.cpp)
target_include_directories(main PUBLIC "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}")

add_executable(server-dtls server-dtls13.cpp)
target_include_directories(main PUBLIC "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}")
target_link_libraries(server-dtls PUBLIC wolfssl)

add_executable(client-dtls client-dtls13.cpp)
target_include_directories(main PUBLIC "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}")
target_link_libraries(client-dtls PUBLIC wolfssl)