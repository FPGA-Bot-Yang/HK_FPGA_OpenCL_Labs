echo $1

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/altera/16.0/quartus/dspba/backend/linux64/
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib/x86_64-linux-gnu

if [ "$1" = "hw" ]; then
	echo "Compiling kernels to generate hardware"
	#aoc  conv_kernel.cl -o bin/conv_kernel.aoco -v -c --report --board de1soc_sharedonly
else
    # compile the host code
	echo "******************* Building host code *******************"
    make
    # compile the kernel code for emulation
	echo "******************* Compiling kernels for emulation ************************"
    aoc -march=emulator device/conv_kernel.cl -o bin/conv_kernel.aocx -v -report -board=a10gx
    # Launch the emulation
	echo "******************* Compiling kernels for emulation ************************"
    env CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 bin/host bin/conv_kernel mnist_test_img_0.pgm
	echo "******************* Genearating Compilation Report ************************"
    aoc -v -c device/conv_kernel.cl -o bin/conv_kernel.aoco
    cp -r bin/conv_kernel/reports/ .

fi
