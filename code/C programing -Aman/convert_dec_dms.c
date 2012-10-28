
#include <string.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

char convert_decimal_latlong(double latlong)
{
	char sLatLong[7];
	char sD[3];
	char sM[3];
	char sS[3];	
	int D = (int)(latlong);     //  int = the integer or whole number part (the part in
							//front of the decimal0
	double Md = latlong - D;
	double M =  Md*60;
	int iM = (int)(M);
	double Sd = M - iM;
	
	double S = Sd*60.0;
	int iS = (int)(S);
	
	
    // insert code here...
	if(latlong < 0){
		D = D * -1;
		
	}
	itoa(D,sD,10);
	

	strncpy(sLatLong,sD,sizeof(sLatLong));
		
	if(iS == 60){
		iM = iM+1 ;
		iS = 0;
		
	}
	itoa(iM,sM,10);
	itoa(iS,sS,10);
	if(iM < 10){
		strncat(sLatLong,"0",sizeof(sLatLong));
		strncat(sLatLong,sM,sizeof(sLatLong));
	} else
		strncat(sLatLong,sM,sizeof(sLatLong));
	if(iS < 10){
		strncat(sLatLong,"0",sizeof(sLatLong));
		strncat(sLatLong,sS,sizeof(sLatLong));
	} else
		strncat(sLatLong,sS,sizeof(sLatLong));
	
    printf("Degrees:%d\nMinutes:%d\nSeconds:%d\n\nsLatLong is (%s)\n",D,iM,iS,sLatLong);

	return(sLatLong);
}

int main (int argc, const char * argv[]) {

	double vals[8] = {31.9166667,46.9166667,33.7802778,45.5055556,33.8005556,45.5341667,31.7036111,47.0655556};
	double latlong = 32.1333333;
	int i=0;
	for(i=0;i<8;i++)

		convert_decimal_latlong(vals[i]);


/*	315500	465500
	334649	453020
	334802	453203
	314213	470356
*/

    return 0;
}
