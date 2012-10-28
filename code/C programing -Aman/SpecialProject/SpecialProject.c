/* File: SpecialProject.c
 * Copy: copyright (c) 2011 Aman Khatri
 * Vers: 1.0.0 4/20/2011 kaman - original coding
 * Desc: Computes the internet charges of a USER from the file USAGE.txt and returns it to a new file ,Charges.txt.
 */

#include<stdio.h>	 /*Header File*/
#include<conio.h>	 /*Header File*/
#include<string.h>	 /*Header File*/
#include<stdlib.h>	 /*Header File*/
#include<math.h>	 /*Header File*/

	struct customer					    /*structured Variable*/
	{
		long int id;					/*variable declaration*/
		float hours_used;				/*variable declaration*/
		float usage_charges;			/*variable declaration*/
		float average_cost;				/*variable declaration*/
	};

	struct customer cust;

	struct billing_month				/*Structured Variable*/
	{
		int month;						/*variable declaration*/
		int year;						/*variable declaration*/
	};

	struct billing_month period;

void charges(float,float *,float *);	 /*Function Declaration*/
float round_money(float);				 /*Function Declaration*/

int main()								 /* Main Function */
{
	FILE *fpUsage = (FILE *)NULL;						 /* File Input Pointer*/
	FILE *fpCharges = (FILE *)NULL;
	//int i;								/*variable declaration*/


	if((fpUsage = fopen("usage.txt","r")) == NULL)            /* If input file doesn't exists */
	{
		printf("Unable to open the usage.txt, terminating application...");		/* Error Message */
		exit(1);
	}

	if((fpCharges = fopen("charges.txt","a")) == NULL)		 /* If Output file doesn't exists */
	{
		printf("Unable to open the charges.txt, terminating application...");	/* Error Message */
		exit(1);
	}

	fscanf(fpUsage,"%d %d",&period.month,&period.year);					/*scans the file */
	fprintf(fpCharges,"Charges for %d/%d\n\n",period.month,period.year); /*prints year and month */
	printf("Charges for %d/%d\n\n",period.month,period.year);			/*prints charges for month*/
	fputs("Customer	     Hours Used	      Usage Charges	       Average Cost\n",fpCharges);  /* Headings of table , there was an error in the book so charges per hour collumn has been changed to usage charge in the heading*/

	while(fscanf(fpUsage,"%ld %f",&cust.id,&cust.hours_used) != EOF)						/*while condition for navigating throught the file */
	{				
		charges(cust.hours_used, &cust.usage_charges, &cust.average_cost);				    /* Displays the usage of internet by the user */

		fprintf(fpCharges,"%ld       	%10.2f	       %10.2f       	%10.2f\n",cust.id,cust.hours_used,cust.usage_charges,cust.average_cost);  /* ouptputs the charges, customer id in the output file */

		printf("%ld	%10.2f	%10.2f	%10.2f\n",cust.id,cust.hours_used,cust.usage_charges,cust.average_cost);					/*prints details*/
	}

	fclose(fpUsage);		/*closes the input file*/
	fclose(fpCharges);		/*Closes the output file*/

	printf("\n\nInternet bill calculated..."); /*diplays that the bill has been calculated*/
	

	return 0;
}

void charges(float hours_used,float *usage, float *avg_cost)  /*function to compute usage*/
{	
	float extra_usage = hours_used - 10;					/*local variable*/
	if (hours_used <= 10)										/*if usage is under 10 hours*/
	{
		*usage=7.99;								
	}
	if (hours_used > 10)
	{
		extra_usage= round_money(extra_usage);					/*calling a function to round the charges*/
		*usage = 7.99+(extra_usage*1.99);
	}	
	
	*avg_cost = *usage / hours_used;								/*average Cost*/
 	
}

float round_money(float money)										/*Rounds the money */
{
	float result = 0.0;

	result = ceil (money);												/*rounds the money*/
	return result;													/*returns the result to the main function */
}