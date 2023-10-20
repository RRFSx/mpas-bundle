#
echo "Loading Spack-Stack 1.5.0"
#
source /etc/profile.d/modules.sh  # note: needed on non-computing nodes
module purge
export LMOD_TMOD_FIND_FIRST=yes
module use /glade/work/jedipara/cheyenne/spack-stack/modulefiles/misc
module load miniconda/3.9.12
module load ecflow/5.8.4
module load mysql/8.0.31

module use /glade/work/epicufsrt/contrib/spack-stack/cheyenne/spack-stack-1.5.0/envs/unified-env/install/modulefiles/Core
module load stack-gcc/10.1.0
module load stack-openmpi/4.1.1
module load stack-python/3.9.12
module load jedi-mpas-env/1.0.0
module list

ulimit -s unlimited
export GFORTRAN_CONVERT_UNIT='big_endian:101-200'

