
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include "smallc.tab.h"

extern "C"
{
  int yylex(void);
}

int line_num = 1;
void RenewPos();
#define YY_USER_ACTION RenewPos();
const int PRINT_INFO = 0;

extern FILE *output;

char *temp;
char *nodeLable;

%}

%x comment

%option noyywrap
%option yylineno
%option nounput

%%


"/*"      	BEGIN(comment);
<comment>{
[^*\n]*
"*"+[^*/\n]*
[\n]             
"*"+"/"     BEGIN(INITIAL);
}

0x0|0X0|00|0 					{ strcpy(nodeLable, "INT: "); 	strcat(nodeLable, yytext); if (PRINT_INFO) fprintf(output, "int "); 		return INT;}
[1-9][0-9]* 					{ strcpy(nodeLable, "INT: "); 	strcat(nodeLable, yytext); if (PRINT_INFO) fprintf(output, "int ");  	return INT;}
-[1-9][0-9]* 					{ strcpy(nodeLable, "NEGINT: ");strcat(nodeLable, yytext); if (PRINT_INFO) fprintf(output, "negint ");  	return NEGINT;}
0[1-7][0-7]*    				{ strcpy(nodeLable, "INT: "); 	strcat(nodeLable, yytext); if (PRINT_INFO) fprintf(output, "int "); 		return INT;}
-0[1-7][0-7]*   				{ strcpy(nodeLable, "NEGINT: ");strcat(nodeLable, yytext); if (PRINT_INFO) fprintf(output, "negint "); 	return NEGINT;}
0[Xx][1-9a-fA-F][0-9a-fA-F]* 	{ strcpy(nodeLable, "INT: "); 	strcat(nodeLable, yytext); if (PRINT_INFO) fprintf(output, "int "); 		return INT;}
-0[Xx][1-9a-fA-F][0-9a-fA-F]* 	{ strcpy(nodeLable, "NEGINT: ");strcat(nodeLable, yytext); if (PRINT_INFO) fprintf(output, "negint "); 	return NEGINT;}


int			{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "TYPE: ");  strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "int ");  return TYPE;}
struct      { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "STRUCT "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "struct ");return STRUCT;}
return	    { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "RETURN "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "return ");return RETURN;}
if			{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "IF: ");    strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "if ");    return IF;}
else		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "ELSE: ");  strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "else ");  return ELSE;}
break		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "BREAK: "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "break "); return BREAK;}
continue	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "CONT: ");  strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "continue "); 	return CONT;}
for			{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "FOR: ");   strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "for "); 	return FOR;}

write    	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp,"WRITE: "); 	strcat(temp,yytext); if (PRINT_INFO) fprintf(output, "write ");	return WRITE;}
read   	 	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp,"READ: "); 	strcat(temp,yytext); if (PRINT_INFO) fprintf(output, "read ");	return READ;}


[_a-zA-Z][a-zA-Z0-9_]* 			{ nodeLable = (char*)malloc(sizeof(char) * 60); strcpy(nodeLable, "ID: "); strcat(nodeLable, yytext); if (PRINT_INFO) fprintf(output, "ID "); return ID;}

";"     { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "SEMI: ");  	strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "; "); 		return SEMI;}
","     { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "COMMA: "); 	strcat(temp, yytext); if (PRINT_INFO) fprintf(output, ", "); 	return COMMA;}
"."     { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "DOT: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, ". "); 		return DOT;}
"("     { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "LP: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "( "); 		return LP;}
")"     { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "RP: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, ") "); 		return RP;}
"["     { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "LB: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "[ "); 		return LB;}
"]"     { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "RB: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "] "); 		return RB;}
"{"     { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "LC: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "{ "); 		return LC;}
"}"     { temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "RC: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "} "); 		return RC;}

"-"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "MINUS: ");  	strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "- "); 	return MINUS;}
"!"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "LOGICALNOT: ");strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "! ");return LOGICALNOT;}
"++"	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "PREINC: ");  	strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "++ "); 	return PREINC;}
"--"	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "PREDEC: ");  	strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "-- "); 	return PREDEC;}
"~"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "BINARYNOT: "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "! "); return BITNOT;}
"*"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "MUL: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "* ");		return MUL;}
"/"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "DIV: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "/ "); return DIV;}
"%"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "MOD: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "% "); return MOD;}
"+"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "PLUS: ");  	strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "+ "); return PLUS;}
"<<"	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "SHL: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "<< "); return SHL;}
">>"	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "SHR: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, ">> "); return SHR;}
">"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "GT: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "> "); return GT;}
">="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "GE: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, ">= "); return GE;}
"<"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "LT: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "< "); return LT;}
"<="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "LE: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "<= "); return LE;}
"=="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "ET: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "== "); return ET;}
"!="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "NET: ");  		strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "!= "); return NET;}
"&"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "BITAND: ");  	strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "& "); return BITAND;}
"^"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "BITXOR: ");  	strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "^ "); return BITXOR;}
"|"		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "BITOR: ");  	strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "| "); return BITOR;}
"&&"	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "LOGICALAND: ");strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "&& "); return LOGICALAND;}
"||"	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "LOGICALOR: "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "|| "); return LOGICALOR;}

"="		{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "ASSIGN: ");  	strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "= "); return ASSIGN;}
"+="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "PLUSASSIGN: ");strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "+= "); return PLUSASSIGN;}
"-="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp,"MINUSASSIGN: ");strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "-= "); return MINUSASSIGN;}
"*="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "MULASSIGN: "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "*= "); return MULASSIGN;}
"/="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "DIVASSIGN: "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "/= "); return DIVASSIGN;}
"&="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "ANDASSIGN: "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "&= "); return ANDASSIGN;}
"^="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "XORASSIGN: "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "^= "); return XORASSIGN;}
"|="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "ORASSIGN: ");  strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "|= "); return ORASSIGN;}
"<<="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "SHLASSIGN: "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, "<<= "); return SHLASSIGN;}
">>="	{ temp = (char*)malloc(sizeof(char) * 60); strcpy(temp, "SHRASSIGN: "); strcat(temp, yytext); if (PRINT_INFO) fprintf(output, ">>= "); return SHRASSIGN;}

[\n]      	{ ++ line_num;}
[ \t]+ 		{}
"//"(.)*  	{ /* comment */ }

.    {fprintf(output, "error");}
%%

void RenewPos(){
	// yyla.location.first_line = line_num;
}
