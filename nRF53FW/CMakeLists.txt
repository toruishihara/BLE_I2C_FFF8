cmake_minimum_required(VERSION 3.20)
set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
set(hci_ipc_CMAKE_FLAGS "-DCMAKE_POLICY_VERSION_MINIMUM=3.5")

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(si1145_sample)

target_sources(app PRIVATE 
    src/main.c
    src/settings.c
)
