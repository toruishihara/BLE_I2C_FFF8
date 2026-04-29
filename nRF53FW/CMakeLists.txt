cmake_minimum_required(VERSION 3.20)

# If the policy is passed via -D on the command line, 
# set it as an environment variable so child images inherit it.
if(CMAKE_POLICY_VERSION_MINIMUM)
    set(ENV{CMAKE_POLICY_VERSION_MINIMUM} ${CMAKE_POLICY_VERSION_MINIMUM})
endif()

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(si1145_sample)

target_sources(app PRIVATE 
    src/main.c
    src/settings.c
)
