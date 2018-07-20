/*
Added intermediate values
*/


__constant float w_r[] = {1,0.995183,0.98078,0.956929,0.92386,0.881891,0.831427,0.772954};


__constant float w_i[] = {0,-0.0980298,-0.195115,-0.29041,-0.38273,-0.471453,-0.555634,-0.634462};





__kernel void mmm(__global const float* restrict in_real, __global const float* restrict in_img, __global float* restrict out_real, __global float* restrict out_img, __global int* restrict N) {

	int n = *N;

    for (int gid = 0; gid < n; gid++){

    	

    	int g8 = gid*8;


	float stage0_r[8];
	float stage1_r[8];
    	float stage2_r[8];
   	float stage3_r [8];
    	

	float stage0_i[8];
    	float stage1_i[8];
    	float stage2_i[8];
    	float stage3_i [8];
    	


    	for (int i =0; i <8; i++)
    	{
		stage0_r[i] = in_real[g8+i];
		stage0_i[i] = in_img[g8+i];
    	}

    	int L = 4;
    	int m = 1;
    	#pragma unroll
    	for (int base = 0; base < 4; base += 1) {
    	    int j = base;
	    float c0_r = stage0_r[base];
	    float c0_i = stage0_i[base];
	    float c1_r = stage0_r[base+4];
	    float c1_i = stage0_i[base+4];
	    stage1_r[base+(j+0)*m] = c0_r+c1_r;
	    stage1_i[base+(j+0)*m] = c0_i+c1_i;
	    float c2_r = c0_r-c1_r;
	    float c2_i = c0_i-c1_i;
	    stage1_r[base+(j+1)*m] =w_r[j*4/L]*c2_r - w_i[j*4/L]*c2_i;
	    stage1_i[base+(j+1)*m] =w_r[j*4/L]*c2_i + w_i[j*4/L]*c2_r;
    	}


    	L = 2;
    	m = 2;
    	#pragma unroll
    	for (int base = 0; base < 4; base += 1) {
    	    int j = base/m;
	 
    	}
 


    	L = 1;
    	m = 4;
    	#pragma unroll
    	for (int base = 0; base < 4; base += 1) {
    	    int j = base/m;
	
    	}



    	

    	

    	for (int i =0; i <8; i++)
    	{
		out_real[g8+i] = stage3_r[i];
		out_img[g8+i] = stage3_i[i];
    	}
    }
}

