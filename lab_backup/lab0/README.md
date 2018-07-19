## Description
This lab involves implementation of simple 2D convolution kernel commanly used in Convolutional Neural Networks(CNN) using OpenCL for Altera FPGAs. The conv_2d kernel does not contain complete loop unrolling, memory optimizations, and is limited to one computation unit. Subsequent labs will explore each of these in turn.

- This implementation is fixed for image and filter size, because we will buffer the entire image into on-chip(local)memory and then perform computations. Hence, the max image resolution is limited by the FPGA resources.
- The local work size is equal to gloal work size in all dimensions because we copy the entire image in a single work group.
- Each work item will copy a single pixel from the global memory into the local memory and wait for all other work items to finish copying their respective pixels.
- The read process is pipelined across all work items and thus the AOCL tool can optimize the HW to issue outstanding memory requests.
- The computation involves reading the pixels from 3x3 window and performing dot-product. Even the compute loop is unrolled and pipelined to perform parallel and pipelined computations within the work item. For example, reading pixels from the local BRAM can be overlapped with the MAC operation. Pipelining hint allows the tool to generate such hardware.

## Steps to run
## Kernel emulation
./compile_and_run.sh to compile the kernel for emulation (a10_ref emulation target)

## Kernel HW
./compile_kernels.sh hw to compile the kernel for FPGA target and run the kernel on an actual FPGA board
