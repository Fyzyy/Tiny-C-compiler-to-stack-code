%option noyywrap
/* avoid dependency with library fl */

%{ 
#include "y.tab.h"
#include "Table_des_symboles.h"
#include <stdio.h>

%}
%% 

"="                      { return EQ;}

"+"                      { return PLUS;}
"-"                      { return MOINS;}
"*"                      { return STAR;}
"/"                      { return DIV;}
"||"                     { return OR;}
"&&"                     { return AND;}
"!"                      { return NOT;}

"=="                     { return EQUAL;}
"!="                     { return DIFF;}
"<"                      { return INF;}
">"                      { return SUP;}

"("                      { return PO;}
")"                      { return PF;}
"{"                      { return AO;}
"}"                      { return AF;}

"int"                    { return INT;}
"float"                  { return FLOAT;}
"void"                   { return VOID;}

"return"                 { return RETURN;}
"if"                     { return IF;}
"else"                   { return ELSE;}
"while"                  { return WHILE;}

"."                      { return DOT;}
"->"                     { return ARR;}

";"                      { return PV;}
","                      { return VIR;}


[0-9]+                   { yylval.int_value =  atoi (yytext);
                           return NUM; }
[0-9]*\.[0-9]+           { yylval.float_value =  atof (yytext);
                           return DEC; }
[A-Za-z][A-Za-z0-9]*     { yylval.string_value = string_to_sid(yytext);
		           return ID; }
[ \t\n]                   { /* on avale sans rendre la main */; }
