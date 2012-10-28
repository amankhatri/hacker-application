/*  File: p1.c
 *  Copy: Copyright (c) 2011 Aman Khatri 
 *  vers: 1.0.0 01/24/2011 kaman - original coding
 *  Desc: This program converts temperature from degree fahrenheit to degree celsius 
 */

# include <stdio.h>  /* Standard input output library */
# define farenheit_to_celsius 5.0/9.0  /*constant declaration */
/* Name: main*/
int 
main (void)
{
	int fahrenheit;   /* declaring variables */
	double celsius;   /* Declaring variables */

	printf (" EE 233 spring 2011, P1: This program converts temperature from degree fahrenheit to degree celsius.\n");     /* displays project details */      
	printf ( " Enter the temprature in degree fahrenheit (whole number only)  > ") ;        /* asking for user input */
	scanf  ( "%d", &fahrenheit ) ;		/* machine takes in the value for computation */

	/* formula for converting celsius to degree ferenheit, machine computes according to this formula */
	celsius = farenheit_to_celsius *(fahrenheit - 32); 

	printf (" Temprature in degree celsius equals %.2f\n", celsius); /* prints the result */
	
	return (0);
}