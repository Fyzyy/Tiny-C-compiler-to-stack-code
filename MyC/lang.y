%{

#include "Table_des_symboles.h"
#include "symb_list.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_DEPTH 10

extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);
  exit(0);
  }
		
 int depth=0; // block depth
 
%}

%union { 
  struct ATTRIBUTE * symbol_value;
  struct symb_list *list_value;
  char * string_value;
  int int_value;
  float float_value;
  int type_value;
  int label_value;
  int offset_value;

}

%token <int_value> NUM
%token <float_value> DEC


%token INT FLOAT VOID

%token <string_value> ID
%token AO AF PO PF PV VIR
%token RETURN  EQ
%token <label_value> IF ELSE WHILE

%token <label_value> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%nonassoc IFX
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DIFF EQUAL SUP INF       // higher priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
%nonassoc ELSE


%{

int offsets[MAX_DEPTH] = {0};
int block_offsets[MAX_DEPTH] = {0};

int fblock_offset;
int fargs_count;
attribute fsymb;

char * type2string (int c) {
  switch (c)
    {
    case INT:
      return("int");
    case FLOAT:
      return("float");
    case VOID:
      return("void");
    default:
      return("type error");
    }  
};

void tab() {
  for (int i=0; i<depth; i++)
    printf("  ");
}

attribute register_new_symbol(int type, char* str, int offset) {
  return set_symbol_value(string_to_sid(str), makeSymbol(type, offset, depth, (depth <= 1) ? block_offsets[0]:block_offsets[depth]));

}

int is_float(int exp) {
  return exp == FLOAT;
}

int convert_op(char* op, int type_exp1, int type_exp2) {

  if (is_float(type_exp1) || is_float(type_exp2)) {
        if (!is_float(type_exp2)) {
          tab();
          printf("I2F;\n");
        }
        if (!is_float(type_exp1)) {
          tab();
          printf("I2F2;\n");
        }
    tab(); 
    printf("%sF;\n", op);
    return FLOAT;
  }
  else {
    tab(); 
    printf("%sI;\n",op);
    return INT;
  }

}


void init_offsets(int* offsets) {
  for (int i=0; i<MAX_DEPTH; i++) 
    offsets[i]=1;
}

void change_block() {
  offsets[depth] = 1;
  block_offsets[depth]++;
}

char glob[8000] = "";

int label = 0;
int loop_label =0;

int gen_label() {
  return label++;
}

int gen_loop_label() {
  return loop_label++;
}




char* genStackBpStr(int i) {
    if (i <= 0) {
        return NULL;
    }

    char* result = (char*)malloc(sizeof(char) * 50 * i); // Choisir une taille appropriée
    if (i == 1) {
        sprintf(result, "stack[bp].index_value");
    } else {
        char* subResult = genStackBpStr(i - 1);
        sprintf(result, "stack[%s].index_value", subResult);
        free(subResult);
    }
    return result;
}

%}


%start prog  

// liste de tous les non terminaux dont vous voulez manipuler l'attribut
%type <type_value> type exp typename app
%type <string_value> fun_head fid
%type <list_value> vlist params
%type <int_value> args arglist
%type <label_value> if while

 /* Attention, la rêgle de calcul par défaut $$=$1 
    peut créer des demandes/erreurs de type d'attribut */

%%

 // O. Déclaration globale

prog : glob_decl_list              {}

glob_decl_list : glob_decl_list fun {}
| glob_decl_list decl PV       {}
|                              {} // empty glob_decl_list shall be forbidden, but usefull for offset computation

// I. Functions

fun : type fun_head fun_body   
{
  //remove_symbol(string_to_sid($2)); 
  block_offsets[0]++; 
  //set_symbol_value(string_to_sid($2),register_new_symbol($1, $2, offsets[depth]++));
}
;

fun_head : ID PO PF            {

  register_new_symbol($<type_value>0, $1, offsets[depth]++); //pour les récursives
  
  // Pas de déclaration de fonction à l'intérieur de fonctions !
  if (depth>0) yyerror("Function must be declared at top level~!\n");
    
  printf("void pcode_%s() { \n",$1);
  $$ = $1;

  }

| ID PO params PF              {

  depth--; // on declare les symbols avec une depth 1 pour ne pas les confondre avec des var global

  register_new_symbol($<type_value>0, $1, offsets[depth]++);
  // Pas de déclaration de fonction à l'intérieur de fonctions !
  if (depth>0) yyerror("Function must be declared at top level~!\n");
    
  printf("void pcode_%s() { \n",$1);
  $$ = $1;

 }
;

params: type ID vir params     {register_new_symbol($1, $2, -offsets[depth]++);} // récursion droite pour numéroter les paramètres du dernier au premier
| type ID                      {block_offsets[depth]++; depth++; register_new_symbol($1, $2, -offsets[depth]++);}


vir : VIR                      {}
;

fun_body : fao block faf       {}
;

fao : AO                       
{  
  depth++;
  change_block(); 
}
;
faf : AF                       {depth--; tab(); printf("}\n\n"); }
;


// II. Block
block:
decl_list inst_list            {}
;

// III. Declarations

decl_list : decl_list decl PV   {} 
|                               {}
;

decl: var_decl                  {}
;

var_decl : type vlist          {}
;
// on creer une liste chainée pour parcourir tout les symbol à déclarer.
vlist: vlist vir ID            {register_new_symbol($<type_value>0, $3, offsets[depth]++); char * load = ($<type_value>0 == INT ? "LOADI(0);\n" : "LOADF(0);\n"); if (depth==0) strcat(glob, load); else {tab(); printf("%s",load);}} // récursion gauche pour traiter les variables déclararées de gauche à droite
| ID                           {register_new_symbol($<type_value>0, $1, offsets[depth]++); char * load = ($<type_value>0 == INT ? "LOADI(0);\n" : "LOADF(0);\n"); if (depth==0) strcat(glob, load); else {tab(); printf("%s",load);}}
;

type
: typename                     {$$=$1;}
;

typename
: INT                          {$$=INT;}
| FLOAT                        {$$=FLOAT;}
| VOID                         {$$=VOID;}
;

// IV. Intructions

inst_list: inst_list inst   {} 
| inst                      {}
;

pv : PV                       {}
;
 
inst:
ao block af                   {}
| aff pv                      {}
| ret pv                      {}
| cond                        {}
| loop                        {}
| pv                          {}
;

// Accolades explicites pour gerer l'entrée et la sortie d'un sous-bloc

ao : AO                       {depth++; change_block(); tab(); printf("SAVEBP;//%d, %d\n", depth, block_offsets[depth]);}
;

af : AF                       {tab(); printf("RESTOREBP;\n"); depth--;}
;


// IV.1 Affectations

aff : ID EQ exp               
{
  attribute symb;

  if (sid_valid(string_to_sid($1))) symb = get_symbol_value(string_to_sid($1), depth);
  else yyerror("Unknow Symbol\n");

  if (symb->depth > depth) yyerror("symbol not defined in current or higher block \n");

  if ((get_symbol_value(string_to_sid($1), depth)->type == INT) && ($3 == FLOAT))
    yyerror("ERROR : affecting float in int !  \n");

  if ((get_symbol_value(string_to_sid($1), depth)->type == FLOAT) && ($3 == INT)) {
    tab();
    printf("I2F;\n");
  }

  tab();

  char* stackBpStr = genStackBpStr(depth - symb->depth);
  if (stackBpStr == NULL) printf("STOREP(bp+%d);\n",symb->offset);
  else printf("STOREP(%s+%d);\n",stackBpStr ,symb->offset);
  free(stackBpStr);

}
;


// IV.2 Return
ret : RETURN exp              {tab(); printf("return;\n");}
| RETURN PO PF                {}
;

// IV.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction
//           qui est résolu comme on le souhaite par un décalage (shift)
//           avec ELSE en entrée (voir y.output)

cond :
if bool_cond inst  elsop       {tab(); printf("end_%d:\n", $1);}
;

elsop : else inst              {}
|                  %prec IFX   {} // juste un "truc" pour éviter le message de conflit shift / reduce
;

bool_cond : PO exp PF         {tab(); printf("IFN(false_%d);\n", $<label_value>0);}
;

if : IF                       {$$ = gen_label(); }
;

else : ELSE                   {tab(); printf("GOTO(end_%d);\n",$<label_value>-2); tab(); printf("false_%d:\n", $<label_value>-2);}
;

// IV.4. Iterations

loop : while while_cond inst  {tab(); printf("GOTO(StartLoop_%d)\n", $1); tab(); printf("EndLoop_%d:\n", $1);}
;

while_cond : PO exp PF        {tab(); printf("IFN(EndLoop_%d)\n", $<label_value>0);}
;

while : WHILE                 {$$=gen_loop_label(); tab(); printf("StartLoop_%d:\n",$$);}
;


// V. Expressions



exp
// V.1 Exp. arithmetiques
: MOINS exp %prec UNA         {$$ = $2; tab(); if (is_float($2)) printf("MINUSF\n"); else printf("MINUSI\n");}
         // -x + y lue comme (- x) + y  et pas - (x + y)
| exp PLUS exp                {$$ = convert_op("ADD", $1, $3);}
| exp MOINS exp               {$$ = convert_op("SUB", $1, $3);}
| exp STAR exp                {$$ = convert_op("MULT", $1, $3);}
| exp DIV exp                 {$$ = convert_op("DIV", $1, $3);}
| PO exp PF                   {$$ = $2;}
| ID                          
{

  attribute symb;

  if (sid_valid(string_to_sid($1))) symb = get_symbol_value(string_to_sid($1), depth);
  else yyerror("Unknow Symbol\n");
  if (symb->depth > depth) yyerror("symbol not defined in current or higher block \n");

  $$ = symb->type;
  tab();

  char* stackBpStr = genStackBpStr(depth - symb->depth);
  if (stackBpStr == NULL) printf("LOADP(bp+%d);\n",symb->offset);
  else printf("LOADP(%s+%d);\n",stackBpStr ,symb->offset);
  free(stackBpStr);
}
| app                         {$$ = $1;}
| NUM                         {$$ = INT; tab(); printf("LOADI(%d);\n",$1);}
| DEC                         {$$ = FLOAT; tab(); printf("LOADF(%f);\n",$1);}


// V.2. Booléens

| NOT exp %prec UNA           {$$ = INT; tab(); printf("NOT;\n");}
| exp INF exp                 {$$ = convert_op("LT", $1, $3);}
| exp SUP exp                 {$$ = convert_op("GT", $1, $3);}
| exp EQUAL exp               {$$ = convert_op("EQ", $1, $3);}
| exp DIFF exp                {$$ = convert_op("NEQ", $1, $3);}
| exp AND exp                 {$$ = INT; tab(); printf("AND;\n");}
| exp OR exp                  {$$ = INT; tab(); printf("OR;\n");}

;

// V.3 Applications de fonctions


app : fid PO args PF          
{
  $$ = get_symbol_value(string_to_sid($1),0)->type; 
  tab(); printf("SAVEBP;\n"); 
  tab(); printf("CALL(pcode_%s);\n", $1); 
  tab(); printf("RESTOREBP;\n"); 
  tab(); printf("ENDCALL(%d);\n",$3);
}
;

fid : ID                      
{

  $$ = $1;
  fsymb = get_symbol_value(string_to_sid($1),0);  // tu dois gerer les decla prealable pour les récursion  en supprimant les symboel en doublons !!
  fblock_offset = fsymb->block_offset;
  fargs_count = count_args(fblock_offset);
}

args :  arglist               {$$ = $1;}
|                             {$$ = 0;}
;

arglist : arglist VIR exp     {$$ = $1+1; if((get_symbol_value_by_pos(1, fblock_offset,-fargs_count+$1)->type == FLOAT) && ( $3 == INT)) {tab(); printf("I2F;\n");}} // récursion gauche pour empiler les arguements de la fonction de gauche à droite
| exp                         {$$=1; if((get_symbol_value_by_pos(1, fblock_offset, -fargs_count)->type == FLOAT) && ( $1 == INT)) {tab(); printf("I2F;\n");}}
;



%% 
int main () {

  init_offsets(offsets);

  /* Ici on peut ouvrir le fichier source, avec les messages 
     d'erreur usuel si besoin, et rediriger l'entrée standard 
     sur ce fichier pour lancer dessus la compilation.
   */

char * header=
"// PCode Header\n\
#include \"PCode.h\"\n\
\n";

char * body= 
"\n\
int main() {\n\
  SAVEBP;\n\
  %s\
pcode_main();\n\
  RESTOREBP;\n\
  print_stack();\n\
  return stack[sp-1].int_value;\n\
}\n\n";

printf("%s\n", header); // output header

int parse = yyparse();

printf(body, glob); // output main c and global var

print_symbols();

return parse;

} 

