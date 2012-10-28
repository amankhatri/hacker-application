/* File: P2.c
 * Copy: copyright (c) 2011 Aman Khatri
 * Vers: 1.0.0 2/7/2011 kaman - original coding
 * Desc: This program opens a text file and counts the number of words in the file
 */

#include <stdio.h>	/* include the standard input and output functions */
#include <stdlib.h> /* include the standard library */
#define STR_LEN 81


/* Name: main */
int 
main(int argc , char * argv [ ])       /*main funtion returns interger and charater values*/
{
	int i;                /* counter*/
	FILE *inp;            /*file pointer*/
	int status;           /* feedback from fscanf function*/
	char str[STR_LEN];    /* declaration of charater string */ 
	i=0;                  /* counter set to zero */
	
	if (argc <2)                                                                 /* if the program starts without any comment-line arguments, it prints the developer's detail*/
	{
		printf ("EE 233 spring 2011 P2, kaman, Aman Khatri \n");                   /*developer's details*/
        exit(0);                                                                 /*exits the 'if' condition*/
	}
	
	else if (argc >= 2)                                                          /*this condition displays and error message when file can't be opened */                                                   
	{ 
		inp = fopen(argv[1] ,"r");                                               /*opening the file to check if it exists */
		
		if (inp==NULL)
		{ 
			printf("could not open that file\n");                                /*displays an error message*/
			exit(0);                                                             /* exits the if statement*/
		}
		
		else                                                                     /*condition where the program starts executing and opens the testfile*/
		{
			status = fscanf ( inp, "%s", str);                                   /*scans throught the text file*/      
		
			while (status != EOF)                                                /*loop navigates through the file*/ 
			{
				i = i + 1;
			    status  = fscanf (inp ,"%s",str);                                /*scans the textfile*/
			}
		}
	
			printf("%s contains %.4d words.\n", argv[1], i);                     /*displays the number of words in the file*/
	}
	 
	 
	return 0;
}