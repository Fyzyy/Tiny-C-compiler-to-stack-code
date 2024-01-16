/*
 *  PCode.c
 * 
 *  Created by Janin on 12/11/21.
 *  Copyright 2021 ENSEIRB. All rights reserved.
 *
 */


#include "PCode.h"
#include <stdio.h>

stack_value stack[SIZE];

int sp = 0; // première case libre
int bp = 0;
int fp = 0;


// test pile vide, pile pleine et pile valide (pour le debug ?)

int empty_stack () {
  return sp <= 0;  // sp == 0 when valid stack
}


int full_stack () {
  return sp >= SIZE;  // sp == SIZE when valid stack
}

int valid_stack (){
  return sp > 1 && sp <= SIZE;
}


// imprime la pile

void print_stack() {
  printf("\nBEGIN STACK : bp = %i, fp = %i\n",
	 bp, fp);
  int p = 0;
  while (p < sp) {
    printf ("(%i)  int : %i   float : %f\n",p, stack[p].int_value, stack[p].float_value);
    p++;
  }
  printf("END STACK\n");
  
}

void test();

void test() {
  // testing macros' syntax (not to be ran)
  
  LOADI(22)
  LOADF(4.5)
  DROP(4)
  MINUSI
  MINUSF  
  I2F
  F2I
    
  ADDI
  MULTI
  SUBI
  DIVI
    
  ADDF
  MULTF
  SUBF
  DIVF
    
  LTI
  GTI
    //  LEQI
    //  GEQI
    
  EQI
  LTF
  GTF
    // LEQF
    // GEQF
  EQF
  OR
  AND
  NOT
    
  IFT(toto)
  IFN(toto)
  GOTO(toto)

 toto: NOP 
  LOADP(bp)
  STOREP(bp)
  SAVEBP
    
  RESTOREBP
  
  CALL(test)
    
  ENDCALL(3)
  
}


