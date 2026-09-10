# Copyright Spack Project Developers. See COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import os
from spack_repo.builtin.build_systems.cmake import CMakePackage

from spack.package import *


class Code4hep(CMakePackage):

    homepage = "https://github.com/code4hep/Code4hep"
    git = "https://github.com/code4hep/Code4hep.git"

    #maintainers("")

    #license("")
    version("main", branch="main")

    depends_on("c", type="build")
    depends_on("cxx", type="build")
    depends_on("cmake@3.23:", type="build")
    depends_on("python@3:", type=("build", "link"))

    depends_on("root +geom +math")
    depends_on("dd4hep")
    depends_on("edm4hep")
    depends_on("podio")
    depends_on("geant4")
    depends_on("stitched")
    depends_on("k4geo")
    depends_on("lcio")
    depends_on("boost +program_options")
    depends_on("catch2")
    depends_on("py-pybind11")
    depends_on("hepmc3")
    depends_on("pythia8")
    
    def cmake_args(self):
        return [
            self.define("C4H_ENABLE_TIDY", False),
            self.define("CMAKE_MODULE_PATH", os.path.join(self.package_dir, "cmake-modules")),
            self.define("PYTHIA8_ROOT", self.spec["pythia8"].prefix),
        ]
    
    @run_before("cmake")
    def fix_plugin_install(self):
        filter_file(
            "# All plugin .so files must share one directory for edmPluginRefresh.",
            'install(TARGETS ${_target} LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}")\n\n'
            "    # All plugin .so files must share one directory for edmPluginRefresh.",
            "cmake/Code4hepBuildFunctions.cmake",
            string=True,
        )