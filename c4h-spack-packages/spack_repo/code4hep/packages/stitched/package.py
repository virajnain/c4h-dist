# Copyright Spack Project Developers. See COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack_repo.builtin.build_systems.cmake import CMakePackage

from spack.package import *


class Stitched(CMakePackage):
    """Stitched is a data processing framework extracted from CMSSW."""

    homepage = "https://github.com/code4hep/stitched-alpha2"
    git = "https://github.com/code4hep/stitched-alpha2.git"

    maintainers("makortel")

    license("Apache-2.0", checked_by="makortel")

    depends_on("c", type="build")
    depends_on("cxx", type="build")

    depends_on("cmake@3.23:", type="build")
    depends_on("pkg-config", type="build", when="platform=linux") # needed for util-linux-uuid

    depends_on("boost@1.80.0: +program_options +filesystem +serialization", when="@:2026-05-27")
    depends_on("boost@1.80.0: +program_options", when="@2026-05-28:")
    depends_on("intel-tbb@2022.3.0:")
    depends_on("python@3.12.4:")

    # later versions would require changes in the namespacing in the Stitched's CMakeLists.txt
    # TODO: figure out the exact upper limit
    # TODO: upgrade CMakeLists.txt to support later tinyxml2
    depends_on("tinyxml2@6.2.0")

    depends_on("c4h-md5@1.0")
    depends_on("clhep@2.4.7.2:")
    depends_on("py-pybind11@3.0.2:")
    depends_on("cpu-features@0.9.0: +shared")
    depends_on("root@6.36.0:")
    depends_on("util-linux-uuid@2.40:", when="platform=linux")

    # Needed for InitRootHandlers (in case of crashes)
    # We could separate the stack tracing logic from InitRootHandlers
    # and make the dependence on gdb optional
    # Does not build trivially on MacOS, so enable it just for linux for now
    depends_on("gdb", type="run", when="platform=linux")

    version("2026-05-18", commit="45e717a66f9bd50f7734a4863c39687f7946c651")
    version("2026-05-27", commit="efcfa97330dcf9ab81d58e48c40f7f95fa363510")
    version("2026-05-28", commit="1f9f7dc0f4e499687b93458f3fbf02ea747b857e")
    version("2026-06-15", commit="53486de13cecbec085cc992acde3dab968cf88f3")

    variant(
        "cxxstd",
        default="20",
        values=("20", "23"),
        multi=False,
        description="C++ standard to use",
    )

    def cmake_args(self):
        return [
            self.define("CMAKE_CXX_STANDARD", self.spec.variants["cxxstd"].value),
            self.define("CMAKE_CXX_STANDARD_REQUIRED", True),
        ]
