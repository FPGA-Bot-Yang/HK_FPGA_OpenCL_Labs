/*
Original FFT Algorithm 
W constants are from Ahmed's FFT algorithm


*/


__constant float w_r[] = {1,0.995183,0.98078,0.956929,0.92386,0.881891,0.831427,0.772954};


__constant float w_i[] = {0,-0.0980298,-0.195115,-0.290321,-0.38273,-0.471453,-0.555634,-0.634462};

//__constant float w_r[] = {1,0.995183,0.98078,0.956929,0.92386,0.881891,0.831427,0.772954,0.707035,0.634305,0.555464,0.471273,0.382542,0.290126,0.194916,0.0978271,0,-0.0982325,-0.195315,-0.290516,-0.382919,-0.471632,-0.555803,-0.63462,-0.707323,-0.773212,-0.831653,-0.882083,-0.924016,-0.957047,-0.98086,-0.995223,-1,-0.995143,-0.980701,-0.956811,-0.923704,-0.881699,-0.831201,-0.772695,-0.706747,-0.63399,-0.555126,-0.470914,-0.382166,-0.289736,-0.194516,-0.0974217,0,0.0986379,0.195715,0.290906,0.383295,0.471992,0.556142,0.634934,0.707611,0.773471,0.83188,0.882275,0.924172,0.957165,0.980939,0.995263};


//__constant float w_i[] = {0,-0.0980298,-0.195115,-0.290321,-0.38273,-0.471453,-0.555634,-0.634462,-0.707179,-0.773083,-0.83154,-0.881987,-0.923938,-0.956988,-0.98082,-0.995203,-1,-0.995164,-0.980741,-0.95687,-0.923782,-0.881795,-0.831314,-0.772825,-0.706891,-0.634147,-0.555295,-0.471094,-0.382354,-0.289931,-0.194716,-0.0976244,0,0.0984352,0.195515,0.290711,0.383107,0.471812,0.555972,0.634777,0.707467,0.773341,0.831767,0.882179,0.924094,0.957106,0.980899,0.995243,1,0.995123,0.980661,0.956752,0.923626,0.881603,0.831088,0.772566,0.706603,0.633832,0.554956,0.470734,0.381978,0.289542,0.194316,0.097219};






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


    for(int L = 4; L>0; L/=2){
      
      int m = 4/L;
      
    
      
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
