/* File: P4.c
 * Copy: copyright (c) 2011 Aman Khatri
 * Vers: 1.0.0 3/9/2011 kaman - original coding
 * Desc: Opens a textfile, then counts number of words in file. Words are seprated by spcae also, this program finds the specified word in the textfile
 */

#include<stdio.h>     /* input and output functions */
#include<stdlib.h>    /* standard library */
#include <string.h>   /* string functions */

/* sets the variable STR_LEN to have a maximum of 81 include one end of file charater  */
#define STR_LEN 81

/* prototype functions */
int count_words(FILE *inp, int flag, char search_str[]);  

/* Name: main */
int 
main(int argc, char *argv[])
{ 
	int string_count;														 /* declaration of counter variable  */
	FILE *inp;																 /* file pointer */
	int status;																 /* recieves feedback from the fscanf function  */
	char str[STR_LEN];														 /* string variable to hold the words from the file  */
	int count_all;															 /* flag to report what should be count in the file  */
	
	if (argc < 2)															 /* this tests if the number of string(s) is less then two */
	{
	/* prints the name of the program and the name of the programmer, then exit the program*/
		printf("EE 233 Spring 2011 P4, kaman, Aman Khatri.\n");
		exit(0);															 /*exiting the if condition*/
	}
	else if (argc==2)														 /*if there are two strings*/
	{
		inp=fopen(argv[1],"r");
		/* testing if the file exists */
		if (inp==NULL)														 /* if the file does not exists */          
		{
			printf("could not open the file");								 /* print an error message */
			exit(0);														 /* exit the if condition*/  
		}
		else
		{
			count_all = 1;
			string_count = count_words(inp, count_all, " ");
		}
		fclose(inp);														/*closes the file*/
		printf("%s contains %.4d total words.",argv[1],string_count);       /*print the number of words*/
	}
	else if (argc==3)
	{
		inp=fopen(argv[1],"r");
		/* testing for the file existance */
		if (inp==NULL)														/* if the file does not exist */          
		{
			printf("could not open the file");								/* print an error message */
			exit(0);														/* exit the if condition*/  
		}
		else																/* if file exists */
		{
			count_all=0;													/*count the words */
			string_count=count_words(inp, count_all, argv[2]);				/*reading the string*/
		}
		fclose(inp);														/*closes the file*/
		printf("%s contains the word %s %.4d times.",argv[1],argv[2],string_count); /*print the number of words and the number of times it appears in the text file */
	}

	return(0);
}


/* name: count_words 
 * Desc: function for word count */
int
count_words(FILE *inp, int flag, char search_str[]) 
{
	int status;
	int n;
	char str[STR_LEN];
	n = 0;
	if (flag==1)
	{
		status=fscanf(inp,"%s",str);
		while (status != EOF)
		{
			n=n+1;
			status=fscanf(inp,"%s",str);
		}
	}
	else if (flag == 0)
	{
		status=fscanf(inp,"%s",str);
		while (status != EOF)
		{
			if (stricmp(str,search_str)==0)
			{
				n=n+1;
			}
			status=fscanf(inp,"%s",str);
		}
	}
	return(n);
}





