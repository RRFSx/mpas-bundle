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

ecbuild_bundle( PROJECT oops      GIT "https://github.com/JCSDA-internal/oops.git"        TAG a4aa20cccb84a5a3e7af9876885fdac4abd9be98 )
ecbuild_bundle( PROJECT saber     GIT "https://github.com/JCSDA-internal/saber.git"       TAG 4397f9e4357d4cdbc89bd7cd01494373cad93e74 )
ecbuild_bundle( PROJECT crtm      GIT "https://github.com/JCSDA/CRTMv3.git"               TAG 5d5f736288174a0a33af3786bbcc9214d5f6c567 )
option(ENABLE_IODA_DATA "Obtain ioda test data from ioda-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT ioda-data GIT "https://github.com/jcsda-internal/ioda-data.git"   TAG 2ff8d79fc2d7336ff44ab4cca5766b7a36d50aec )
ecbuild_bundle( PROJECT ioda      GIT "https://github.com/jcsda-internal/ioda.git"        TAG 935172bbb45ba49737ebca05adef5e8263c1fbdf )
option(ENABLE_UFO_DATA "Obtain ufo test data from ufo-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT ufo-data  GIT "https://github.com/jcsda-internal/ufo-data.git"    TAG cc6ce782474a8b0763ff96033b57588339716f46 )
ecbuild_bundle( PROJECT ufo       GIT "https://github.com/jcsda-internal/ufo.git"         TAG f5c60a3c8c84a4f8af80544a0d6b311726e46dc2 )


# Find external ESMF for mpas-model (optional)
find_package(ESMF 8.3.0 MODULE)

set(MPAS_DOUBLE_PRECISION "ON" CACHE STRING "MPAS-Model: Use double precision 64-bit Floating point.")
set(MPAS_CORES init_atmosphere atmosphere CACHE STRING "MPAS-Model: cores to build.")

ecbuild_bundle( PROJECT MPAS      GIT "https://github.com/MPAS-Dev/MPAS-Model.git" TAG 82dc4d0e4d8fd17e3848b0d9166eff594d77621a )
option(BUNDLE_SKIP_SACA "Don't build saca"  "ON") # Skip saca build unless user passes -DBUNDLE_SKIP_SACA=OFF
ecbuild_bundle( PROJECT saca      GIT "https://github.com/liujake/SACA.git"              BRANCH develop UPDATE )
option(ENABLE_MPAS_JEDI_DATA "Obtain mpas-jedi test data from mpas-jedi-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT mpas-jedi-data  GIT "https://github.com/jcsda-internal/mpas-jedi-data.git"  BRANCH develop UPDATE )
ecbuild_bundle( PROJECT mpas-jedi GIT "https://github.com/JCSDA-internal/mpas-jedi"      BRANCH feature/MPAS-Model_v8.1 UPDATE )


# Set GIT_BRANCH_FUNC to MPAS-JEDI's current branch so that it can be used for mpas-jedi-data
find_branch_name(REPO_DIR_NAME mpas-jedi)

# If mpas-jedi's current branch is available in mpas-jedi-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME mpas-jedi-data
	BRANCH develop ) #tmp solution for fetching mpas-jedi-data repo. 
			 #This is required because the mpas-jedi dev branch is not being used.
ecbuild_bundle_finalize()
