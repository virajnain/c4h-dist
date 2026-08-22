# Geant4Config.cmake only sets variables (Geant4_LIBRARIES, Geant4_INCLUDE_DIRS),
# not a modern imported target. Delegate to it explicitly in CONFIG mode
# (bypassing this file to avoid recursion), then synthesize Geant4::Geant4.

find_package(Geant4 CONFIG QUIET)

if(Geant4_FOUND AND NOT TARGET Geant4::Geant4)
    add_library(Geant4::Geant4 INTERFACE IMPORTED)
    target_link_libraries(Geant4::Geant4 INTERFACE ${Geant4_LIBRARIES})
    target_include_directories(Geant4::Geant4 INTERFACE ${Geant4_INCLUDE_DIRS})
    if(Geant4_DEFINITIONS)
        separate_arguments(_geant4_defs UNIX_COMMAND "${Geant4_DEFINITIONS}")
        target_compile_definitions(Geant4::Geant4 INTERFACE ${_geant4_defs})
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Geant4 DEFAULT_MSG Geant4_LIBRARIES Geant4_INCLUDE_DIRS)