#!/bin/bash

## Point ModelSim Path
alias vsim17=/opt/Altera/Quartus/17.1/modelsim_ase/linuxaloem/vsim

## OpenCL realated 17.1
export INTELFPGAOCLSDKROOT=/opt/Altera/Quartus/17.1/hld
export PATH=$PATH:$INTELFPGAOCLSDKROOT/bin:$INTELFPGAOCLSDKROOT/host/linux64/lib:$AOCL_BOARD_PACKAGE_ROOT/linux64/lib
export AOCL_BOARD_PACKAGE_ROOT=$INTELFPGAOCLSDKROOT/board/a10_ref
export LD_LIBRARY_PATH=$AOCL_BOARD_PACKAGE_ROOT/linux64/lib:$INTELFPGAOCLSDKROOT/host/linux64/lib
export QUARTUS_ROOTDIR_OVERRIDE=/opt/Altera/Quartus/17.1/quartus
export LM_LICENSE_FILE=2200@bluemountain.eee.hku.hk
