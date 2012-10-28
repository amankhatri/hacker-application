 /* File: P3.c
 * Copy: copyright (c) 2011 Aman Khatri
 * Vers: 1.0.0 2/7/2011 kaman - original coding
 * Desc: This program opens a text file to count the number of items and to calculate the average of the given data
 */

#include <stdio.h>  /* include inputs and outputs */
#include <stdlib.h> /* include the library */


/* Name: main */
int
main(int argc , char * argv [ ])
{
	int i;					/* counter*/
	FILE *inp;				/* file pointer*/
	int status;				/* feedback from fscanf function*/
	double count;			/* Declaration of variable used in the program */
	double average;         /* Declaration of variable to store average of the given data */
	double sum;             /* Declaration of variable to store sum of the given data */
	
 i = 0;						/* Initializing the variable */
 count = 0;					/* Initializing the variable */
 sum = 0;					/* Initializing the variable */

	if (argc <2)														/* if the program starts without any comment-line arguments, it prints the developer's detail */
	{
		printf ( "EE 233 spring 2011 P3, Aman Khatri \n");				/* developer's details */
		exit (0);														/* exits the 'if' condition */
	}
																		
	else if (argc >=2)													/* this condition displays and error message when file can't be opened */ 
	{
		inp = fopen(argv [1] , "r");									/* opening the file to check if it exists */
		
		if (inp==NULL)
		{
				printf("could not open file\n");						/* displays an error message */
				exit(0);												/* exits the if statement */
		}

		else															/* condition where the program starts executing and opens the testfile */
		{
				status = fscanf (inp, "%lf", & count);					/* scans through the text file */ 
				
				while (status != EOF)									/* loop navigates through the file */
				{
					i = i+1;
					sum = sum + count;                                  /* Calculates the sum */
					status = fscanf (inp, "%lf", & count);				/* scans the textfile */
				}

				average = sum/i;										/* Calculates the average */
				fclose(inp);											/* closes the testfile */
		}
     printf ( "%s contains % .2d items. and their %lf average is \n", argv [1], i, average); /* displays the number of items and there average */
	}
	
	return 0;
	
	}