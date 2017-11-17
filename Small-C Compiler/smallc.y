
%{

extern "C"{
	void yyerror(const char *s);
	extern int yylex(void);
}

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <string.h>
#include <vector>
#include <math.h>
#include <stdlib.h>
#include <stddef.h>
#include <ctype.h>
#define YYSTYPE double
using namespace std;

extern char *yytext;
extern char *nodeLable;
extern int  line_num;

const int PRINT_INFO = 0; // =1 if debug infomation for parsing needed
const int PRINT_INFO_LLVM = 0; // =1 if debug infomation for LLVM code generation needed

int nodeSize = 10;
int charSize = 60;

FILE *input;
FILE *output;

struct treeNode *root;
struct treeNode *stack[5000];
int top = 0;
int curCode = 0;


struct treeNode
{
    char* lable;
	struct treeNode* child[10];
	int code;
};

struct symbol
{
    char* word;
    char type;
    char* arrSize;
    char* structName;
    int structMem;
};
struct symbol* symTable[27][20];

int 	rNum, callNum, ifNum, forNum, arridxNum;
int 	paraFlag(0), paraPoint(0);
char* 	paraArr[10];
int 	entryDepth(0), loadFlag(1);
char 	*arrName, *arrSize, *strName;
int 	structMemNum;

// From here begin the parsing tree part
struct treeNode* noTermBuild(char* st); // build non-terminal in the tree
struct treeNode* termBuild(char* pST,char* sST);// build terminal in the tree
void noTermInsert(struct treeNode* root, struct treeNode* point);// insert non-terminal in the tree
void termInsert(struct treeNode* root, char* st);// build terminal in the tree
void printTree(struct treeNode* root, int depth);//print out the parsing tree

// From here begin the LLVM part
void CG_Program(struct treeNode* root);
void CG_Extdefs(struct treeNode* t);
void CG_Extdef(struct treeNode* t);
void CG_ExtvarsType(struct treeNode* t);
void CG_DecExt(struct treeNode* t);
void CG_Func(struct treeNode* t);
void CG_Paras(struct treeNode* t);
void CG_Para(struct treeNode* t);
void CG_Stmtblock(struct treeNode* t);
void CG_Defs(struct treeNode* t);
void CG_Def(struct treeNode* t);
void CG_Decs(struct treeNode* t);
void CG_DecInner(struct treeNode* t);
void CG_Stmts(struct treeNode* t);
void CG_Stmt(struct treeNode* t);
char* CG_Exp(struct treeNode* t);
void CG_ArgsExt(struct treeNode* t);
void CG_ArgsInner(struct treeNode* t);
void CG_ArgsFunc(struct treeNode* t);

void CG_ExtdefStruct(struct treeNode* t);
void CG_DecStrId(struct treeNode* t);
void CG_ExtdefStrId(struct treeNode* t);
void CG_ExtvarsStrId(struct treeNode* t);
void CG_ExtdefStrOp(struct treeNode* t);
void CG_DefsStrOp(struct treeNode* t);
void CG_DefStrOp(struct treeNode* t);
%}

%token TYPE STRUCT RETURN IF ELSE BREAK CONT FOR 
%token INT NEGINT ID SEMI COMMA LC RC READ WRITE
%right ASSIGN 
%right PLUSASSIGN MINUSASSIGN MULASSIGN DIVASSIGN ANDASSIGN XORASSIGN ORASSIGN 
%right SHLASSIGN SHRASSIGN 
%left LOGICALOR 
%left LOGICALAND 
%left BITOR BITXOR BITAND 
%left ET NET 
%left GT LT 
%left LE GE 
%left SHL SHR 
%left PLUS MINUS 
%left MUL DIV MOD 
%right LOGICALNOT BITNOT 
%right PREINC PREDEC 
%right LB LP 
%right RB RP 
%right DOT


%%

PROGRAM	: EXTDEFS	{if (PRINT_INFO) cout << top << endl; root = noTermBuild("PROGRAM"); noTermInsert(root, stack[top]); top = top - 1; if (PRINT_INFO) cout << top << endl;}
		;

EXTDEFS	: EXTDEF EXTDEFS	{root = noTermBuild("EXTDEFS"); noTermInsert(root, stack[top - 1]); noTermInsert(root, stack[top]); if (PRINT_INFO) cout << top << endl; top = top - 1; stack[top] = root; if (PRINT_INFO) cout << top << endl;}
		| {top = top + 1; stack[top] = termBuild("EXTDEFS","NULL"); if (PRINT_INFO) cout << top << endl;}
		;

EXTDEF	: SPEC EXTVARS SEMI		{ if (PRINT_INFO) cout << top << endl; root = noTermBuild("EXTDEF"); noTermInsert(root, stack[top - 1]); noTermInsert(root, stack[top]); termInsert(root,"SEMI"); stack[-- top] = root; if (PRINT_INFO) cout << top << endl;}
		| SPEC FUNC STMTBLOCK	{ if (PRINT_INFO) cout << top << endl; root = noTermBuild("EXTDEF"); noTermInsert(root, stack[top - 2]); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root, stack[top - 1]); noTermInsert(root, stack[top]); if (PRINT_INFO) cout << root->lable << endl; top = top - 2; stack[top] = root; if (PRINT_INFO) cout << top << endl;}
		;

EXTVARS	: DEC	{ root = noTermBuild("EXTVARS"); noTermInsert(root,stack[top]); stack[top] = root;}
		| DEC COMMA EXTVARS		{ root = noTermBuild("EXTVARS"); noTermInsert(root,stack[top-1]); termInsert(root,"COMMA"); noTermInsert(root,stack[top]); stack[-- top]=root;}
		| {top = top + 1; stack[top] = termBuild("EXTVARS","NULL");}
		;

SPEC	: TYPE	{top = top + 1; stack[top] = termBuild("SPEC", "TYPE");}
		| STSPEC	{ root = noTermBuild("SPEC"); noTermInsert(root, stack[top]); stack[top] = root; if (PRINT_INFO) cout << top << endl;}
		;

STSPEC	: STRUCT OPTTAG LC DEFS RC	{if (PRINT_INFO) cout << top << endl; root = noTermBuild("STSPEC"); termInsert(root, "STRUCT"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root, stack[top - 1]); termInsert(root, "LC"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root, stack[top]); termInsert(root, "RC"); if (PRINT_INFO) cout << root->lable << endl; stack[-- top] = root; if (PRINT_INFO) cout << top << endl;}
		| STRUCT THEID		{ root = noTermBuild("STSPEC"); termInsert(root, "STRUCT"); noTermInsert(root,stack[top]); stack[top]=root;}
		;

OPTTAG	: THEID{root=noTermBuild("OPTTAG"); noTermInsert(root,stack[top]); stack[top]=root;}
		| {top = top + 1; stack[top]=termBuild("OPTTAG","NULL"); if (PRINT_INFO) cout << top << endl;}
		;

VAR		: THEID	{root=noTermBuild("VAR"); noTermInsert(root,stack[top]); stack[top]=root;}
		| VAR LB INT RB	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("VAR"); noTermInsert(root,stack[top]); termInsert(root,"LB"); termInsert(root,nodeLable); termInsert(root,"RB"); stack[top]=root;  if (PRINT_INFO) cout << top << endl;}
		;

FUNC	: THEID LP PARAS RP	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("FUNC"); noTermInsert(root,stack[top-1]); termInsert(root,"LP"); noTermInsert(root,stack[top]); termInsert(root,"RP"); stack[-- top]=root; if (PRINT_INFO) cout << top << endl;}
		;

PARAS	: PARA COMMA PARAS	{ root=noTermBuild("PARAS"); noTermInsert(root,stack[top-1]); if (PRINT_INFO) cout << root->lable << endl; termInsert(root,"COMMA"); noTermInsert(root,stack[top]); if (PRINT_INFO) cout << root->lable << endl; stack[-- top]=root;if (PRINT_INFO) cout << top << endl;}
		| PARA	{ root=noTermBuild("PARAS"); noTermInsert(root,stack[top]); stack[top]=root;}
		| {top = top + 1; stack[top]=termBuild("PARAS","NULL"); if (PRINT_INFO) cout << top << endl;}
		;

PARA	: SPEC VAR	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("PARA"); noTermInsert(root,stack[top-1]); noTermInsert(root,stack[top]); stack[-- top]=root; if (PRINT_INFO) cout << top << endl;}
		;

STMTBLOCK: LC DEFS STMTS RC	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("STMTBLOCK"); termInsert(root,"LC"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root,stack[top-1]); noTermInsert(root,stack[top]); termInsert(root,"RC"); stack[-- top]=root; if (PRINT_INFO) cout << top << endl;}
		;

STMTS	: STMT STMTS	{ root=noTermBuild("STMTS"); noTermInsert(root,stack[top-1]); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root,stack[top]);  if (PRINT_INFO) cout << root->lable << endl; stack[-- top]=root;if (PRINT_INFO) cout << top << endl;}
		| {top = top + 1; stack[top]=termBuild("STMTS","NULL");}
		;

STMT	: EXP SEMI	{ root = noTermBuild("STMT"); noTermInsert(root,stack[top]); termInsert(root,"SEMI"); stack[top]=root;}
		| STMTBLOCK	{ root=noTermBuild("STMT"); noTermInsert(root,stack[top]); stack[top]=root;}
		| RETURN EXP SEMI	{ root=noTermBuild("STMT"); termInsert(root,"RETURN"); noTermInsert(root,stack[top]); termInsert(root,"SEMI"); stack[top] = root;  if (PRINT_INFO) cout << top << endl;}
		| IF LP EXP RP STMT ESTMT	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("STMT"); termInsert(root,"IF"); if (PRINT_INFO) cout << root->lable << endl; termInsert(root,"LP"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root,stack[top-2]); termInsert(root,"RP"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root,stack[top - 1]); noTermInsert(root,stack[top]); top = top - 2; stack[top]=root; if (PRINT_INFO) cout << top << endl;}
		| FOR LP EXP SEMI EXP SEMI EXP RP STMT	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("STMT"); termInsert(root,"FOR"); if (PRINT_INFO) cout << root->lable << endl; termInsert(root,"LP"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root,stack[top-3]); if (PRINT_INFO) cout << root->lable << endl; termInsert(root,"SEMI"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root,stack[top-2]); if (PRINT_INFO) cout << root->lable << endl; termInsert(root,"SEMI"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root,stack[top-1]); if (PRINT_INFO) cout << root->lable << endl; termInsert(root,"RP"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root,stack[top]); if (PRINT_INFO) cout << root->lable << endl; top = top - 3; stack[top]=root; if (PRINT_INFO) cout << top << endl;}
		| CONT SEMI	{if (PRINT_INFO) cout << top << endl;  root=noTermBuild("STMT"); termInsert(root,"CONT"); if (PRINT_INFO) cout << root->lable << endl; termInsert(root,"SEMI"); if (PRINT_INFO) cout << root->lable << endl; top = top + 1; stack[top]=root;}
		| BREAK SEMI	{ root=noTermBuild("STMT"); termInsert(root,"BREAK"); termInsert(root,"SEMI"); top = top + 1; stack[top]=root;}
		;

ESTMT	: ELSE STMT	{ root=noTermBuild("ESTMT"); termInsert(root,"ELSE"); noTermInsert(root,stack[top]); stack[top]=root;}
		| {top = top + 1; stack[top]=termBuild("ESTMT","NULL"); if (PRINT_INFO) cout << top << endl;}
		;

DEFS	: DEF DEFS	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("DEFS"); noTermInsert(root,stack[top-1]); noTermInsert(root,stack[top]); stack[-- top]=root; if (PRINT_INFO) cout << top << endl;}
		| {top = top + 1; stack[top]=termBuild("DEFS","NULL"); if (PRINT_INFO) cout << top << endl;}
		;

DEF		: SPEC DECS SEMI	{ root=noTermBuild("DEF"); noTermInsert(root,stack[top-1]); noTermInsert(root,stack[top]); termInsert(root,"SEMI"); stack[-- top]=root;}
		;

DECS	: DEC COMMA DECS	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("DECS"); noTermInsert(root,stack[top-1]); termInsert(root,"COMMA"); noTermInsert(root,stack[top]); stack[-- top]=root; if (PRINT_INFO) cout << top << endl;}
		| DEC	{ root=noTermBuild("DECS"); noTermInsert(root,stack[top]); stack[top]=root; if (PRINT_INFO) cout << top << endl;}
		;

DEC		: VAR	{ root=noTermBuild("DEC"); noTermInsert(root,stack[top]); stack[top]=root;}
		| VAR ASSIGN INIT	{ root=noTermBuild("DEC"); noTermInsert(root,stack[top-1]); termInsert(root,"ASSIGN"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		;

INIT	: EXP	{ root=noTermBuild("INIT"); noTermInsert(root,stack[top]); stack[top]=root;}
		| LC ARGS RC	{ root=noTermBuild("INIT"); termInsert(root,"LC"); noTermInsert(root,stack[top]); termInsert(root,"RC"); stack[top]=root;}
		;

EXP		: EXP DOT EXP	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root, "DOT"); noTermInsert(root, stack[top]); stack[-- top]=root; if (PRINT_INFO) cout << top << endl;}
		| EXP ASSIGN EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"ASSIGN"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP PLUS EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"PLUS"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP MINUS EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"MINUS"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP MUL EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"MUL"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP DIV EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"DIV"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP MOD EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"MOD"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP SHLASSIGN EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"SHLASSIGN"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP SHRASSIGN EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"SHRASSIGN"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP SHL EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"SHL"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP SHR EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"SHR"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP LT EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"LT"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP GT EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"GT"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP LE EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"LE"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP GE EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"GE"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP ET EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"ET"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP NET EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"NET"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP LOGICALAND EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"LOGICALAND"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP LOGICALOR EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"LOGICALOR"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP BITAND EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"BITAND"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP BITXOR EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"BITXOR"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP BITOR EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"BITOR"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP PLUSASSIGN EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"PLUSASSIGN"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP MINUSASSIGN EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"MINUSASSIGN"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP MULASSIGN EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"MULASSIGN"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP DIVASSIGN EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"DIVASSIGN"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP ANDASSIGN EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"BITAND"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP XORASSIGN EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"BITXOR"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP ORASSIGN EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"BITOR"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| PREINC EXP	{ root=noTermBuild("EXP"); termInsert(root,"PREINC"); noTermInsert(root,stack[top]); stack[top]=root;}
		| PREDEC EXP	{ root=noTermBuild("EXP"); termInsert(root,"PREDEC"); noTermInsert(root,stack[top]); stack[top]=root;}
		| LOGICALNOT EXP	{ root=noTermBuild("EXP"); termInsert(root,"LOGICALNOT"); noTermInsert(root,stack[top]); stack[top]=root;}
		| BITNOT EXP	{ root=noTermBuild("EXP"); termInsert(root,"BITNOT"); noTermInsert(root,stack[top]); stack[top]=root;}
		| LP EXP RP	{ root=noTermBuild("EXP"); termInsert(root,"LP"); noTermInsert(root,stack[top]); termInsert(root,"RP"); stack[top]=root; if (PRINT_INFO) cout << top << endl;}
		| THEID LP ARGS RP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"LP"); noTermInsert(root,stack[top]); top = top - 1; termInsert(root,"RP"); stack[top]=root; if (PRINT_INFO) cout << top << endl;}
		| THEID ARRS	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root; if (PRINT_INFO) cout << top << endl;}
		| EXP DOT THEID	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"DOT"); noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
		| EXP NEGINT	{root=noTermBuild("EXP"); noTermInsert(root,stack[top]); termInsert(root,nodeLable); stack[top]=root;}
		| NEGINT	{top = top + 1; stack[top]=termBuild("EXP",nodeLable);}
		| INT	{top = top + 1; stack[top]=termBuild("EXP",nodeLable);}
		| {top = top + 1; stack[top]=termBuild("EXP","NULL");}
		| WR	{root = noTermBuild("EXP"); noTermInsert(root, stack[top]); stack[top]=root;}
		;

THEID	: 	ID	{if (PRINT_INFO) cout << top << endl; top = top + 1; stack[top]=termBuild("THEID",nodeLable); if (PRINT_INFO) cout << top << endl;}
		;

WR		: WRITE LP EXP RP {root=noTermBuild("WR"); termInsert(root,"WRITE"); termInsert(root,"LP"); noTermInsert(root,stack[top]);  termInsert(root,"RP"); stack[top]=root;}
		| READ LP EXP RP {root=noTermBuild("WR"); termInsert(root,"READ"); termInsert(root,"LP"); noTermInsert(root,stack[top]);  termInsert(root,"RP"); stack[top]=root;}
		;

ARRS	: LB EXP RB ARRS	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("ARRS"); termInsert(root,"LB"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root,stack[top - 1]); termInsert(root,"RB"); if (PRINT_INFO) cout << root->lable << endl; noTermInsert(root,stack[top]); stack[-- top]=root; if (PRINT_INFO) cout << top << endl;}
		| {stack[++ top] = termBuild("ARRS","NULL"); if (PRINT_INFO) cout << root->lable << endl; if (PRINT_INFO) cout << top << endl;}
		;

ARGS	: EXP COMMA ARGS	{if (PRINT_INFO) cout << top << endl; root=noTermBuild("ARGS"); noTermInsert(root,stack[top - 1]); termInsert(root,"COMMA"); noTermInsert(root,stack[top]); stack[-- top]=root; if (PRINT_INFO) cout << top << endl;}
		| EXP	{if (PRINT_INFO) cout << top << endl; root = noTermBuild("ARGS"); noTermInsert(root,stack[top]); stack[top]=root; if (PRINT_INFO) cout << top << endl;}
		//| {top = top + 1; stack[top]=termBuild("ARGS","NULL");}
		;


%%

int main(int argc, char **argv)
{
	input = fopen(argv[1], "r");
	output = fopen(argv[2], "w");
	if(!input) {
		perror(argv[1]);
		return 1;
	}
	if(!output) {
		perror(argv[2]);
		return 1;
	}
	printf("\n");
	line_num = 1;
	extern FILE *yyin, *yyout;
	yyin = input;
	yyout = output;

	yyparse();

	
	// the parsing tree part
	// printTree(root,0);
	
	cout << "File: " << argv[1] << " Parsing complete\n";

	CG_Program(root);

	fclose(input);
	fclose(output);
	return 0;
}


void yyerror(const char *s)
{
	fprintf(stderr, "%s %s\n", s, yytext);
}


//////////////////////////////////////////////////////////////
//            Here starts all the parsing tree part         //
//////////////////////////////////////////////////////////////

// build non-terminal in the tree
struct treeNode* noTermBuild(char* st)
{
	struct treeNode* rNode = (struct treeNode*)malloc(sizeof(struct treeNode));
	rNode->lable = (char*)malloc(sizeof(char)*charSize);
	strcpy(rNode->lable, st);
    int i;
	for (int i = 0; i < nodeSize; i ++) 
		rNode->child[i] = NULL;
	rNode->code = curCode;
	curCode = curCode + 1;
	return rNode;
}

// build terminal in the tree
struct treeNode* termBuild(char* pST,char* sST)
{
	struct treeNode* pNode = (struct treeNode*)malloc(sizeof(struct treeNode));
	pNode->lable = (char*)malloc(sizeof(char)*charSize);
	strcpy(pNode->lable, pST);
	for (int i = 0; i < nodeSize; i ++) 
		pNode->child[i] = NULL;
	pNode->code = curCode;
	curCode = curCode + 1;

	pNode->child[0] = (struct treeNode*)malloc(sizeof(struct treeNode));
	pNode->child[0]->lable = (char*)malloc(sizeof(char)*charSize);
	strcpy(pNode->child[0]->lable,sST);
	for (int i = 0; i < nodeSize; i ++) 
		pNode->child[0]->child[i] = NULL;
	pNode->child[0]->code = curCode;
	curCode = curCode + 1;
	return pNode;
}

// insert non-terminal in the tree
void noTermInsert(struct treeNode* root, struct treeNode* point)
{
    int temp;
    for (temp = 0; root->child[temp]; temp ++);
	root->child[temp] = NULL;
	if (point) root->child[temp] = point;
}

// build terminal in the tree
void termInsert(struct treeNode* root, char* st)
{
	int temp;
    for (temp = 0; root->child[temp]; temp ++);
    if (PRINT_INFO) cout << temp << endl;
	root->child[temp] = (struct treeNode*)malloc(sizeof(struct treeNode));
    if (PRINT_INFO) cout << st << endl;
	root->child[temp]->lable = (char*)malloc(sizeof(char)*charSize);
	strcpy(root->child[temp]->lable, st);
	for (int k = 0; k < nodeSize; k ++) 
		root->child[temp]->child[k] = NULL;
	root->child[temp]->code = curCode;
	curCode = curCode + 1;
}

//print out the parsing tree
void printTree(struct treeNode* root, int depth)
{
    for (int i = 0; i < (depth - 1) * 4; ++ i)
    	if (i % 4 == 0)
    		fprintf(output, "|");
    	else fprintf(output, " ");
    if (depth) fprintf(output, "|---");
	fprintf(output, "%s\n",root->lable);

	int temp = 0;
	if (root->child[temp]) 
		depth = depth + 1;
	while (root->child[temp])
		printTree(root->child[temp ++],depth);
}



//////////////////////////////////////////////////////////////
//                Here starts all the LLVM part             //
//////////////////////////////////////////////////////////////

void CG_Program(struct treeNode* root) //root of all syntax trees
{
    fprintf(output, "@.str = private unnamed_addr constant [3 x i8] c\"%%d\\00\", align 1\n");
    fprintf(output, "@.str1 = private unnamed_addr constant [2 x i8] c\"\\0A\\00\", align 1\n"); //这玩意儿是为LLVM IR中的换行符准备的

	if (PRINT_INFO_LLVM) cout << "CG_Program before" << endl;

    CG_Extdefs(root->child[0]);

	if (PRINT_INFO_LLVM) cout << "CG_Program after" << endl;

    fprintf(output, "\ndeclare i32 @__isoc99_scanf(i8*, ...) #1\n");
    fprintf(output, "declare i32 @printf(i8*, ...) #1\n");
}

// External Definition S
void CG_Extdefs(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Extdefs" << endl;
    if (t->child[1]) //EXTDEF EXTDEFS
    {
		if (PRINT_INFO_LLVM) cout << "CG_Extdefs step 1" << endl;
        CG_Extdef(t->child[0]);
		if (PRINT_INFO_LLVM) cout << "CG_Extdefs step 2" << endl;
        CG_Extdefs(t->child[1]);
    }
}

// External Definition
void CG_Extdef(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Extdef" << endl;
    if (t->child[1]->lable[0]=='E') { 	//SPEC EXTVARS SEMI
        if (t->child[0]->child[0]->lable[0]=='T') { //TYPE, int case
			if (PRINT_INFO_LLVM) cout << "CG_Extdef step 1" << endl;
            CG_ExtvarsType(t->child[1]);
        } else {						//STSPEC, struct case
			if (PRINT_INFO_LLVM) cout << "CG_Extdef step 2" << endl;	
            CG_ExtdefStruct(t);
        }
    } else {							//SPEC FUNC STMTBLOCK
		if (PRINT_INFO_LLVM) cout << "CG_Extdef step 3.1" << endl;
        CG_Func(t->child[1]);
		if (PRINT_INFO_LLVM) cout << "CG_Extdef step 3.2" << endl;
        CG_Stmtblock(t->child[2]);
    }
}

//External Definition of Struct
void CG_ExtdefStruct(struct treeNode* t) 
{
	if (PRINT_INFO_LLVM) cout << "CG_ExtdefStruct" << endl;
    if (t->child[0]->child[0]->child[1]->lable[0]=='T') {//STRUCT THEID
		if (PRINT_INFO_LLVM) cout << "CG_ExtdefStruct step 1" << endl;
        CG_ExtdefStrId(t);
    }
    else {
    	CG_ExtdefStrOp(t);
		if (PRINT_INFO_LLVM) cout << "CG_ExtdefStruct step 2" << endl;
    }
}

//STSPEC -> STRUCT OPTTAG LC DEFS RC
void CG_ExtdefStrOp(struct treeNode* t) 
{
	if (PRINT_INFO_LLVM) cout << "CG_ExtdefStrOp" << endl;
    struct treeNode* nodeId = t->child[0]->child[0]->child[1]->child[0]->child[0];

	if (PRINT_INFO_LLVM) cout << "CG_ExtdefStrOp step 1" << endl;
    char* tmp = (char*)malloc(sizeof(char)*200);
    int len = strlen(nodeId->lable);
    for (int i = 4; i <= len; i ++) 
    	tmp[i - 4] = nodeId->lable[i];

    structMemNum = 0;
    fprintf(output, "%%struct.%s = type { ",tmp);
	if (PRINT_INFO_LLVM) cout << "CG_ExtdefStrOp step 2" << endl;
    CG_DefsStrOp(t->child[0]->child[0]->child[3]);
    fprintf(output, " }\n",tmp);
    structMemNum = 0;
}

// STSPEC -> STRUCT OPTTAG LC DEFS RC case
void CG_DefsStrOp(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_DefsStrOp" << endl;
    if (t->child[1]) {//DEF DEFS
		if (PRINT_INFO_LLVM) cout << "CG_DefsStrOp step 1" << endl;
        CG_DefStrOp(t->child[0]);
        structMemNum ++;
        if (strcmp(t->child[1]->child[0]->lable,"NULL")) 
        	fprintf(output, ", ");
		if (PRINT_INFO_LLVM) cout << "CG_DefsStrOp step 2" << endl;
        CG_DefsStrOp(t->child[1]);
    }
}

// STSPEC -> STRUCT OPTTAG LC DEFS RC case
void CG_DefStrOp(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_DefStrOp" << endl;
    struct treeNode* nodeId = t->child[1]->child[0]->child[0]->child[0]->child[0];

    char* tmp = (char*)malloc(sizeof(char)*200);
    int len = strlen(nodeId->lable);
    for (int i = 4; i <= len; i ++) 
    	tmp[i - 4] = nodeId->lable[i];

    int dim1 = tmp[0]-'a';
    if (dim1<0) dim1 = tmp[0]-'A';
    if (tmp[0]=='_') dim1 = 26;
    int i = 0;
    while (symTable[dim1][i]) i++;
	if (PRINT_INFO_LLVM) cout << "CG_DefStrOp step 1" << endl;
    symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
    struct symbol* s = symTable[dim1][i];
    s->word = (char*)malloc(sizeof(char)*200);
    strcpy(s->word,tmp);
    s->structMem = structMemNum;
	if (PRINT_INFO_LLVM) cout << "CG_DefStrOp step 2" << endl;

    fprintf(output, "i32");
}

// STRUCT THEID External Definition
void CG_ExtdefStrId(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_ExtdefStrId" << endl;
    strName = (char*)malloc(sizeof(char)*200);

    struct treeNode* nodeId = t->child[0]->child[0]->child[1]->child[0];
	if (PRINT_INFO_LLVM) cout << "CG_ExtdefStrId step 1" << endl;
    char* tmp = (char*)malloc(sizeof(char)*200);
    int len = strlen(nodeId->lable);
    for (int i = 4; i <= len; i ++) 
    	tmp[i - 4] = nodeId->lable[i];

	if (PRINT_INFO_LLVM) cout << "CG_ExtdefStrId step 2" << endl;
    strcpy(strName,tmp);
    CG_ExtvarsStrId(t->child[1]);
    free(strName);
}

// STRUCT ID External Var
void CG_ExtvarsStrId(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_ExtvarsStrId" << endl;
    if (t->child[1])
    {
        CG_DecStrId(t->child[0]);
		if (PRINT_INFO_LLVM) cout << "CG_ExtvarsStrId step 1" << endl;
        CG_ExtvarsStrId(t->child[2]);
    }
    else CG_DecStrId(t->child[0]);
}

// STRUCT ID Declaration
void CG_DecStrId(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_DecStrId" << endl;
    struct treeNode* nodeId = t->child[0]->child[0]->child[0];
    char* tmp = (char*)malloc(sizeof(char)*200);
	if (PRINT_INFO_LLVM) cout << "CG_DecStrId step 1" << endl;
    int len = strlen(nodeId->lable);
    for (int i = 4; i <= len; i ++) 
    	tmp[i - 4] = nodeId->lable[i];

    int dim1 = tmp[0]-'a';
    if (dim1<0) dim1 = tmp[0]-'A';
    if (tmp[0]=='_') dim1 = 26;
    int i = 0;
    while (symTable[dim1][i]) i ++;
    symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
    struct symbol* s = symTable[dim1][i];
    s->word = (char*)malloc(sizeof(char)*200);
	if (PRINT_INFO_LLVM) cout << "CG_DecStrId step 2" << endl;
    strcpy(s->word,tmp);
    s->structName = (char*)malloc(sizeof(char)*200);
    strcpy(s->structName,strName);
    s->type = 'g';

    fprintf(output, "@%s",tmp);
    fprintf(output, " = common global %%struct.%s zeroinitializer, align 4\n",strName);
}

// TYPE External Var
void CG_ExtvarsType(struct treeNode* t) 
{
	if (PRINT_INFO_LLVM) cout << "CG_ExtvarsType" << endl;
    if (t->child[1] == NULL) {	//DEC
		if (PRINT_INFO_LLVM) cout << "CG_ExtvarsType step 1" << endl;
        CG_DecExt(t->child[0]); 
	} else {					//DEC COMMA EXTVARS
		if (PRINT_INFO_LLVM) cout << "CG_ExtvarsType step 2.1" << endl;
        CG_DecExt(t->child[0]);
		if (PRINT_INFO_LLVM) cout << "CG_ExtvarsType step 2.2" << endl;
        CG_ExtvarsType(t->child[2]);
    }
}

// Global Var
void CG_DecExt(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_DecExt" << endl;
    if (t->child[1]==NULL) 				//VAR
    {
        struct treeNode* nodeVar = t->child[0];
        if (nodeVar->child[1]==NULL)
        {
            fprintf(output, "@");
            struct treeNode* nodeId = nodeVar->child[0]->child[0];
			if (PRINT_INFO_LLVM) cout << "CG_DecExt step 1" << endl;
            int len = strlen(nodeId->lable);

            char* tmp = (char*)malloc(sizeof(char)*60);
    for (int i = 4; i <= len; i ++) 
    	tmp[i - 4] = nodeId->lable[i];
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            int i=0;
            while (symTable[dim1][i]) i++;
            symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
            struct symbol* s = symTable[dim1][i];
            s->word = (char*)malloc(sizeof(char)*60);
            strcpy(s->word,tmp);
            s->type = 'g';

            fprintf(output, "%s",tmp);
            fprintf(output, " = common global i32 0, align 4\n");
        }
        else //case 3. a[3]
        {
            //@b = common global [20 x i32] zeroinitializer, align 4
            fprintf(output, "@");
            struct treeNode* nodeId = nodeVar->child[0]->child[0]->child[0];
			if (PRINT_INFO_LLVM) cout << "CG_DecExt step 2" << endl;
            int len = strlen(nodeId->lable);

            char* tmp = (char*)malloc(sizeof(char)*60);
    		for (int i = 4; i <= len; i ++) 
    			tmp[i - 4] = nodeId->lable[i];
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            int i=0;
            while (symTable[dim1][i]) i++;
            symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
            struct symbol* s = symTable[dim1][i];
            s->word = (char*)malloc(sizeof(char)*60);
            strcpy(s->word,tmp);
            s->type = 'g';

            fprintf(output, "%s",tmp);
            fprintf(output, " = common global [");
            struct treeNode* nodeInt = nodeVar->child[2];
            len = strlen(nodeInt->lable);
            for (int i = 5; i < len; i ++) 
            	fprintf(output, "%c",nodeInt->lable[i]);

            s->arrSize = (char*)malloc(sizeof(char)*60);
            for (int i = 5; i <= len; i ++) 
            	s->arrSize[i - 5] = nodeInt->lable[i];

            fprintf(output, " x i32] zeroinitializer, align 4\n");
        }
    }
    else //VAR ASSIGN INIT case
    {
        struct treeNode* nodeVar = t->child[0]; //node of VAR
        if (nodeVar->child[1]==NULL) //case 2. a = 1
        {
            //@ans = global i32 0, align 4
            fprintf(output, "@");
            struct treeNode* nodeId = nodeVar->child[0]->child[0];
			if (PRINT_INFO_LLVM) cout << "CG_DecExt step 3" << endl;
            int len = strlen(nodeId->lable);

            char* tmp = (char*)malloc(sizeof(char)*60);
   			for (int i = 4; i <= len; i ++) 
    			tmp[i - 4] = nodeId->lable[i];
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            int i=0;
            while (symTable[dim1][i]) i++;
            symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
            struct symbol* s = symTable[dim1][i];
            s->word = (char*)malloc(sizeof(char)*60);
            strcpy(s->word,tmp);
            s->type = 'g';

            fprintf(output, "%s",tmp);

            struct treeNode* nodeInit = t->child[2]->child[0]->child[0];
            len = strlen(nodeInit->lable);
    		for (int i = 5; i <= len; i ++) 
    			tmp[i - 5] = nodeInit->lable[i];

            fprintf(output, " = global i32 %s, align 4\n",tmp);
        }
        else 
        {
            fprintf(output, "@");
            struct treeNode* nodeId = nodeVar->child[0]->child[0]->child[0];
			if (PRINT_INFO_LLVM) cout << "CG_DecExt step 4" << endl;
            int len = strlen(nodeId->lable);

            char* tmp = (char*)malloc(sizeof(char)*60);
            int i=4; for (i=4;i<=len;i++) tmp[i-4] = nodeId->lable[i];
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            i=0;
            while (symTable[dim1][i]) i++;
            symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
            struct symbol* s = symTable[dim1][i];
            s->word = (char*)malloc(sizeof(char)*60);
            strcpy(s->word,tmp);
            s->type = 'g';

            fprintf(output, "%s",tmp);
            fprintf(output, " = global [");
            struct treeNode* nodeInt = nodeVar->child[2];
            len = strlen(nodeInt->lable);
            for (int i = 5; i < len; i ++) 
            	fprintf(output, "%c",nodeInt->lable[i]);

            s->arrSize = (char*)malloc(sizeof(char)*60);
            for (int i = 5; i <= len; i ++) 
            	s->arrSize[i-5] = nodeInt->lable[i];

            fprintf(output, " x i32] [");
            CG_ArgsExt(t->child[2]->child[1]);
            fprintf(output, "], align 4\n");
        }
    }
}

// External Arg
void CG_ArgsExt(struct treeNode* t)
{
    if (t->child[1]==NULL) 		//EXP
    {
        fprintf(output, "i32 ");
        char* val = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_ArgsExt step 1.1" << endl;
        val = CG_Exp(t->child[0]);
        fprintf(output, "%s",val);
    } else {					//EXP COMMA ARGS
        fprintf(output, "i32 ");
        char* val = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_ArgsExt step 2.1" << endl;
        val = CG_Exp(t->child[0]);
        fprintf(output, "%s, ",val);
		if (PRINT_INFO_LLVM) cout << "CG_ArgsExt step 2.2" << endl;
        CG_ArgsExt(t->child[2]);
    }
}

// Function
void CG_Func(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Func" << endl;
    rNum = callNum = ifNum = forNum = arridxNum = 0;

    fprintf(output, "\n");
    fprintf(output, "define i32 @");

    struct treeNode* nodeId = t->child[0]->child[0];
    int len = strlen(nodeId->lable);

	if (PRINT_INFO_LLVM) cout << "CG_Func step 1" << endl;
    char* tmp = (char*)malloc(sizeof(char)*60);
   	for (int i = 4; i <= len; i ++) 
   		tmp[i - 4] = nodeId->lable[i];

    fprintf(output, "%s(",tmp);
    if (t->child[2]->child[0]->lable[0]=='N') {
		if (PRINT_INFO_LLVM) cout << "CG_Func step 2.0" << endl;
    	paraFlag = 0;
    } else {
        paraFlag = 1;
		if (PRINT_INFO_LLVM) cout << "CG_Func step 2" << endl;
        CG_Paras(t->child[2]);
    }
    fprintf(output, ") #0\n");
}

// parametres
void CG_Paras(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Paras" << endl;
    if (t->child[0]->lable[0]=='N') {}
    else if (t->child[1]) 				//PARA COMMA PARAS
    {
		if (PRINT_INFO_LLVM) cout << "CG_Paras step 1.0" << endl;
        CG_Para(t->child[0]);
        fprintf(output, ", ");
		if (PRINT_INFO_LLVM) cout << "CG_Paras step 1.1" << endl;
        CG_Paras(t->child[2]);
    }
    else CG_Para(t->child[0]); 			//PARA
}

// parametre
void CG_Para(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Para" << endl;
    struct treeNode* nodeId = t->child[1]->child[0]->child[0];
    int len = strlen(nodeId->lable);
	if (PRINT_INFO_LLVM) cout << "CG_Para step 1" << endl;
    char* tmp = (char*)malloc(sizeof(char)*60);
    int i=4; for (i=4;i<=len;i++) tmp[i-4] = nodeId->lable[i];
    int dim1 = tmp[0]-'a';
    if (dim1<0) dim1 = tmp[0]-'A';
    if (tmp[0]=='_') dim1 = 26;
    i=0;
    while (symTable[dim1][i]) i++;
    symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
    struct symbol* s = symTable[dim1][i];
    s->word = (char*)malloc(sizeof(char)*60);
    strcpy(s->word,tmp);
    s->type = 'a';

    fprintf(output, "i32 %%");
    fprintf(output, "%s",tmp);

    paraArr[paraPoint] = (char*)malloc(sizeof(char)*60);
    strcpy(paraArr[paraPoint],tmp);
	if (PRINT_INFO_LLVM) cout << "CG_Para step 2" << endl;
    paraPoint++;
}

// statement block
void CG_Stmtblock(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Stmtblock" << endl;
    if (!entryDepth)
    {
        fprintf(output, "{\n");
        fprintf(output, "entry:\n");
    }

    if (paraFlag)
    {
        int i=0;
        while (paraArr[i])
        {
            fprintf(output, "  %%%s.addr = alloca i32, align 4\n",paraArr[i]);
            fprintf(output, "  store i32 %%%s, i32* %%%s.addr, align 4\n",paraArr[i],paraArr[i]);
            free(paraArr[i]);
            i++;
			if (PRINT_INFO_LLVM) cout << "CG_Stmtblock step " << i << endl;
        }
        paraFlag = 0;
        paraPoint = 0;
    }

	if (PRINT_INFO_LLVM) cout << "CG_Stmtblock step 1" << endl;
    CG_Defs(t->child[1]);
	if (PRINT_INFO_LLVM) cout << "CG_Stmtblock step 2"  << endl;
    CG_Stmts(t->child[2]);

    if (!entryDepth) fprintf(output, "}\n");
}

// Definitions
void CG_Defs(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Defs" << endl;
    if (t->child[1]==NULL) {}
    else
    {
		if (PRINT_INFO_LLVM) cout << "CG_Defs step 1" << endl;
        CG_Def(t->child[0]);
		if (PRINT_INFO_LLVM) cout << "CG_Defs step 2" << endl;
        CG_Defs(t->child[1]);
    }
}

// Definition
void CG_Def(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Def" << endl;
    CG_Decs(t->child[1]);
}

// Declartions
void CG_Decs(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Decs" << endl;
    if (t->child[1] == NULL) {				//DEC
		if (PRINT_INFO_LLVM) cout << "CG_Decs step 1.1" << endl;
        CG_DecInner(t->child[0]);
    } else {								//DEC COMMA DECS
		if (PRINT_INFO_LLVM) cout << "CG_Decs step 2.1" << endl;
        CG_DecInner(t->child[0]);
		if (PRINT_INFO_LLVM) cout << "CG_Decs step 2.2" << endl;
        CG_Decs(t->child[2]);
    }
}

void CG_DecInner(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_DecInner" << endl;
    if (t->child[1]==NULL) 					//VAR case
    {
        struct treeNode* nodeVar = t->child[0];
        if (nodeVar->child[1]==NULL)
        {
            fprintf(output, "  %%");
            struct treeNode* nodeId = nodeVar->child[0]->child[0];
			if (PRINT_INFO_LLVM) cout << "CG_DecInner step 1" << endl;
            int len = strlen(nodeId->lable);

            char* tmp = (char*)malloc(sizeof(char)*60);
            int i=4; for (i=4;i<=len;i++) tmp[i-4] = nodeId->lable[i];
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            i=0;
            while (symTable[dim1][i]) i++;

            symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
            struct symbol* s = symTable[dim1][i];
            s->word = (char*)malloc(sizeof(char)*60);
            strcpy(s->word,tmp);
            s->type = 'l';

            fprintf(output, "%s",tmp);
            fprintf(output, " = alloca i32, align 4\n");
        }
        else
        {
            fprintf(output, "  %%");
            struct treeNode* nodeId = nodeVar->child[0]->child[0]->child[0];
			if (PRINT_INFO_LLVM) cout << "CG_DecInner step 2" << endl;
            int len = strlen(nodeId->lable);

            char* tmp = (char*)malloc(sizeof(char)*60);
            for (int i = 4; i <= len; i ++) 
            	tmp[i - 4] = nodeId->lable[i];
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            int i = 0;
            while (symTable[dim1][i]) i++;
            symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
            struct symbol* s = symTable[dim1][i];
            s->word = (char*)malloc(sizeof(char)*60);
            strcpy(s->word,tmp);
            s->type = 'l';

            fprintf(output, "%s",tmp);
            fprintf(output, " = alloca [");
            struct treeNode* nodeInt = nodeVar->child[2];
            len = strlen(nodeInt->lable);
            for (int i=5; i <len; i++) 
            	fprintf(output, "%c",nodeInt->lable[i]);

            s->arrSize = (char*)malloc(sizeof(char)*60);
            for (int i = 5; i <=len; i++) 
            	s->arrSize[i - 5] = nodeInt->lable[i];

            fprintf(output, " x i32], align 4\n");
        }
    }
    else
    {
        struct treeNode* nodeVar = t->child[0];
        if (nodeVar->child[1]==NULL)
        {
            fprintf(output, "  %%");
            struct treeNode* nodeId = nodeVar->child[0]->child[0];
			if (PRINT_INFO_LLVM) cout << "CG_DecInner step 3" << endl;
            int len = strlen(nodeId->lable);

            char* tmp = (char*)malloc(sizeof(char)*60);
            for (int i=4;i<=len;i++) 
            	tmp[i-4] = nodeId->lable[i];
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            int i=0;
            while (symTable[dim1][i]) i++;
            symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
            struct symbol* s = symTable[dim1][i];
            s->word = (char*)malloc(sizeof(char)*60);
            strcpy(s->word,tmp);
            s->type = 'l';

            fprintf(output, "%s",tmp);

            char* tmp2 = (char*)malloc(sizeof(char)*60);
            struct treeNode* nodeInit = t->child[2]->child[0]->child[0];
			if (PRINT_INFO_LLVM) cout << "CG_DecInner" << endl;
            len = strlen(nodeInit->lable);
            for (int i=5;i<=len;i++) 
            	tmp2[i-5] = nodeInit->lable[i];

            fprintf(output, " = alloca i32, align 4\n");
            fprintf(output, "  store i32 %s, i32* %%%s, align 4\n",tmp2,tmp);
        } else {
            fprintf(output, "  %%");
            struct treeNode* nodeId = nodeVar->child[0]->child[0]->child[0];
            int len = strlen(nodeId->lable);

            char* tmp = (char*)malloc(sizeof(char)*60);
            for (int i=4;i<=len;i++) tmp[i-4] = nodeId->lable[i];
            int dim1 = tmp[0]-'a';
            if (dim1<0) dim1 = tmp[0]-'A';
            if (tmp[0]=='_') dim1 = 26;
            int i=0;
            while (symTable[dim1][i]) i++;
            symTable[dim1][i] = (struct symbol*)malloc(sizeof(struct symbol));
            struct symbol* s = symTable[dim1][i];
            s->word = (char*)malloc(sizeof(char)*60);
            strcpy(s->word,tmp);
            s->type = 'l';

            fprintf(output, "%s",tmp);
            fprintf(output, " = alloca [");
            struct treeNode* nodeInt = nodeVar->child[2];
            len = strlen(nodeInt->lable);
            for (int i=5;i<len;i++) fprintf(output, "%c",nodeInt->lable[i]);

            s->arrSize = (char*)malloc(sizeof(char)*60);
            for (int i=5;i<=len;i++) s->arrSize[i-5] = nodeInt->lable[i];

            fprintf(output, " x i32], align 4\n");

            arrName = (char*)malloc(sizeof(char)*60);
            arrSize = (char*)malloc(sizeof(char)*60);
            strcpy(arrName,tmp);
            strcpy(arrSize,s->arrSize);

			if (PRINT_INFO_LLVM) cout << "CG_DecInner step 4" << endl;
            CG_ArgsInner(t->child[2]->child[1]);

            free(arrName);
            free(arrSize);
        }
    }
}

// Inner ARGS
void CG_ArgsInner(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_ArgsInner" << endl;
    if (t->child[1]==NULL) //EXP
    {
        char* val = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_ArgsInner step 1" << endl;
        val = CG_Exp(t->child[0]);
        fprintf(output, "  %%arrayidx%d = getelementptr inbounds [%s x i32]* %%%s, i32 0, i32 %s\n",arridxNum,arrSize,arrName,val);
        fprintf(output, "  store i32 %s, i32* %%arrayidx%d, align 4\n",val,arridxNum);
        arridxNum++;
    }
    else //EXP COMMA ARGS
    {
        char* val = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_ArgsInner step 2.0" << endl;
        val = CG_Exp(t->child[0]);
        fprintf(output, "  %%arrayidx%d = getelementptr inbounds [%s x i32]* %%%s, i32 0, i32 %s\n",arridxNum,arrSize,arrName,val);
        fprintf(output, "  store i32 %s, i32* %%arrayidx%d, align 4\n",val,arridxNum);
        arridxNum++;
		if (PRINT_INFO_LLVM) cout << "CG_ArgsInner step 2.1" << endl;
        CG_ArgsInner(t->child[2]);
    }
}

// statements
void CG_Stmts(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Stmts" << endl;
    if (t->child[1]) 									//STMT STMTS
    {
	if (PRINT_INFO_LLVM) cout << "CG_Stmts step 1" << endl;
        CG_Stmt(t->child[0]);
	if (PRINT_INFO_LLVM) cout << "CG_Stmts step 2" << endl;
        CG_Stmts(t->child[1]);
    }
    else {}
}

// statement
void CG_Stmt(struct treeNode* t) 
{
	if (PRINT_INFO_LLVM) cout << "CG_Stmt" << endl;
    if (t->child[1]==NULL) 								//STMTBLOCK
    {
        entryDepth++;
		if (PRINT_INFO_LLVM) cout << "CG_Stmt step 1" << endl;
        CG_Stmtblock(t->child[0]);
        entryDepth--;
    }
    else if (t->child[0]->lable[0]=='E') 				//EXP SEMI
    {
		if (PRINT_INFO_LLVM) cout << "CG_Stmt step 2" << endl;
        CG_Exp(t->child[0]);
    }
    else if (t->child[0]->lable[0]=='I') 				//IF
    {
        if (t->child[5]->child[1]!=NULL) 			
        {
            char* tmp = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Stmt step 3" << endl;
            tmp = CG_Exp(t->child[2]);


            if (!strcmp(t->child[2]->child[1]->lable,"DOT"))
            {
                char num[10];
                sprintf(num, "%d", rNum++);
                char* tmpReg = (char*)malloc(sizeof(char)*60);
                strcpy(tmpReg,"%r");
                strcat(tmpReg,num);

				if (PRINT_INFO_LLVM) cout << "CG_Stmt step 3.1" << endl;
                fprintf(output, "  %s = icmp ne i32 %s, 0\n",tmpReg,tmp);
                strcpy(tmp,tmpReg);
            }


            fprintf(output, "  br i1 %s, label %%if%d.then, label %%if%d.else\n\n",tmp, ifNum, ifNum);

            fprintf(output, "if%d.then:\n",ifNum);
			if (PRINT_INFO_LLVM) cout << "CG_Stmt step 3.2" << endl;
            CG_Stmt(t->child[4]);
            fprintf(output, "  br label %%if%d.end\n\n",ifNum);

            fprintf(output, "if%d.else:\n",ifNum);
			if (PRINT_INFO_LLVM) cout << "CG_Stmt step 3.3" << endl;
            CG_Stmt(t->child[5]->child[1]);
            fprintf(output, "  br label %%if%d.end\n\n",ifNum);

            fprintf(output, "if%d.end:\n",ifNum);

            ifNum++;
        }
        else
        {
            char* tmp = (char*)malloc(sizeof(char)*60);
			if (PRINT_INFO_LLVM) cout << "CG_Stmt step 4.0" << endl;
            tmp = CG_Exp(t->child[2]);


            if (!strcmp(t->child[2]->child[1]->lable,"DOT")) {
                char num[10];
                sprintf(num, "%d", rNum++);
                char* tmpReg = (char*)malloc(sizeof(char)*60);
                strcpy(tmpReg,"%r");
                strcat(tmpReg,num);
				if (PRINT_INFO_LLVM) cout << "CG_Stmt step 4.1" << endl;

                fprintf(output, "  %s = icmp ne i32 %s, 0\n",tmpReg,tmp);
                strcpy(tmp,tmpReg);
            }


            fprintf(output, "  br i1 %s, label %%if%d.then, label %%if%d.end\n\n",tmp, ifNum, ifNum);

            fprintf(output, "if%d.then:\n",ifNum);
			if (PRINT_INFO_LLVM) cout << "CG_Stmt step 4.2" << endl;
            CG_Stmt(t->child[4]);
            fprintf(output, "  br label %%if%d.end\n\n",ifNum);

            fprintf(output, "if%d.end:\n",ifNum);

            ifNum++;
        }
    }
    else if (t->child[0]->lable[0]=='R') 				//RETURN EXP SEMI
    {
        fprintf(output, "  %%r%d = alloca i32, align 4\n",rNum);
        int oldrNum = rNum;
        rNum++;
		if (PRINT_INFO_LLVM) cout << "CG_Stmt step 5.0" << endl;

		if (PRINT_INFO_LLVM) cout << "return finished" << endl;

        char* tmp = (char*)malloc(sizeof(char)*60);
			if (PRINT_INFO_LLVM) cout << "CG_Stmt step 5.1" << endl;
        tmp = CG_Exp(t->child[1]);

		if (PRINT_INFO_LLVM) cout << "0 finished" << endl;

        fprintf(output, "  store i32 %s, i32* %%r%d\n",tmp,oldrNum);
        fprintf(output, "  %%r%d = load i32* %%r%d\n",rNum,oldrNum);
        fprintf(output, "  ret i32 %%r%d\n",rNum);
        rNum++;
    }
    else if (t->child[0]->lable[0]=='F') 				//FOR
    {
		if (PRINT_INFO_LLVM) cout << "CG_Stmt step 6.0" << endl;
        CG_Exp(t->child[2]);
        fprintf(output, "  br label %%for%d.cond\n\n",forNum);

        fprintf(output, "for%d.cond:\n",forNum);
        char* tmp = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Stmt step 6.1" << endl;
        tmp = CG_Exp(t->child[4]);

        if (t->child[4]->child[0]->lable[0]=='T' && t->child[4]->child[1]->lable[0]=='A') //special case, ID ARRS
        {
            fprintf(output, "  %%r%d = icmp sgt i32 %s, 0",rNum,tmp);
            fprintf(output, "  br i1 %%r%d, label %%for%d.body, label %%for%d.end\n\n",rNum,forNum,forNum);
            rNum++;
        }
        else fprintf(output, "  br i1 %s, label %%for%d.body, label %%for%d.end\n\n",tmp,forNum,forNum);

        fprintf(output, "for%d.body:\n",forNum);
		if (PRINT_INFO_LLVM) cout << "CG_Stmt step 6.1" << endl;
        CG_Stmt(t->child[8]);
        fprintf(output, "  br label %%for%d.inc\n\n",forNum);

        fprintf(output, "for%d.inc:\n",forNum);
		if (PRINT_INFO_LLVM) cout << "CG_Stmt step 6.2" << endl;
        CG_Exp(t->child[6]);
        fprintf(output, "  br label %%for%d.cond\n\n",forNum);

        fprintf(output, "for%d.end:\n",forNum);

        forNum++;
    }
}

char* CG_Exp(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_Exp" << endl;
	// if (PRINT_INFO_LLVM) cout << t->child[0]->lable[0] << t->child[0]->lable[1] << t->child[0]->lable[2] << endl;
    if (t->child[1]==NULL && t->child[0]->lable[0]=='I') {			//EXP->INT
		if (PRINT_INFO_LLVM) cout << "EXP->INT" << endl;
        char* tmp = (char*)malloc(sizeof(char)*60);
        struct treeNode* nodeInt = t->child[0];
        int len = strlen(nodeInt->lable);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 1" << endl;
        for (int i = 5; i <= len; i ++) 
        	tmp[i - 5] = nodeInt->lable[i];
        return tmp;
    } else if (t->child[1]==NULL && t->child[0]->lable[0]=='N') {	//EXP->NEGINT
        char* tmp = (char*)malloc(sizeof(char)*60);
        struct treeNode* nodeInt = t->child[0];
        int len = strlen(nodeInt->lable);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 2" << endl;
        for (int i = 8; i <= len; i ++) 
        	tmp[i - 8] = nodeInt->lable[i];
        return tmp;
    } else if (!strcmp(t->child[0]->lable,"WR")) { 					//EXP->WR
        struct treeNode* nodeWr = t->child[0];
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 3" << endl;
        if (nodeWr->child[0]->lable[0]=='W') {						//WRITE
            char* tmp = (char*)malloc(sizeof(char)*60);
			if (PRINT_INFO_LLVM) cout << "CG_Exp step 3.0" << endl;
            tmp = CG_Exp(nodeWr->child[2]);

            int trans;
            if (strlen(tmp)>1 && (tmp[0]=='0' || (tmp[0]=='-' && tmp[1]=='0'))) {
                trans = strtol(tmp,NULL,0);
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 3.1" << endl;
                fprintf(output, "  %%call%d = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([3 x i8]* @.str, i32 0, i32 0), i32 %d)\n",callNum,trans);
                callNum++;
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 3.2" << endl;
                fprintf(output, "  %%call%d = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([2 x i8]* @.str1, i32 0, i32 0))\n",callNum);
                callNum++;
            } else {
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 3.3" << endl;
                fprintf(output, "  %%call%d = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([3 x i8]* @.str, i32 0, i32 0), i32 %s)\n",callNum,tmp);
                callNum++;
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 3.4" << endl;
                fprintf(output, "  %%call%d = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([2 x i8]* @.str1, i32 0, i32 0))\n",callNum);
                callNum++;
            }
        }
        else {														//READ
            char* tmp = (char*)malloc(sizeof(char)*200);
            loadFlag = 0;
			if (PRINT_INFO_LLVM) cout << "CG_Exp step 3.5" << endl;
            tmp = CG_Exp(nodeWr->child[2]);
            loadFlag = 1;

            fprintf(output, "  %%call%d = call i32 (i8*, ...)* @__isoc99_scanf(i8* getelementptr inbounds ([3 x i8]* @.str, i32 0, i32 0), i32* %s)\n",callNum,tmp);
            callNum ++;
        }
        return NULL;
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 3.10" << endl;
    }
    else if (t->child[0]->lable[0]=='T' && t->child[1]->lable[0]=='A') { //EXP->THEID ARRS

		if (PRINT_INFO_LLVM) cout << "CG_Exp step 4" << endl;
        struct treeNode* nodeArrs = t->child[1];
        if (nodeArrs->child[0]->lable[0]=='N') 	{						//ARRS->NULL, ID case
            char* tmp = (char*)malloc(sizeof(char)*60);
			if (PRINT_INFO_LLVM) cout << "CG_Exp step 4.0" << endl;
            struct treeNode* nodeId = t->child[0]->child[0];
            int len = strlen(nodeId->lable);
            for (int i = 4; i <=len; i ++) 
            	tmp[i - 4] = nodeId->lable[i];

            int index = tmp[0]-'a';
            if (index<0) index = tmp[0]-'A';
            if (tmp[0]=='_') index = 26;

            int i=0;
            while (strcmp(tmp,symTable[index][i]->word)) i++;
			if (PRINT_INFO_LLVM) cout << "CG_Exp step 4.1" << endl;

            struct symbol* id = symTable[index][i];
            switch (id->type)
            {
                case 'g':
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 4.2" << endl;
                for (int i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];
                tmp[0] = '@';
                break;

                case 'l':
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 4.3" << endl;
                for (int i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];
                tmp[0] = '%';
                break;

                case 'a':
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 4.4" << endl;
                for (int i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];
                tmp[0] = '%';
                strcat(tmp,".addr");
                break;
            }

            if (loadFlag)
            {
                char num[10];
                sprintf(num, "%d", rNum++);
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 4.5" << endl;
                char* tmpReg = (char*)malloc(sizeof(char)*60);
                strcpy(tmpReg,"%r");
                strcat(tmpReg,num);

                fprintf(output, "  %s = load i32* %s, align 4\n",tmpReg,tmp);
                return tmpReg;
            }
            else return tmp;
        } else {
			if (PRINT_INFO_LLVM) cout << "CG_Exp step 5" << endl;
            char* tmp = (char*)malloc(sizeof(char)*60);
            struct treeNode* nodeId = t->child[0]->child[0];
			if (PRINT_INFO_LLVM) cout << "CG_Exp step 5.0" << endl;
            int len = strlen(nodeId->lable);
            for (int i = 4; i <= len; i ++) 
            	tmp[i - 4] = nodeId->lable[i];

            char* arrsIndex = (char*)malloc(sizeof(char)*60);
            if (loadFlag==0)
            {
                loadFlag = 1;
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 5.1" << endl;
                arrsIndex = CG_Exp(t->child[1]->child[1]); //what we obtained could be register or INT
                loadFlag = 0;
            }
            else arrsIndex = CG_Exp(t->child[1]->child[1]);

            char* ret = (char*)malloc(sizeof(char)*60);
            strcpy(ret,"%arrayidx");

            char num[10];
            sprintf(num, "%d", arridxNum++);
            strcat(ret,num);
			if (PRINT_INFO_LLVM) cout << "CG_Exp step 5.2" << endl;

            int index = tmp[0]-'a';
            if (index<0) index = tmp[0]-'A';
            if (tmp[0]=='_') index = 26;

            int i = 0;
            while (strcmp(tmp,symTable[index][i]->word)) i++;

            struct symbol* id = symTable[index][i];
            switch (id->type)
            {
                case 'g':
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 5.3" << endl;
                for (int i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];
                tmp[0] = '@';
                break;

                case 'l':
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 5.4" << endl;
                for (int i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];
                tmp[0] = '%';
                break;

                case 'a':
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 5.5" << endl;
                for (int i=strlen(tmp);i>=0;i--) tmp[i+1] = tmp[i];
                tmp[0] = '%';
                strcat(tmp,".addr");
                break;
            }

            //%arrayidx4 = getelementptr inbounds [2 x i32]* %d, i32 0, i32 1
            fprintf(output, "  %s = getelementptr inbounds [%s x i32]* %s, i32 0, i32 %s\n",ret,id->arrSize,tmp,arrsIndex);

            if (loadFlag)
            {
                char num[10];
                sprintf(num, "%d", rNum++);
                char* tmpReg = (char*)malloc(sizeof(char)*60);
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 5.6" << endl;
                strcpy(tmpReg,"%r");
                strcat(tmpReg,num);
				if (PRINT_INFO_LLVM) cout << "CG_Exp step 5.7" << endl;

                fprintf(output, "  %s = load i32* %s, align 4\n",tmpReg,ret);
                return tmpReg;
            }
            else return ret;
        }
    }
    else if (!strcmp(t->child[0]->lable,"PREINC")) { 					//++
        char* op = (char*)malloc(sizeof(char)*60);
        loadFlag = 0;
        op = CG_Exp(t->child[1]);
        loadFlag = 1;

        fprintf(output, "  %%r%d = load i32* %s, align 4\n",rNum,op);
        fprintf(output, "  %%r%d = add nsw i32 %%r%d, 1\n",rNum+1,rNum);
        fprintf(output, "  store i32 %%r%d, i32* %s, align 4\n",rNum+1,op);

        rNum+=2;
        return NULL;
    }

    else if (!strcmp(t->child[0]->lable,"LOGICALNOT")) 	{					//!
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 6" << endl;
        char* op = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 6.0" << endl;
        op = CG_Exp(t->child[1]);

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 6.1" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        fprintf(output, "  %s = icmp eq i32 %s, 0\n",tmpReg,op);
        return tmpReg;
    }
    else if (t->child[1]->lable[0]=='N' && t->child[1]->lable[1]=='E' && t->child[1]->lable[2]=='G') { //EXP -> EXP NEGINT
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 7" << endl;
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 7.0" << endl;
        op1 = CG_Exp(t->child[0]);

        char* op2 = (char*)malloc(sizeof(char)*60);
        struct treeNode* nodeInt = t->child[1];
        int len = strlen(nodeInt->lable);
        for (int i=9;i<=len;i++) op2[i-9] = nodeInt->lable[i];

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        fprintf(output, "  %s = sub nsw i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    } else if (!strcmp(t->child[1]->lable,"ASSIGN")) {						//EXP->EXP ASSIGN EXP
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 8" << endl;
        char* op2 = (char*)malloc(sizeof(char)*200);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 8.0" << endl;
        op2 = CG_Exp(t->child[2]);

        loadFlag = 0;
        char* op1 = (char*)malloc(sizeof(char)*200);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 8.1" << endl;
        op1 = CG_Exp(t->child[0]);
        loadFlag = 1;

        fprintf(output, "  store i32 %s, i32* %s, align 4\n",op2,op1);
        return NULL;
    } else if (!strcmp(t->child[0]->lable,"LP")) { 							//LP EXP RP
        return CG_Exp(t->child[1]);
    } else if (!strcmp(t->child[1]->lable,"DOT")) {							//EXP->EXP DOT THEID
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 9 -" << endl;
    	struct treeNode* nodeId = t->child[0]->child[0]->child[0];
        char* tmp = (char*)malloc(sizeof(char)*200);
        int len = strlen(nodeId->lable);
        for (int i = 4; i <= len; i ++) tmp[i - 4] = nodeId->lable[i];

		if (PRINT_INFO_LLVM) cout << "CG_Exp step 9" << endl;
        int index = tmp[0]-'a';
        if (index<0) index = tmp[0]-'A';
        if (tmp[0]=='_') index = 26;

        int i = 0;
        while (strcmp(tmp,symTable[index][i]->word)) i++;
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 9.0" << endl;

        struct symbol* id = symTable[index][i];

        char* op1 = (char*)malloc(sizeof(char)*200);
        strcpy(op1,tmp);

        char* opStr = (char*)malloc(sizeof(char)*200);
        strcpy(opStr,id->structName); //opStr, doubleO

        free(tmp);

		if (PRINT_INFO_LLVM) cout << "CG_Exp step 9.1" << endl;
        nodeId = t->child[2]->child[0];
        tmp = (char*)malloc(sizeof(char)*200);
        len = strlen(nodeId->lable);
        for (int i = 4; i <= len; i ++) tmp[i - 4] = nodeId->lable[i];

        index = tmp[0]-'a';
        if (index<0) index = tmp[0]-'A';
        if (tmp[0]=='_') index = 26;

        i = 0;
        while (strcmp(tmp,symTable[index][i]->word)) i++;

        id = symTable[index][i];

        int op2 = id->structMem; //op2, 0

		if (PRINT_INFO_LLVM) cout << "CG_Exp step 9.2" << endl;
        char* ret = (char*)malloc(sizeof(char)*200);
        strcpy(ret,"getelementptr inbounds (%struct.");
        strcat(ret,opStr);
        strcat(ret,"* @");
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 9.2.1" << endl;
        strcat(ret,op1);
        strcat(ret,", i32 0, i32 ");
        char indTmp = '0'+op2;
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 9.2.2" << endl;
        char* ind = (char*)malloc(sizeof(char)*50); ind[0] = indTmp; ind[1] = '\0';
        strcat(ret,ind);
        strcat(ret,")");

        if (loadFlag)
        {
            char num[10];
            sprintf(num, "%d", rNum++);
            char* tmpReg = (char*)malloc(sizeof(char)*200);
			if (PRINT_INFO_LLVM) cout << "CG_Exp step 9.3" << endl;
            strcpy(tmpReg,"%r");
            strcat(tmpReg,num);

            fprintf(output, "  %s = load i32* %s, align 4\n",tmpReg,ret);
            return tmpReg;
        }
        else return ret;
    }
    else if (!strcmp(t->child[1]->lable,"ET")) 					//EXP->EXP ET EXP
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 9.0" << endl;
        op1 = CG_Exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 9.1" << endl;
        op2 = CG_Exp(t->child[2]);

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 9.2" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        fprintf(output, "  %s = icmp eq i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->lable,"GT")) 					//EXP->EXP GT EXP
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 10.0" << endl;
        op1 = CG_Exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 10.1" << endl;
        op2 = CG_Exp(t->child[2]);

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 10.2" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 10.3" << endl;

        fprintf(output, "  %s = icmp sgt i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->lable,"LT")) 					//EXP->EXP LT EXP
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 11.0" << endl;
        op1 = CG_Exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 11.1" << endl;
        op2 = CG_Exp(t->child[2]);

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 11.2" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 11.3" << endl;

        fprintf(output, "  %s = icmp slt i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->lable,"LOGICALAND")) 				//EXP->EXP LOGICALAND EXP
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 12.0" << endl;
        op1 = CG_Exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 12.1" << endl;
        op2 = CG_Exp(t->child[2]);

        int reg1 = rNum, reg2 = rNum+1; rNum+=2;
        fprintf(output, "  %%r%d = icmp ne i1 %s, 0\n",reg1,op1);
        fprintf(output, "  %%r%d = icmp ne i1 %s, 0\n",reg2,op2);

        int reg3 = rNum; rNum++;
        fprintf(output, "  %%r%d = and i1 %%r%d, %%r%d\n",reg3,reg1,reg2);

        char num[10];
        sprintf(num, "%d", reg3);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 12.3" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        return tmpReg;
    }
    else if (!strcmp(t->child[1]->lable,"PLUS")) 				//EXP PLUS EXP
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 13.0" << endl;
        op1 = CG_Exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 13.1" << endl;
        op2 = CG_Exp(t->child[2]);

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 13.2" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        fprintf(output, "  %s = add nsw i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->lable,"MINUS")) 				//EXP MINUS EXP
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 14.0" << endl;
        op1 = CG_Exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 14.1" << endl;
        op2 = CG_Exp(t->child[2]);

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 14.2" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        fprintf(output, "  %s = sub nsw i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->lable,"MUL")) //EXP MUL EXP
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 15.0" << endl;
        op1 = CG_Exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 15.1" << endl;
        op2 = CG_Exp(t->child[2]);

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 15.2" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        fprintf(output, "  %s = mul nsw i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->lable,"MOD"))						//MOD srem
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 16.0" << endl;
        op1 = CG_Exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 16.1" << endl;
        op2 = CG_Exp(t->child[2]);

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 16.2" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        fprintf(output, "  %s = srem i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->lable,"BITAND"))					//BITAND
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 17.0" << endl;
        op1 = CG_Exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 17.1" << endl;
        op2 = CG_Exp(t->child[2]);

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 17.2" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        fprintf(output, "  %s = and i32 %s, %s\n",tmpReg,op1,op2);
        sprintf(num, "%d", rNum++);
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        fprintf(output, "  %s = icmp ne i32 %%r%d, 0\n",tmpReg,rNum-2);
        return  tmpReg;
    }
    else if (!strcmp(t->child[1]->lable,"BITXOR"))					//BITXOR
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 18.0" << endl;
        op1 = CG_Exp(t->child[0]);
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 18.1" << endl;
        op2 = CG_Exp(t->child[2]);

        char num[10];
        sprintf(num, "%d", rNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 18.2" << endl;
        strcpy(tmpReg,"%r");
        strcat(tmpReg,num);

        fprintf(output, "  %s = xor i32 %s, %s\n",tmpReg,op1,op2);
        return tmpReg;
    }
    else if (!strcmp(t->child[1]->lable,"SHRASSIGN")) 				//EXP SHRASSIGN EXP
    {
        char* op1 = (char*)malloc(sizeof(char)*60);
        loadFlag = 0;
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 19.0" << endl;
        op1 = CG_Exp(t->child[0]);
        loadFlag = 1;
        char* op2 = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 19.1" << endl;
        op2 = CG_Exp(t->child[2]);

        fprintf(output, "%%r%d = load i32* %s, align 4\n",rNum,op1);
        fprintf(output, "  %%r%d = ashr i32 %%r%d, %s\n",rNum+1,rNum,op2);
        fprintf(output, "  store i32 %%r%d, i32* %s, align 4\n",rNum+1,op1);
        rNum+=2;
        return NULL;
    }
    else if (!strcmp(t->child[2]->lable,"ARGS")) 				//ID LP ARGS RP
    {
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 20.1" << endl;
        CG_ArgsFunc(t->child[2]);

        char num[10];
        sprintf(num, "%d", callNum++);
        char* tmpReg = (char*)malloc(sizeof(char)*60);
        strcpy(tmpReg,"%call");
        strcat(tmpReg,num);

        char* funcName = (char*)malloc(sizeof(char)*60);
        struct treeNode* nodeId = t->child[0]->child[0];
		if (PRINT_INFO_LLVM) cout << "CG_Exp step 20.1" << endl;
        int len = strlen(nodeId->lable);
        for (int i=4;i<=len;i++) 
        	funcName[i-4] = nodeId->lable[i];

        fprintf(output, "  %s = call i32 @%s(",tmpReg,funcName);
        int i;
        for (i=0;i<paraPoint-1;i++)
        {
            fprintf(output, "i32 %s, ",paraArr[i]);
            free(paraArr[i]);
        }
        if (paraPoint>0)
        {
            fprintf(output, "i32 %s",paraArr[paraPoint-1]);
            free(paraArr[i]);
            paraPoint = 0;
        }
        fprintf(output, ")\n");

        return tmpReg;
    }
    else return NULL;
}

// Function Call ARGS
void CG_ArgsFunc(struct treeNode* t)
{
	if (PRINT_INFO_LLVM) cout << "CG_ArgsFunc" << endl;
    if (t->child[1]==NULL) 			//EXP
    {
        char* tmp = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_ArgsFunc step 1.1" << endl;
        tmp = CG_Exp(t->child[0]);
        paraArr[paraPoint] = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_ArgsFunc step 1.2" << endl;
        strcpy(paraArr[paraPoint],tmp);
        paraPoint++;
    }  else {							//EXP COMMA ARGS
        char* tmp = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_ArgsFunc step 2.1" << endl;
        tmp = CG_Exp(t->child[0]);
        paraArr[paraPoint] = (char*)malloc(sizeof(char)*60);
		if (PRINT_INFO_LLVM) cout << "CG_ArgsFunc step 2.2" << endl;
        strcpy(paraArr[paraPoint],tmp);
        paraPoint++;
		if (PRINT_INFO_LLVM) cout << "CG_ArgsFunc step 2.3" << endl;
        CG_ArgsFunc(t->child[2]);
    }
}