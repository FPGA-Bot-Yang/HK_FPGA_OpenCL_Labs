#define SIZE 16
__kernel  void mmm(__global float* restrict a, __global float* restrict b, __global float* restrict c){
    
    int i = get_local_id(0);
    int row_start_index = i*SIZE;

    for(int j = 0; j < SIZE; j++){
	    float temp = 0;
	    for (int k =0; k < SIZE; k++){
		    temp += (a[i*SIZE+k] * b[k*SIZE+j]);
	    }
	    c[row_start_index+j] = temp;
    }
}
