/*
 *  Table des symboles.c
 *
 *  Created by Janin on 12/10/10.
 *  Copyright 2010 LaBRI. All rights reserved.
 *
 */


#include <stdlib.h>
#include <stdio.h>

#include "Table_des_symboles.h"

/* bit  type handling */

  


/* Attribute types */

attribute new_attribute () {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
  if (r==NULL) {printf("Failed Malloc\n"); exit(-1);}
  return r;
};

attribute makeSymbol(int type, int offset, int depth, int block_offset)
{
  attribute r = new_attribute();
  r -> type = type;
  r -> offset = offset;
  r -> depth = depth;
  r -> block_offset = block_offset;
  return r;
}



/* The storage structure is implemented as a linked chain */

/* linked element def */

typedef struct elem {
	sid symbol_name;
	attribute symbol_value;
	struct elem * next;
} elem;

/* linked chain initial element */
static elem * storage=NULL;

/* get the symbol value of symb_id from the symbol table */
attribute get_symbol_value(sid symb_id, int depth) {
	elem * tracker=storage;

	attribute cur = NULL;

	/* look into the linked list for the symbol value */
	while (tracker) {
		if (tracker->symbol_name == symb_id && tracker->symbol_value->depth <= depth) {
			if (cur == NULL || tracker->symbol_value->depth > cur->depth || // bloc depth inf
				(tracker->symbol_value->depth == cur->depth &&				// même depth donc on regarde b_offset
				tracker->symbol_value->block_offset > cur->block_offset)) {
				cur = tracker->symbol_value;
			}
		}
		tracker = tracker->next;
	}

    
	/* if not found does cause an error */
	if (cur == NULL) {
		fprintf(stderr,"ERROR : symbol %s is not a valid defined symbol\n",(char *) symb_id);
		exit(-1);
	}
	return cur;
};

/* get the symbol value of symb_id from the symbol table */
attribute get_symbol_value_by_pos(int depth, int b_offset, int offset) {
	elem * tracker=storage;

	/* look into the linked list for the symbol value */
	while (tracker) {
		if ((tracker->symbol_value->depth == depth) && (tracker->symbol_value->block_offset == b_offset) && (tracker->symbol_value->offset == offset))
			return tracker->symbol_value;
		tracker = tracker->next;
	}

    
	/* if not found does cause an error */
	if (tracker == NULL) {
		fprintf(stderr,"ERROR : symbol (%d, %d, %d) not found\n",depth, b_offset, offset);
		exit(-1);
	}
};

/* add the symbol symb_id with given value */
attribute set_symbol_value(sid symb_id,attribute value) {

	elem * tracker;	
	tracker = malloc(sizeof(elem));
	tracker -> symbol_name = symb_id;
	tracker -> symbol_value = value;
	tracker -> next = storage;
	storage = tracker;
	return storage -> symbol_value;
}

int count_args(int fblock_offset) {
	/* look into the linked list for the symbol value */
	elem * tracker=storage;
	int count = 0;
	while (tracker) {
		if ((tracker->symbol_value->depth == 1) && (tracker->symbol_value->block_offset == fblock_offset) && (tracker->symbol_value->offset < 0))
			count++;
		tracker = tracker->next;
	}
	return count;
}

void print_symbols() {
	elem * tracker=storage;

	/* look into the linked list for the symbol value */
	while (tracker) {
		attribute cur = tracker->symbol_value;
		printf("// symb : %s | offset : %d | type : %d | depth : %d | b_offset : %d \n", tracker->symbol_name, tracker->symbol_value->offset, cur->type, cur->depth, cur->block_offset); 
		tracker = tracker -> next;
	}

}

/* Remove the symbol with the given symbol name from the symbol table */
void remove_symbol(sid symb_id) {
    elem *current = storage;
    elem *prev = NULL;

    while (current != NULL) {
        if (current->symbol_name == symb_id) {
            if (prev == NULL) {
                // The symbol to be removed is at the beginning of the list
                storage = current->next;
            } else {
                // The symbol to be removed is in the middle or at the end of the list
                prev->next = current->next;
            }

            // Free memory allocated for the removed symbol
            free(current->symbol_value);
            free(current);

            return; // Symbol found and removed
        }

        prev = current;
        current = current->next;
    }

    // If the symbol is not found, print an error
    fprintf(stderr, "ERROR: Symbol %s not found for removal\n", (char *)symb_id);
    exit(-1);
}

