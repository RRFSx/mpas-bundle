# (C) Copyright 2017-2020 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

#
# MPAS/JEDI bundle
#

cmake_minimum_required( VERSION 3.14 )
project( mpas-bundle VERSION 1.0.0 LANGUAGES C CXX Fortran )

## ECBuild integration
include(GNUInstallDirs)
set( INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE STRING "Library installation directory" FORCE ) #Force ecbuild to use the default platform lib install location
set( ECBUILD_DEFAULT_BUILD_TYPE Debug CACHE STRING "ECBuild default build type" FORCE)
set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )
set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )
find_package( ecbuild 3.5 REQUIRED HINTS ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/../ecbuild )
include( ecbuild_bundle )
ecbuild_bundle_initialize()
ecbuild_add_fortran_flags(-fcheck=all BUILD Debug)

# Use external jedi-cmake or build in bundle
if(DEFINED ENV{jedi_cmake_ROOT})
  include( $ENV{jedi_cmake_ROOT}/share/jedicmake/Functions/git_functions.cmake )
  list( APPEND CMAKE_MODULE_PATH $ENV{jedi_cmake_ROOT}/share/jedicmake/Modules )
  message (INFO "CMAKE_MODULE_PATH")
else()
  ecbuild_bundle( PROJECT jedicmake GIT "https://github.com/jcsda-internal/jedi-cmake.git" BRANCH develop UPDATE RECURSIVE )
  include( jedicmake/cmake/Functions/git_functions.cmake )
  list( APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/jedicmake/CMakeModules/Modules )
endif()

option(BUNDLE_SKIP_ECKIT "Don't build eckit" "ON" ) # Skip eckit build unless user passes -DBUNDLE_SKIP_ECKIT=OFF
option(BUNDLE_SKIP_FCKIT "Don't build fckit" "ON" ) # Skip eckit build unless user passes -DBUNDLE_SKIP_FCKIT=OFF
option(BUNDLE_SKIP_ATLAS "Don't build eckit" "ON" ) # Skip atlas build unless user passes -DBUNDLE_SKIP_ATLAS=OFF
ecbuild_bundle( PROJECT eckit     GIT "https://github.com/ecmwf/eckit.git" TAG 1.24.4 )
ecbuild_bundle( PROJECT fckit     GIT "https://github.com/ecmwf/fckit.git" TAG 0.11.0 )
ecbuild_bundle( PROJECT atlas     GIT "https://github.com/ecmwf/atlas.git" TAG 0.34.0 )

#TODO: When mpas-bundle becomes a public repo, consider changing the default value of BUNDLE_SKIP_ROPP-UFO to "ON"
option(BUNDLE_SKIP_ROPP-UFO "Don't build ROPP-UFO"  "OFF") # Build ropp-ufo unless user passes -DBUNDLE_SKIP_ROPP-UFO=ON
ecbuild_bundle( PROJECT ropp-ufo  GIT "https://github.com/JCSDA-internal/ropp-test.git"   BRANCH develop UPDATE )
option(BUNDLE_SKIP_RTTOV "Don't build rttov"  "ON") # Skip rttov build unless user passes -DBUNDLE_SKIP_RTTOV=OFF
ecbuild_bundle( PROJECT rttov     GIT "https://github.com/JCSDA-internal/rttov.git"       BRANCH develop UPDATE )

ecbuild_bundle( PROJECT oops      GIT "https://github.com/JCSDA-internal/oops.git"        TAG 3a5b35668ab4455f4094c069dd148e7352b7911e )
ecbuild_bundle( PROJECT saber     GIT "https://github.com/JCSDA-internal/saber.git"       TAG a2c8e1c78faf045613b7a5c15627e31fe947dc9f )
ecbuild_bundle( PROJECT crtm      GIT "https://github.com/JCSDA/CRTMv3.git"               TAG ec3fa012dc5a6a1d7657dd857eb2a8362ec926d9 )
option(ENABLE_IODA_DATA "Obtain ioda test data from ioda-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT ioda-data GIT "https://github.com/jcsda-internal/ioda-data.git"   TAG 68a4bd3423836a891d589e978e37cb1d4410a2fe )
ecbuild_bundle( PROJECT ioda      GIT "https://github.com/jcsda-internal/ioda.git"        TAG e2217b6537223289f9050ea079469c54cc381463 )
option(ENABLE_UFO_DATA "Obtain ufo test data from ufo-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT ufo-data  GIT "https://github.com/jcsda-internal/ufo-data.git"    TAG 30b969b450a9b51940101e37c6ef86ef91e8ac09 )
ecbuild_bundle( PROJECT ufo       GIT "https://github.com/jcsda-internal/ufo.git"         TAG 088d28d0133a8d3529c842fec33b8a8aa6f0b1cb )


# Find external ESMF for mpas-model (optional)
find_package(ESMF 8.3.0 MODULE)

set(MPAS_DOUBLE_PRECISION "ON" CACHE STRING "MPAS-Model: Use double precision 64-bit Floating point.")
set(MPAS_CORES init_atmosphere atmosphere CACHE STRING "MPAS-Model: cores to build.")

ecbuild_bundle( PROJECT MPAS      GIT "https://github.com/MPAS-Dev/MPAS-Model.git" TAG 82dc4d0e4d8fd17e3848b0d9166eff594d77621a )
option(BUNDLE_SKIP_SACA "Don't build saca"  "ON") # Skip saca build unless user passes -DBUNDLE_SKIP_SACA=OFF
ecbuild_bundle( PROJECT saca      GIT "https://github.com/liujake/SACA.git"              BRANCH develop UPDATE )
option(ENABLE_MPAS_JEDI_DATA "Obtain mpas-jedi test data from mpas-jedi-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT mpas-jedi-data  GIT "https://github.com/jcsda-internal/mpas-jedi-data.git" TAB cd9821633126cb0b4f44d2d3952cd7436f3667db )
ecbuild_bundle( PROJECT mpas-jedi GIT "https://github.com/JCSDA-internal/mpas-jedi"      TAG 7793cb450e548d32dd064da6b744c1fa6ed45195 )


# Set GIT_BRANCH_FUNC to MPAS-JEDI's current branch so that it can be used for mpas-jedi-data
find_branch_name(REPO_DIR_NAME mpas-jedi)

# If mpas-jedi's current branch is available in mpas-jedi-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME mpas-jedi-data
	BRANCH develop ) #tmp solution for fetching mpas-jedi-data repo. 
			 #This is required because the mpas-jedi dev branch is not being used.
ecbuild_bundle_finalize()
