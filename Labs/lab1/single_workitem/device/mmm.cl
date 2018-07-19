#define SIZE 16
__kernel  void mmm(__global float* restrict a, __global float* restrict b, __global float* restrict c){
	for (int i = 0; i < SIZE; i++){
		for (int j =0; j < SIZE; j++){
			float temp = 0;
			for (int k =0; k < SIZE; k++){
			temp += (a[i*SIZE+k] * b[k*SIZE+j]);
			}
			c[i*SIZE+j] = temp;
		}
	}	
}
