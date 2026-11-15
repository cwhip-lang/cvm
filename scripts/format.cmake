cmake_minimum_required(VERSION 3.24)

# Rewrite the repository's *.cw files in place. cwhip-format reads
# .cwhip-format from the working directory, which is the source root.
if(NOT DEFINED SOURCE_DIR OR SOURCE_DIR STREQUAL "" OR NOT IS_DIRECTORY "${SOURCE_DIR}")
    message(FATAL_ERROR "cwhip-format requires the repository source directory")
endif()

set(cwhip_format_hints)
if(DEFINED CWHIP_SDK_BIN AND NOT CWHIP_SDK_BIN STREQUAL "")
    list(APPEND cwhip_format_hints "${CWHIP_SDK_BIN}")
endif()
if(cwhip_format_hints)
    find_program(CWHIP_FORMAT_EXECUTABLE NAMES cwhip-format HINTS ${cwhip_format_hints})
else()
    find_program(CWHIP_FORMAT_EXECUTABLE NAMES cwhip-format)
endif()
if(NOT CWHIP_FORMAT_EXECUTABLE OR NOT EXISTS "${CWHIP_FORMAT_EXECUTABLE}")
    message(FATAL_ERROR "cwhip-format is not available")
endif()

file(GLOB_RECURSE cvm_format_sources LIST_DIRECTORIES false "${SOURCE_DIR}/*.cw")
cmake_path(SET cvm_format_source_root NORMALIZE "${SOURCE_DIR}")
set(cvm_format_binary_root "")
if(DEFINED BINARY_DIR AND NOT BINARY_DIR STREQUAL "")
    cmake_path(SET cvm_format_binary_root NORMALIZE "${BINARY_DIR}")
endif()
cmake_path(SET cvm_format_named_build NORMALIZE "${cvm_format_source_root}/build")

set(cvm_format_inputs)
foreach(cvm_format_source IN LISTS cvm_format_sources)
    cmake_path(SET cvm_format_absolute NORMALIZE "${cvm_format_source}")
    set(cvm_format_skip FALSE)
    if(NOT cvm_format_binary_root STREQUAL ""
            AND NOT cvm_format_binary_root PATH_EQUAL cvm_format_source_root)
        cmake_path(IS_PREFIX cvm_format_binary_root "${cvm_format_absolute}"
            cvm_format_in_binary)
        if(cvm_format_in_binary)
            set(cvm_format_skip TRUE)
        endif()
    endif()
    cmake_path(IS_PREFIX cvm_format_named_build "${cvm_format_absolute}"
        cvm_format_in_named_build)
    if(cvm_format_in_named_build)
        set(cvm_format_skip TRUE)
    endif()
    if(cvm_format_skip)
        continue()
    endif()
    file(RELATIVE_PATH cvm_format_relative
        "${cvm_format_source_root}" "${cvm_format_absolute}")
    if(cvm_format_relative STREQUAL "" OR cvm_format_relative MATCHES "^\\.\\./")
        continue()
    endif()
    list(APPEND cvm_format_inputs "${cvm_format_relative}")
endforeach()
list(SORT cvm_format_inputs COMPARE STRING)

if(NOT cvm_format_inputs)
    message(FATAL_ERROR "cwhip-format found no Cwhip sources to format")
endif()

execute_process(
    COMMAND "${CWHIP_FORMAT_EXECUTABLE}" -i ${cvm_format_inputs}
    WORKING_DIRECTORY "${cvm_format_source_root}"
    RESULT_VARIABLE cvm_format_result)
if(NOT cvm_format_result EQUAL 0)
    message(FATAL_ERROR "cwhip-format failed with status ${cvm_format_result}")
endif()
