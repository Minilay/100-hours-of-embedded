cmake_minimum_required(VERSION 3.13)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_C_FLAGS "-mcpu=cortex-m0plus -mthumb -O2")
set(CMAKE_EXE_LINKER_FLAGS "-T ${CMAKE_SOURCE_DIR}/minimal.ld -nostdlib -Wl,-Map=${CMAKE_BINARY_DIR}/minimal_startup.map")
project(minimal_startup C)

add_executable(minimal_startup
    startup.c
    main.c
    # bs2_default_padded_checksummed.S.o
)

target_link_options(minimal_startup PRIVATE
    ${CMAKE_SOURCE_DIR}/bs2_default_padded_checksummed.S.o
)

add_custom_command(TARGET minimal_startup POST_BUILD
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:minimal_startup> minimal_startup.bin
    COMMENT "Generating binary"
)