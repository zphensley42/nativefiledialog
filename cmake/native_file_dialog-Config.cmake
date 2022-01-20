cmake_minimum_required(VERSION 3.15)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    set(LINUX 1)
endif()

set(SOURCES ${CMAKE_CURRENT_LIST_DIR}/../src/nfd_common.c)

# Add specific implementations
if (WIN32)
    list(APPEND SOURCES ${CMAKE_CURRENT_LIST_DIR}/../src/nfd_win.cpp)
    list(APPEND PREPROCESSOR_DEFINITIONS
            UNICODE
            _UNICODE
            )
elseif (APPLE)
    list(APPEND SOURCES ${CMAKE_CURRENT_LIST_DIR}/../src/nfd_cocoa.m)
elseif (LINUX)
    list(APPEND SOURCES ${CMAKE_CURRENT_LIST_DIR}/../src/nfd_gtk.c)
else()
    message(FATAL_ERROR "Cannot detect your system")
endif()

add_library(native_file_dialog ${SOURCES})
target_include_directories(native_file_dialog PUBLIC ${CMAKE_CURRENT_LIST_DIR}/../src/include)
target_compile_definitions(native_file_dialog PUBLIC ${PREPROCESSOR_DEFINITIONS})

if(LINUX)
    find_package(PkgConfig)
    if (PKG_CONFIG_FOUND)
        pkg_check_modules(GTK "gtk+-3.0")
        if (GTK_FOUND)
            target_link_libraries(native_file_dialog ${GTK_LIBRARIES})
            add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER})
        endif()
    endif()
endif()

add_executable(test_nfd_opendialog ${CMAKE_CURRENT_LIST_DIR}/../test/test_opendialog.c)
add_executable(test_nfd_opendialogmultiple ${CMAKE_CURRENT_LIST_DIR}/../test/test_opendialogmultiple.c)
add_executable(test_nfd_pickfolder ${CMAKE_CURRENT_LIST_DIR}/../test/test_pickfolder.c)
add_executable(test_nfd_savedialog ${CMAKE_CURRENT_LIST_DIR}/../test/test_savedialog.c)

target_link_libraries(test_nfd_opendialog native_file_dialog)
target_link_libraries(test_nfd_opendialogmultiple native_file_dialog)
target_link_libraries(test_nfd_pickfolder native_file_dialog)
target_link_libraries(test_nfd_savedialog native_file_dialog)

install(TARGETS native_file_dialog DESTINATION lib)
