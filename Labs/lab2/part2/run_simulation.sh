# Change the OpenCL board support package path to the custom BSP
export AOCL_BOARD_PACKAGE_ROOT=$INTELFPGAOCLSDKROOT/board/simBSP
# Copy the kernel code
cp device/mmm.cl .
# compile the kernel code for emulation
echo "******************* Compiling Kernels for Simulation ************************"
aoc -v mmm.cl
# Launch the simulation
echo "******************* Run Emulation ************************"
cd mmm/kernel_system_tb/kernel_system_tb/sim/mentor
vsim17 &

