from spack_repo.builtin.build_systems.cmake import CMakePackage

from spack.package import *

class Code4hep(CMakePackage):
    
    homepage = "https://github.com/kpedro88/Code4hep/tree/reorg_cmake2_rebase"
    git = "https://github.com/kpedro88/Code4hep.git"

    #maintainers(???)
    #license("???")
    #version(???)

    depends_on("c", type="build")
    depends_on("cxx", type="build")
    depends_on("cmake@3.23:", type="build")
    depends_on("boost@1.80.0: +program_options", when="@2026-05-28:")
    depends_on("python@3.12.4:")

    depends_on("podio")
    depends_on("edm4hep")
    depends_on("dd4hep")
    depends_on("root +geom +math") #mathmore
    depends_on("nlohmann-json")
    depends_on("catch2")
    depends_on("k4geo")
    depends_on("geant4")
    depends_on("py-pybind11")
    depends_on("stitched")