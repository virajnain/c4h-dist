find_path(PYTHIA8_INCLUDE_DIR
    NAMES Pythia8/Pythia.h
    HINTS ${PYTHIA8_ROOT} $ENV{PYTHIA8_ROOT}
    PATH_SUFFIXES include
)

find_library(PYTHIA8_LIBRARY
    NAMES pythia8
    HINTS ${PYTHIA8_ROOT} $ENV{PYTHIA8_ROOT}
    PATH_SUFFIXES lib lib64
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Pythia8 DEFAULT_MSG
    PYTHIA8_LIBRARY PYTHIA8_INCLUDE_DIR)

if(Pythia8_FOUND AND NOT TARGET Pythia8::Pythia8)
    add_library(Pythia8::Pythia8 UNKNOWN IMPORTED)
    set_target_properties(Pythia8::Pythia8 PROPERTIES
        IMPORTED_LOCATION "${PYTHIA8_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${PYTHIA8_INCLUDE_DIR}"
    )
endif()

mark_as_advanced(PYTHIA8_INCLUDE_DIR PYTHIA8_LIBRARY)