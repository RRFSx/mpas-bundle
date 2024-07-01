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
set( SNAPSHOT_DATE CACHE STRING "")
if( NOT SNAPSHOT_DATE )
    string(TIMESTAMP SNAPSHOT_DATE "%Y%m%d")
endif()
find_package( ecbuild 3.5 REQUIRED HINTS ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/../ecbuild )
include( ecbuild_bundle )
include( ${CMAKE_SOURCE_DIR}/cmake/git_utils.cmake )
ecbuild_bundle_initialize()
ecbuild_add_fortran_flags(-fcheck=all BUILD Debug)
# Use external jedi-cmake or build in bundle
set( DEVELOP_REPOSITORIES oops saber crtm ioda-data ioda ufo-data ufo mpas-jedi-data )
set( DEVELOP_REPOSITORY_URLS
     "https://github.com/JCSDA-internal/oops.git"
     "https://github.com/JCSDA-internal/saber.git"
     "https://github.com/JCSDA/CRTMv3.git"
     "https://github.com/JCSDA-internal/ioda-data.git"
     "https://github.com/JCSDA-internal/ioda.git"
     "https://github.com/JCSDA-internal/ufo-data.git"
     "https://github.com/JCSDA-internal/ufo.git"
     "https://github.com/JCSDA-internal/mpas-jedi-data.git"
)
list(LENGTH DEVELOP_REPOSITORY_URLS NUM_DEVELOP_REPOS)
set( REPO_INDEX 0 )
while(${REPO_INDEX} LESS ${NUM_DEVELOP_REPOS})
    list(GET DEVELOP_REPOSITORY_URLS ${REPO_INDEX} REPO_URL)
    list(GET DEVELOP_REPOSITORIES ${REPO_INDEX} REPO_NAME)
    find_snapshot_commit_sha(${REPO_URL} ${CMAKE_SOURCE_DIR}/${REPO_NAME} origin develop ${SNAPSHOT_DATE} ${REPO_NAME}_SHA)
    math(EXPR REPO_INDEX "${REPO_INDEX} + 1")
endwhile ()

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

ecbuild_bundle( PROJECT oops      GIT "https://github.com/JCSDA-internal/oops.git"        TAG ${oops_SHA} )
ecbuild_bundle( PROJECT saber     GIT "https://github.com/JCSDA-internal/saber.git"       TAG ${saber_SHA} )
ecbuild_bundle( PROJECT crtm      GIT "https://github.com/JCSDA/CRTMv3.git"               TAG ${crtm_SHA} )
option(ENABLE_IODA_DATA "Obtain ioda test data from ioda-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT ioda-data GIT "https://github.com/jcsda-internal/ioda-data.git"   TAG ${ioda-data_SHA} )
ecbuild_bundle( PROJECT ioda      GIT "https://github.com/jcsda-internal/ioda.git"        TAG ${ioda_SHA} )
option(ENABLE_UFO_DATA "Obtain ufo test data from ufo-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT ufo-data  GIT "https://github.com/jcsda-internal/ufo-data.git"    TAG ${ufo-data_SHA} )
ecbuild_bundle( PROJECT ufo       GIT "https://github.com/jcsda-internal/ufo.git"         TAG ${ufo_SHA} )


# Find external ESMF for mpas-model (optional)
find_package(ESMF 8.3.0 MODULE)

set(MPAS_DOUBLE_PRECISION "ON" CACHE STRING "MPAS-Model: Use double precision 64-bit Floating point.")
set(MPAS_CORES init_atmosphere atmosphere CACHE STRING "MPAS-Model: cores to build.")

ecbuild_bundle( PROJECT MPAS      GIT "https://github.com/amstokely/MPAS-Model" BRANCH atmosphere/fix_cmake UPDATE )
option(BUNDLE_SKIP_SACA "Don't build saca"  "ON") # Skip saca build unless user passes -DBUNDLE_SKIP_SACA=OFF
ecbuild_bundle( PROJECT saca      GIT "https://github.com/liujake/SACA.git"              BRANCH develop UPDATE )
option(ENABLE_MPAS_JEDI_DATA "Obtain mpas-jedi test data from mpas-jedi-data repository (vs tarball)" ON)
ecbuild_bundle( PROJECT mpas-jedi-data  GIT "https://github.com/jcsda-internal/mpas-jedi-data.git" TAG ${mpas-jedi-data_SHA} )
ecbuild_bundle( PROJECT mpas-jedi GIT "https://github.com/JCSDA-internal/mpas-jedi"      BRANCH feature/MPAS-Model_v8.1 )


# Set GIT_BRANCH_FUNC to MPAS-JEDI's current branch so that it can be used for mpas-jedi-data
find_branch_name(REPO_DIR_NAME mpas-jedi)

# If mpas-jedi's current branch is available in mpas-jedi-data repo, that branch will be checked out
branch_checkout (REPO_DIR_NAME mpas-jedi-data
	BRANCH develop ) #tmp solution for fetching mpas-jedi-data repo. 
			 #This is required because the mpas-jedi dev branch is not being used.
ecbuild_bundle_finalize()
configure_file( ${CMAKE_SOURCE_DIR}/cmake/repo_shas.yaml.in ${CMAKE_BINARY_DIR}/repo_shas_${SNAPSHOT_DATE}.yaml @ONLY )

