/*
 *  Table des symboles.h
 *
 *  Associative array encoded as linked list of pair (symbol_name, symbol_value)
 *
 *  To be used only with getter get_symbol_value and setter set_symbol_value.
 *
 *  Type attribute can be customized.
 *
 *  Symbol names must be valid sid from Table des chaines. 
 *
 */

#ifndef TABLE_DES_SYMBOLES_H
#define TABLE_DES_SYMBOLES_H

#include "Table_des_chaines.h"

/* Déclarations des types d'attributs */

char* type2string (int);
struct ATTRIBUTE {
  int type;
  int offset;
  int depth;
  int block_offset;
  
  /* les autres attributs dont vous pourriez avoir besoin 
     pour les symboles seront déclarés ici */
  
};
   
typedef struct ATTRIBUTE * attribute;


attribute makeSymbol(int type, int offset, int depth, int block_offset);

attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */


/* get the symbol value of symb_id from the symbol table, NULL if it fails */
attribute get_symbol_value(sid symb_id, int depth);

attribute get_symbol_value_by_pos(int depth, int b_offset, int offset);

int count_args(int fblock_offset);

/* add the symbol symb_id with given value */
attribute set_symbol_value(sid symb_id,attribute value);

void print_symbols();

void remove_symbol(sid symb_id);

#endif
