/* File: p5
 * Copy: Copyright (c) 2011 Aman Khatri
 * Vers: 1.0.0 2/7/2011 kaman - original coding
 * Desc: The purpose of this program is to count the frequency of word appears in the file, and dislplay the word with the
 *  highest frequency and how many times it occured.
*/

// Libraries //
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

// Define default variables //
#define STR_LEN 31
#define MAX_WORDS 601

//main function//                               
int
main(int argc, char *argv[])
{
	int i,j,k,m;         		      // counter variables //
	int compare;                      // strcmp variable//
	int big;                          // store big number //
	int loc;                          // location of biggest number in array //
	int test;                         // tests the word//
	int check;                        // checks the word //
	FILE *inp, *inpa;	              // file pointers //
	int status,statusa;               // feedback from fscanf function //
	int array_of_count[MAX_WORDS];     // holds the count for words
	char word[STR_LEN];               // temporary word holder.//
	char array_of_words[MAX_WORDS][STR_LEN];	  // string counter //

	j = 0;
	k = 0;
	m = 0;

	//  array with null values//
	for(i = 0; i < MAX_WORDS; i++)                 // for condition to check number of words//
	{
		array_of_words[i][0] = '\0';               // two dimension array//
	}
	for(i = 0; i < MAX_WORDS; i++)            
	{
		array_of_count[i] = 0;                     // one dimension array//
	}

	// checks for number of words in file if it exceeds the word limit of 600 words //
	 
	inpa = fopen(argv[1], "r");                     // opens the file to read words from it//            
	statusa = fscanf(inpa,"%s",word);  
	while(statusa != EOF)                           // while status is not equal to end of file charator//
	{
		statusa = fscanf(inpa,"%s",word);
		m++;
	}
	fclose(inpa);                                   // close file//
	if(m > MAX_WORDS)                               // if m is greater then 600 //
	{
		printf("The number of words in the file exceed the maximum allowed.\n");     // prints that file contains more then the word limit//
		exit(0);
	}
	// If only one arguement is typed //
	else if (argc == 1)                                                              // checks if the condition is true//
	{
		printf("EE233 Spring 2011 P5, kaman ,Aman Khatri.\n");   //print name , and blazer id//
		exit(0);                                                 // exit the else condition//
	}
	// If two or more words are typed in command line. //
	else if (argc > 1)
	{
		// Opens the text file stated by the second argument. //
		inp = fopen(argv[1], "r");

		// if file doesn't exists //
		if (inp == NULL)
		{
			printf("Could not open that file.\n");                // if file doesn't exists then displays error//
			exit(0);                                              // exists the loop//
		} 
		else
		{
			// scan file and put words in array//
			do
			{
				status = fscanf(inp,"%s",word);                 // initializes by reading the first word//
				if(status == EOF)
				{
					break;
				}
				// check if word is already in array or not//
				for(i = 0; i < MAX_WORDS; i++)                            
				{
					test = strcmp(array_of_words[i],word);      
					if(test == 0)
					{
						array_of_count[i]++;                    // increament in array count//
						check = 0;
						break;
					}
					else if(test != 0)
					{
						check = 1;
					}
				}
				//if word not found in array, add new word in new slot //
				if(check == 1)
				{
					strcpy(array_of_words[k],word);
					array_of_count[k]++;
					k++;
				}
				j++;
			}while(status != EOF);
			//find highest count//
			big = 0;
		    for(i = 0; i < MAX_WORDS; i++)
		    {
			   if(big < array_of_count[i])
			   {
				   big = array_of_count[i];
				   loc = i;
			   }
		    }
			//output //
			printf("The word, %s, occurred %d times in %s.", array_of_words[loc], array_of_count[loc],argv[1]);
		}
	}
	//closes the file//
	fclose(inp);
	//return value to the main function//
	return (0);
}
