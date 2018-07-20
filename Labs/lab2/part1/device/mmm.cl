/*
Original FFT Algorithm 



*/


__constant float w_r[] = {1,0.995183,0.98078,0.956929,0.92386,0.881891,0.831427,0.772954};


__constant float w_i[] = {0,-0.0980298,-0.195115,-0.290321,-0.38273,-0.471453,-0.555634,-0.634462};







__kernel void mmm(__global const float* restrict in_real, __global const float* restrict in_img, __global float* restrict out_real,__global float* restrict out_img, __global const int* restrict N){

  int n = *N;

  for(int gid = 0; gid< n; gid++){

   
    int g8 = gid *8;

	
	float temp[4 * 8];
    
    
    for(int i=0; i<8;i++){

      temp[0 *8+ i] = in_real[g8+i];
	  temp[1 *8+ i] = in_img[g8+i];

    }

    int realLoad =0 * 8;
 	int imagLoad =1 * 8;
    int realStore=2 * 8;
	int imagStore=3 * 8;

    //Outer compute loop
    for(int L = 4; L>0; L/=2){
      
      int m = 4/L;
      
    
      //Inner compute loop
      for(int base =0;base<4;base+=1){
	
		int j = base/m;
	
		temp[realStore + base+(j+0)*m] = temp[realLoad + base] + temp[realLoad + base+4];
		temp[imagStore + base+(j+0)*m] = temp[imagLoad + base] + temp[imagLoad + base+4];
		temp[realStore + base+(j+1)*m]=w_r[j*4/L]*(temp[realLoad + base] - temp[realLoad + base+4]) - w_i[j*4/L]*(temp[imagLoad + base] - temp[imagLoad + base+4]);
		temp[imagStore + base+(j+1)*m] =w_r[j*4/L]*(temp[imagLoad + base] - temp[imagLoad +base+4])   + w_i[j*4/L]*(temp[realLoad +base] - temp[realLoad + base+4]);
	
	
	
      }

      int temporary = realStore;
      realStore = realLoad;
	  realLoad = temporary;
      	
      temporary = imagStore;
      imagStore = imagLoad;
      imagLoad = temporary; 

    }
      
    
    for(int i=0; i<8;i++){

      out_real[g8+i] = temp[realLoad + i]; 
      out_img[g8+i] = temp[imagLoad + i];

    }
   

    
  }
  
}
