#!/bin/bash
# Patches code4hep/build's install/code4hep.sh with all fixes discovered
# during manual debugging. Idempotent-ish: run once against a fresh checkout.
set -euo pipefail

SCRIPT=install/code4hep.sh

# --- 1. Insert XercesC/Catch2 prefix vars + LD_LIBRARY_PATH + locale exports ---
sed -i '/^CODE4HEP_PREFIX=/i XERCESC_PREFIX=$(spack location -i xerces-c)\nCATCH2_PREFIX=$(spack location -i catch2)\nexport LD_LIBRARY_PATH=${XERCESC_PREFIX}/lib:$LD_LIBRARY_PATH\nexport LANG=en_US.UTF-8\nexport LC_ALL=en_US.UTF-8' "$SCRIPT"

# --- 2. Force cmake to use Spack's gcc@14, not the system/CVMFS compiler ---
sed -i 's|cmake ../ \\|cmake ../ \\\n  -DCMAKE_C_COMPILER=$(spack location -i gcc@14)/bin/gcc \\\n  -DCMAKE_CXX_COMPILER=$(spack location -i gcc@14)/bin/g++ \\|' "$SCRIPT"

# --- 3. Point XercesC flags at Spack's build instead of CVMFS/CMSSW's ---
sed -i 's|-DXercesC_INCLUDE_DIR=\$(scram_tag xerces-c INCLUDE)|-DXercesC_INCLUDE_DIR=${XERCESC_PREFIX}/include|' "$SCRIPT"
sed -i 's|-DXercesC_LIBRARY=\$(scram_tag xerces-c LIBDIR)/libxerces-c.so|-DXercesC_LIBRARY=${XERCESC_PREFIX}/lib/libxerces-c.so|' "$SCRIPT"

# --- 4. Point Catch2 at Spack's build ---
sed -i 's|\$(scram_tag catch2 CATCH2_BASE)|${CATCH2_PREFIX}|' "$SCRIPT"

# --- 5. Patch the generated clhep_patch.cmake heredoc: skip re-finding ROOT ---
sed -i 's|  if(_CLHEP_IN_FIND_PACKAGE)|  if("${_package}" STREQUAL "ROOT" AND TARGET ROOT::Core)\n    message(STATUS "[PATCH] ROOT already found, skipping re-invocation")\n  elseif(_CLHEP_IN_FIND_PACKAGE)|' "$SCRIPT"

# --- 6. After cloning Code4hep, patch its known bugs before configuring ---
#     (TestModules plugin lib naming + stale import paths in test .cc files)
sed -i '/^cd Code4hep$/a \
sed -i "/c4h_add_plugin(/a\\\\    NAME Code4hepTestModulesPlugins" TestModules/plugins/CMakeLists.txt\
sed -i "s/from Code4hep\\\\.TestModules\\\\.modules import/from Code4hep.TestModules.plugins.modules import/" TestModules/test/test_catch2_TestEventHeaderAnalyzer.cc TestModules/test/test_catch2_TestTracksAnalyzer.cc TestModules/test/test_catch2_TestTracksProducer.cc' "$SCRIPT"

echo "Patched $SCRIPT successfully."
grep -n "XERCESC_PREFIX=\|CATCH2_PREFIX=\|CMAKE_C_COMPILER=\|CMAKE_CXX_COMPILER=" "$SCRIPT"