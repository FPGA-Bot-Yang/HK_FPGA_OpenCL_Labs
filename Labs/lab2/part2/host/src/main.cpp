/*******************************************************************************
Vendor: Xilinx
Associated Filename: main.c
#Purpose: An example showing new kernels can be downloaded to FPGA while keeping
#         the data in device memory intact
#*******************************************************************************
Copyright (c) 2016, Xilinx, Inc.^M
All rights reserved.^M
^M
Redistribution and use in source and binary forms, with or without modification, ^M
are permitted provided that the following conditions are met:^M
^M
1. Redistributions of source code must retain the above copyright notice, ^M
this list of conditions and the following disclaimer.^M
^M
2. Redistributions in binary form must reproduce the above copyright notice, ^M
this list of conditions and the following disclaimer in the documentation ^M
and/or other materials provided with the distribution.^M
^M
3. Neither the name of the copyright holder nor the names of its contributors ^M
may be used to endorse or promote products derived from this software ^M
without specific prior written permission.^M
^M
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ^M
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, ^M
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. ^M
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, ^M
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, ^M
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ^M
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, ^M
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, ^M
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*******************************************************************************/
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <complex>
#include "CL/opencl.h"
#include "AOCLUtils/aocl_utils.h"



using namespace aocl_utils;
using namespace std;
////////////////////////////////////////////////////////////////////////////////

#define NUM_ARRAYS 3  //changing this will result in longer emulation time
#define ARRAY_SIZE 8 // do not change, kernels are made for this spec
#define MAX_FLOAT 100.0
#define TOL 10.0
#define KERNELNAME "mmm"
////////////////////////////////////////////////////////////////////////////////

void setArrays(float * real, float *img){
  srand(6);
  float max = (float) MAX_FLOAT;
  for(int i=0; i<NUM_ARRAYS; i++)
    for(int j=0; j<ARRAY_SIZE; j++){
      real[i*ARRAY_SIZE+j] = max*(float)(rand()/(float)RAND_MAX);
      img[i*ARRAY_SIZE+j] = max*(float)(rand()/(float)RAND_MAX);
    }
}
// Function headers for host-side fft
int log2(int N);
int reverse(int N, int n);
void ordina(complex<float>* f1, int N);
void transform(complex<float>* f, int N);
void FFT(complex<float>* f, int N, double d);
void cleanup();

int main(int argc, char** argv)
{
    int err;                            // error code returned from api calls
    int test_fail = 0;

    string kernel_name = KERNELNAME;
    string kernel_name_aocx = KERNELNAME ".aocx";

    float * in_real  = (float *) malloc(sizeof(float) *NUM_ARRAYS*ARRAY_SIZE);
    float * in_img   = (float *) malloc(sizeof(float) *NUM_ARRAYS*ARRAY_SIZE);
    float * out_real_kernel = (float *) malloc(sizeof(float) *NUM_ARRAYS*ARRAY_SIZE);
    float * out_img_kernel  = (float *) malloc(sizeof(float) *NUM_ARRAYS*ARRAY_SIZE);
    float * out_real_host   = (float *) malloc(sizeof(float) *NUM_ARRAYS*ARRAY_SIZE);
    float * out_img_host    = (float *) malloc(sizeof(float) *NUM_ARRAYS*ARRAY_SIZE);
	int * N = (int *) malloc(sizeof(int));
	*N = NUM_ARRAYS;

    setArrays(in_real,in_img);
    

    cl_platform_id platform_id;         // platform id
    cl_device_id device_id;             // compute device id
    cl_context context;                 // compute context
    cl_command_queue commands;          // compute command queue
    cl_program program;                 // compute program
    cl_kernel kernel;                   // compute kernel

    char cl_platform_vendor[1001];
    char cl_platform_name[1001];

    cl_mem in_real_cl_mem;                 
    cl_mem in_img_cl_mem;                 
    cl_mem out_real_kernel_cl_mem;
    cl_mem out_img_kernel_cl_mem;
	cl_mem N_cl_mem;

    printf("Application start\n");
    const double start_time = getCurrentTimestamp();
    

    // Connect to first platform
    err = clGetPlatformIDs(1,&platform_id,NULL);
    if (err != CL_SUCCESS) {
        printf("Error: Failed to find an OpenCL platform!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }
    err = clGetPlatformInfo(platform_id,CL_PLATFORM_VENDOR,1000,(void *)cl_platform_vendor,NULL);
    if (err != CL_SUCCESS) {
        printf("Error: clGetPlatformInfo(CL_PLATFORM_VENDOR) failed!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }
    printf("INFO: CL_PLATFORM_VENDOR %s\n",cl_platform_vendor);
    err = clGetPlatformInfo(platform_id,CL_PLATFORM_NAME,1000,(void *)cl_platform_name,NULL);
    if (err != CL_SUCCESS) {
        printf("Error: clGetPlatformInfo(CL_PLATFORM_NAME) failed!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }
    printf("INFO: CL_PLATFORM_NAME %s\n",cl_platform_name);

    // Connect to a compute device
    err = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_ACCELERATOR,
                         1, &device_id, NULL);
    if (err != CL_SUCCESS) {
            printf("Error: Failed to create a device group!\n");
            printf("Test failed\n");
            return EXIT_FAILURE;
        }
	
    // Create a compute context
    context = clCreateContext(0, 1, &device_id, NULL, NULL, &err);
    if (!context) {
        printf("Error: Failed to create a compute context!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // Create a command commands
    commands = clCreateCommandQueue(context, device_id, 0, &err);
    if (!commands) {
        printf("Error: Failed to create a command commands!\n");
        printf("Error: code %i\n",err);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    int status;

    // Create Program Objects

    // Load binary from disk

    std::string binary_file = getBoardBinaryFile(argv[1], device_id);
    printf("Using AOCX: %s\n", binary_file.c_str());
    program = createProgramFromBinary(context, binary_file.c_str(), &device_id, 1);

    if ((!program) || (err!=CL_SUCCESS)) {
        printf("Error: Failed to create compute program from binary %d!\n", err);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // Build the program executable
    err = clBuildProgram(program, 0, NULL, "", NULL, NULL);
    if (err != CL_SUCCESS) {
        size_t len;
        char buffer[2048];

        printf("Error: Failed to build program executable!\n");
        clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
        printf("%s\n", buffer);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // Create the compute kernel in the program we wish to run
    kernel = clCreateKernel(program, kernel_name.c_str(), &err);
    checkError(err,"creating kernel");

    // Create the input and output arrays in device memory for our calculation
    in_real_cl_mem = clCreateBuffer(context,  CL_MEM_READ_ONLY,  sizeof(float) *ARRAY_SIZE*NUM_ARRAYS, NULL, &err);
     checkError(err,"creating buffer for in_real");
    in_img_cl_mem = clCreateBuffer(context,  CL_MEM_READ_ONLY,  sizeof(float) * ARRAY_SIZE*NUM_ARRAYS, NULL, &err);
    checkError(err,"creating buffer for in_img");
    out_real_kernel_cl_mem = clCreateBuffer(context, CL_MEM_READ_WRITE,  sizeof(float)*ARRAY_SIZE*NUM_ARRAYS, NULL, &err);
     checkError(err,"creating buffer for out_real");
    out_img_kernel_cl_mem = clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(float) *ARRAY_SIZE*NUM_ARRAYS,NULL,&err);
     checkError(err,"creating buffer for out_img");
	N_cl_mem = clCreateBuffer(context,CL_MEM_READ_ONLY,sizeof(int),NULL,&err);
	checkError(err,"Creating buffer for N");
   

    // Write the image from host buffer to device memory
     err = clEnqueueWriteBuffer(commands, in_real_cl_mem, CL_TRUE, 0,  sizeof(float) *ARRAY_SIZE*NUM_ARRAYS,in_real, 0, NULL, NULL);
    checkError(err,"enqueuing write for in_Real");
    // Write filter kernel into device buffer
    //
    err = clEnqueueWriteBuffer(commands, in_img_cl_mem, CL_TRUE, 0,  sizeof(float) *ARRAY_SIZE*NUM_ARRAYS,in_img, 0, NULL, NULL);
    checkError(err,"enqueueing write for in_img");

	err = clEnqueueWriteBuffer(commands,N_cl_mem,CL_TRUE,0,sizeof(int),N,0,NULL,NULL);
	checkError(err,"enqueueing write for N");

    // Set the arguments to our compute kernel
    err  = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *) &in_real_cl_mem);
    checkError(err,"set kernel arg 0");
    err = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *) &in_img_cl_mem);
    checkError(err,"kernel arg 1");
    err = clSetKernelArg(kernel, 2, sizeof(cl_mem), (void *) &out_real_kernel_cl_mem);
    checkError(err,"kernel arg 2");
    err = clSetKernelArg(kernel, 3, sizeof(cl_mem), (void *) &out_img_kernel_cl_mem);
    checkError(err,"kernel arg 3");
    err =clSetKernelArg(kernel,4,sizeof(cl_mem),(void *) &N_cl_mem);
    checkError(err,"kernel arg 4");
 
    size_t swi[2] = {1,1};
    
    err = clEnqueueNDRangeKernel(commands, kernel, 1, NULL, swi,swi, 0, NULL, NULL);
    checkError(err,"enqueueing kernel");
    err = clFinish(commands);
    checkError(err,"waiting for kernel to finish");
    // Read back the results from the device to verify the output
    err = clEnqueueReadBuffer(commands, out_real_kernel_cl_mem, CL_TRUE, 0,
			      sizeof(float) * NUM_ARRAYS*ARRAY_SIZE, out_real_kernel, 0, NULL,NULL);
    checkError(err,"reading the result from out_Real");
    err = clFinish(commands);
    checkError(err,"waiting for first read to be done");
    err = clEnqueueReadBuffer(commands,out_img_kernel_cl_mem, CL_TRUE, 0, sizeof(float)*NUM_ARRAYS*ARRAY_SIZE, out_img_kernel,0,NULL,NULL);
    checkError(err,"reading result from out_img");
    err = clFinish(commands);
    checkError(err,"waiting for reading to be done");
    const double end_time = getCurrentTimestamp();
    const double total_time = end_time - start_time;

    //host-side fft
    complex<float> **inputs = new complex<float>*[NUM_ARRAYS];
    for(int i=0; i< NUM_ARRAYS;i++){                //load up complex arrays 
      inputs[i] = new complex<float>[ARRAY_SIZE];
      for(int j=0; j<ARRAY_SIZE;j++)
	inputs[i][j] = complex<float>(in_real[i*ARRAY_SIZE+j],in_img[i*ARRAY_SIZE+j]);
      FFT(inputs[i],ARRAY_SIZE,1);
    }
    
    
    // Check Results

    int errorsPerArray=0;
    int totalErrors=0;
    for(int i=0; i< NUM_ARRAYS; i++){
      for(int j=0; j<ARRAY_SIZE;j++){
	float diffReal = out_real_kernel[i*ARRAY_SIZE +j] - inputs[i][j].real();
	diffReal = (diffReal>0)? diffReal: (-1*diffReal);
	if(diffReal >TOL)
	  errorsPerArray++;
	
	float diffImg = out_img_kernel[i*ARRAY_SIZE +j] - inputs[i][j].imag();
	diffImg = (diffImg>0)? diffImg: (-1*diffImg);
	if(diffImg >TOL)
	  errorsPerArray++;
      }
      printf("%d wrong answers in array %d\n",errorsPerArray,i);
      totalErrors+=errorsPerArray;
      errorsPerArray=0;
    }
    printf("%d total wrong answers\n",totalErrors);
  
    cout << "Time(ms): " << total_time * 1e3 << endl;
    //--------------------------------------------------------------------------
    // Shutdown and cleanup
    //--------------------------------------------------------------------------
    clReleaseMemObject(out_real_kernel_cl_mem);
    clReleaseMemObject(out_img_kernel_cl_mem);
    clReleaseMemObject(in_real_cl_mem);
    clReleaseMemObject(in_img_cl_mem);
    clReleaseMemObject(N_cl_mem);
    clReleaseProgram(program);
    clReleaseKernel(kernel);
    clReleaseCommandQueue(commands);
    clReleaseContext(context);
}
                                                    


int log2(int N)    /*function to calculate the log2(.) of int numbers*/
{
  int k = N, i = 0;
  while(k) {
    k >>= 1;
    i++;
  }
  return i - 1;
}



int reverse(int N, int n)    //calculating revers number
{
  int j, p = 0;
  for(j = 1; j <= log2(N); j++) {
    if(n & (1 << (log2(N) - j)))
      p |= 1 << (j - 1);
  }
  return p;
}

void ordina(complex<float>* f1, int N) //using the reverse order in the array
{
  complex<float> f2[2<<12];
  for(int i = 0; i < N; i++)
    f2[i] = f1[reverse(N, i)];
  for(int j = 0; j < N; j++)
    f1[j] = f2[j];
}

void transform(complex<float>* f, int N) //
{
  ordina(f, N);    //first: reverse order
   complex<float> *W =new complex<float>[N];

float w_r[8] = {1,0.995183,0.98078,0.956929,0.92386,0.881891,0.831427,0.772954};
float w_i[8] = {0,-0.0980298,-0.195115,-0.290321,-0.38273,-0.471453,-0.555634,-0.634462};
for(int i=0; i< 8;i++){
W[i] = complex<float>(w_r[i],w_i[i]);
}
  int n = 1;
  int a = N / 2;
  for(int j = 0; j < log2(N); j++) {
    for(int i = 0; i < N; i++) {
      if(!(i & n)) {
        complex<float> temp = f[i];
        complex<float> Temp = W[(i * a) % (n * a)] * f[i + n];
        f[i] = temp + Temp;
        f[i + n] = temp - Temp;
      }
    }
    n *= 2;
    a = a / 2;
  }
}

void FFT(complex<float>* f, int N, double d=1)
{
  transform(f, N);
  for(int i = 0; i < N; i++)
    f[i] *= d; //multiplying by step
}
void cleanup(){return;}
