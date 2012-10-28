/* File: CH2.c
 * Copy: Copyright (c) 2011
 * Vers: 1.0.0 09/11/02 rer - Original Coding.
 * Credits: Book
 */

/* Example from Chapter 2, Standish, linked lists */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>

/* declarations
 */

/* page 42, a structure type for list nodes, called NodeType
 */
typedef char AirportCode[4];	// used for three letter airport codes plus '\0' null terminator

typedef struct NodeTag
{
	AirportCode Airport;		// field for three letter airport code
	struct NodeTag *Link;		// link field for node containing a pointer to NodeType
} NodeType;


/* page 41 
 * NOTE: (NodeType **L) replaced (void) from example
 */
void InsertNewSecondNode(char* A, NodeType **L)
{
	NodeType *N;			// let N be a list node

	N = (NodeType *)malloc(sizeof(NodeType));	// allocate a new node, N
	strcpy(N->Airport,A);					// set N's airport to "BRU"
	//NOTE: *L differs from L in example
	N->Link = (*L)->Link;					// let N link to the second node of list L
	(*L)->Link = N;						// let L's first node link to N
}
/* page 45 program 2.13 List Searching Program
 */

NodeType *ListSearch(char *A, NodeType *L)
{

	NodeType *N;			//N points to successive nodes on the list L

	// initialization, let N start by pointing to the first node on the list L
	N=L;					

	// while N points to a non-null node on list L, examine the node to which N points
	while(N != NULL)
	{
		if (strcmp(N->Airport,A)==0)	// if N's Airport == A...
		{
			return N;					// return the node pointer in N
		} else							// otherwise
		{
			N = N->Link;				// advance N to the next node on the list
		}
	}
	return N;							// return NULL if no node's Airport ==A
}

/* page 49 program 2.15 Deleting the Last Node of a List
 * NOTE: **L is the address of the variable L, whose value 
 *		 points to the first node of the list L.
 */
void DeleteLastNode(NodeType **L)
{
	NodeType *PreviousNode, *CurrentNode;

	if(*L != NULL)		// do nothing if *L was the empty list
	{

		if((*L)->Link == NULL)	// if *L has exactly one node...
		{
			free(*L);			// free the node's storage
			*L=NULL;			// set L to be the empty list, and terminals
		} else					// otherwise, list L must have two or more nodes
		{
			// initialize a pair of pointers to point to the first and second nodes
			PreviousNode = *L;	
			CurrentNode = (*L)->Link;

			// advance the pointer pair along L until CurrentNode points to the last node
			while(CurrentNode->Link!=NULL)
			{
				PreviousNode = CurrentNode;			
				CurrentNode = CurrentNode->Link;
			}

			// now PreviousNode points to the next-to-last node on the list
			// and CurrentNode points to the last node on the list
			PreviousNode->Link = NULL;		// last node get NULL link
			free(CurrentNode);				// recycle storage for discarded node
		}
	}
}

/* page 50 program 2.16 Inserting a New Last Node on a List
 * NOTE: **L is the address of the variable L, whose value 
 *		 points to the first node of the list L.
 */
void InsertNewLastNode(char* A, NodeType **L)
{
	NodeType *N, *P;

	// allocate a new node N with Airport == A and Link == NULL
	N = (NodeType *)malloc(sizeof(NodeType));
	strcpy(N->Airport,A);
	N->Link = NULL;

	if(*L == NULL)			// if list *L is empty...
	{
		*L = N;				// let N become the new value for *L
	} else 
	{
		// locate the last node of list L, using pointer variable P
		P = *L;
		while(P->Link != NULL)
			P = P->Link;

		// finally, link node N onto the end of the list
		P->Link = N;
	}
}

/* page 50 program 2.17, Printing a List
 */
void PrintList(NodeType *L)
{
	NodeType *N;			// N points to successive nodes on list L

	// first, print a left parenthesis
	printf("(");

	// let N start by pointing to the first node on the list L
	N = L;

	// provided N does not point to an empty node, print N's Airport
	// and advance N to point to the next node on the list
	while(N != NULL)
	{
		printf("%s",N->Airport);	// print airport code
		N = N->Link;				// make N point to next node on list
		if(N != NULL)
			printf(", ");			// print comma between items
	}
	//finally, print a closing right parenthesis
	printf(")\n");
}

/* page 51-2 program 2.18
 ********* MAIN ***********************
 */
int main(int argc, char* argv[])
{
	// declare L to be of NodeType, construct it by setting
	// L == (DUS, ORD, SAN) then print it.
	NodeType* L;

	// let L be an empty list in the beginning
	L = NULL;
	
	// L is NULL, so add airport codes as the last node in the list
	InsertNewLastNode("DUS",&L);
	InsertNewLastNode("ORD",&L);
	InsertNewLastNode("SAN",&L);

	// print to show list before changes
	PrintList(L);

	// L now has three nodes, add a new second node
	InsertNewSecondNode("BRU",&L);	//NOTE: &L differs from L in example
	PrintList(L);

	DeleteLastNode(&L);

	PrintList(L);

	// added to illustrate command line arguments and debug arguments
	if(argv[1] != NULL)
		InsertNewSecondNode(argv[1],&L);
	if(argv[2] != NULL)
		InsertNewSecondNode(argv[2],&L);
	PrintList(L);
	return 0;
}
// ********** End of Main *************