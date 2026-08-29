cmake_minimum_required(VERSION 3.5.0)
project(vpnfd)

add_library(vpnfd SHARED napi_init.cpp)
target_link_libraries(vpnfd PUBLIC libace_napi.z.so)
