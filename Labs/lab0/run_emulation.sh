echo $1

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/altera/16.0/quartus/dspba/backend/linux64/
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib/x86_64-linux-gnu

export AOCL_BOARD_PACKAGE_ROOT=$INTELFPGAOCLSDKROOT/board/a10_ref

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/Altera/Quartus/17.1/hld/board/a10_ref/linux64/lib

if [ "$1" = "hw" ]; then
	echo "Compiling kernels to generate hardware"
	#aoc  conv_kernel.cl -o bin/conv_kernel.aoco -v -c --report --board de1soc_sharedonly
else
    # compile the host code
	echo "******************* Building Host Code *******************"
    make
    # compile the kernel code for emulation
	echo "******************* Compiling Kernels for Emulation ************************"
    aoc -march=emulator device/mmm.cl -o bin/mmm.aocx -v -report -board=a10gx
    # Launch the emulation
	echo "******************* Run Emulation ************************"
    env CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 bin/host
	echo "******************* Genearating Compilation Report ************************"
    aoc -v -c device/mmm.cl -o bin/mmm.aoco
    cp -r bin/mmm/reports/ .

fi
