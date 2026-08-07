#!/bin/bash
# Patches code4hep/build's install/code4hep.sh with all fixes discovered
# during manual debugging. Idempotent-ish: run once against a fresh checkout.
set -euo pipefail

SCRIPT=install/code4hep.sh

# --- Insert XercesC/Catch2 prefix vars + LD_LIBRARY_PATH + locale exports ---
sed -i '/^CODE4HEP_PREFIX=/i XERCESC_PREFIX=$(spack location -i xerces-c)\nCATCH2_PREFIX=$(s>

# --- Force cmake to use Spack's gcc@14, not the system/CVMFS compiler ---
sed -i 's|cmake ../ \\|cmake ../ \\\n  -DCMAKE_C_COMPILER=$(spack location -i gcc@14)/bin/gc>

# --- Point XercesC flags at Spack's build instead of CVMFS/CMSSW's ---
sed -i 's|-DXercesC_INCLUDE_DIR=\$(scram_tag xerces-c INCLUDE)|-DXercesC_INCLUDE_DIR=${XERCE>
sed -i 's|-DXercesC_LIBRARY=\$(scram_tag xerces-c LIBDIR)/libxerces-c.so|-DXercesC_LIBRARY=$>

# --- Point Catch2 at Spack's build ---
sed -i 's|\$(scram_tag catch2 CATCH2_BASE)|${CATCH2_PREFIX}|' "$SCRIPT"

# --- Patch the generated clhep_patch.cmake heredoc: skip re-finding ROOT ---
sed -i 's|  if(_CLHEP_IN_FIND_PACKAGE)|  if("${_package}" STREQUAL "ROOT" AND TARGET ROOT::C>

# --- After cloning Code4hep, patch its known bugs before configuring ---
#     (TestModules plugin lib naming + stale import paths in test .cc files)
sed -i '/^cd Code4hep$/a \
sed -i "/c4h_add_plugin(/a\\\\    NAME Code4hepTestModulesPlugins" TestModules/plugins/CMake>
sed -i "s/from Code4hep\\\\.TestModules\\\\.modules import/from Code4hep.TestModules.plugins>

echo "Patched $SCRIPT successfully."
grep -n "XERCESC_PREFIX=\|CATCH2_PREFIX=\|CMAKE_C_COMPILER=\|CMAKE_CXX_COMPILER=" "$SCRIPT"

