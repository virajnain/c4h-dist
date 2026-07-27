# Copyright Spack Project Developers. See COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack_repo.builtin.build_systems.cmake import CMakePackage

from spack.package import *


class C4hMd5(CMakePackage):
    """Implementation of MD5"""

    homepage = "https://github.com/Dr15Jones/c4h_md5"
    git = "https://github.com/Dr15Jones/c4h_md5.git"

    maintainers("makortel")

    # L. Peter Deutsch / Aladdin Enterprises MD5 license; zlib-like but not exact SPDX Zlib
    license("Permissive", checked_by="makortel")

    depends_on("c", type="build")
    depends_on("cxx", type="build")

    depends_on("cmake@3.15:", type="build")

    version("main", branch="main")
    version("1.0", commit="2afdaea16410ab54c500a38c22617273dfd408dd")

    variant(
        "cxxstd",
        default="17",
        values=("14", "17", "20", "23"),
        multi=False,
        description="C++ standard to use",
    )

    def cmake_args(self):
        return [
            self.define("CMAKE_CXX_STANDARD", self.spec.variants["cxxstd"].value),
            self.define("CMAKE_CXX_STANDARD_REQUIRED", True),
        ]