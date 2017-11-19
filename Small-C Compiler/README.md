
# SMALL-C COMPILER

![](https://img.shields.io/badge/Yacc-1.0.0-green.svg) ![](https://img.shields.io/badge/Lex-1.0.0-green.svg) ![](https://img.shields.io/badge/Platform-Linux-lightgray.svg) 

## Project Introduction
**Small-C Compiler** is a compiler for **Small-C** language. **Small-C** is a simplified **C** language with the main syntax remained. This mini compiler could analyze the syntax of input code and build a parsing tree, then generate code in **LLVM** language accoring to the structure of this paring tree.

This project includes 3 parts:

1. Lexical Analyzer
2. Syntax Analyzer
3. Target **LLVM** code generation

(
An e-book *Lex and Yacc: from Baics to Advance* could help you better understand **Lex** and **Yacc**.)


## Environment Setting

This whole project is based on Ubuntu 14.04.

**Windows** environment is not recommended here because the instructions are very poorly supported by **Flex** and **Bison** in **Windows**.


Use these commands to install **Lex** and **Yacc**:

    $ sudo apt-get install flex
    $ sudo apt-get install bison

When come to the **LLVM** part, it seems not that easy. The building process of **LLVM** requires nearly 20GB disk space, wchich could be a disaster to some equipments especially virtual machines.  

However, you could switch to this approach:

    $ sudo apt-get install llvm
    $ sudo add-apt-repository 'deb http://llvm.org/apt/precise/ llvm-toolchain-precise main'
    $ wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|sudo apt-key add -
    $ sudo apt-get update
    $ sudo apt-get install clang-3.4 clang-3.4-doc libclang-common-3.4-dev libclang-3.4-dev libclang1-3.4 
    libclang1-3.4-dbg libllvm-3.4-ocaml-dev libllvm3.4 libllvm3.4-dbg lldb-3.4 llvm-3.4 llvm-3.4-dev llvm-3.4-doc 
    llvm-3.4-examples llvm-3.4-runtime cpp11-migrate-3.4 clang-format-3.4

Though this project couldbe  executed without **clang**, reading **LLVM IR** generated could help a lot in understanding how the language works.


## Lexical Analyzer
A lexical analyser has been implemented in this part. It reads the source codes of **SMALLC** and separates them into tokens. The work is done using **Lex** and the related file is `smallc.l`

### DEC HEX & OCT Numbers

In this part, `#include<stdlib.h>` can be checked out for some hint. 

Also, **NEGINT** which stands for negative integer should not be forgotten.

    0x0|0X0|00|0 					{ strcpy(nodeLable, "INT: "); 	strcat(nodeLable, yytext);  	return INT;}
    [1-9][0-9]* 					{ strcpy(nodeLable, "INT: "); 	strcat(nodeLable, yytext);  	return INT;}
    -[1-9][0-9]* 					{ strcpy(nodeLable, "NEGINT: ");strcat(nodeLable, yytext);  	return NEGINT;}
    0[1-7][0-7]*    				{ strcpy(nodeLable, "INT: "); 	strcat(nodeLable, yytext); 		return INT;}
    -0[1-7][0-7]*   				{ strcpy(nodeLable, "NEGINT: ");strcat(nodeLable, yytext);  	return NEGINT;}
    0[Xx][1-9a-fA-F][0-9a-fA-F]* 				{ strcpy(nodeLable, "INT: "); 	strcat(nodeLable, yytext);  	return INT;}
    -0[Xx][1-9a-fA-F][0-9a-fA-F]* 				{ strcpy(nodeLable, "NEGINT: ");strcat(nodeLable, yytext);  	return NEGINT;}

### Comments
There are two kinds of comments in **SMALLC** language.
One is the two slash, which is implemented by:

    "//"(.)*  	{ /* comment */ }
The other one is the `/*` and `*/` pairs:

    "/*"      	BEGIN(comment);
    <comment>{
    [^*\n]*
    "*"+[^*/\n]*
    [\n]             
    "*"+"/"     BEGIN(INITIAL);
    }


## Syntax Analyzer
In this step, syntax analysis is performed by  **Yacc** and the file here is `smallc.y`.

### EXP
In this part, all possible operands are  listed out  to reduce the burden in code generation. For example:

    | EXP PLUS EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"PLUS"); 	noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
    | EXP MUL EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"MUL"); 	noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
    | EXP SHL EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"SHL"); 	noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
    | EXP LT EXP	{ root=noTermBuild("EXP"); noTermInsert(root,stack[top-1]); termInsert(root,"LT"); 	noTermInsert(root,stack[top]); top = top - 1; stack[top]=root;}
    ...

### Read and Write
`WR` is used to hold `read()` and `write()`.

    : WRITE LP EXP RP 	{root=noTermBuild("WR"); termInsert(root,"WRITE"); 	termInsert(root,"LP"); noTermInsert(root,stack[top]);  termInsert(root,"RP"); stack[top]=root;}
	| READ LP EXP RP 	{root=noTermBuild("WR"); termInsert(root,"READ"); 	termInsert(root,"LP"); noTermInsert(root,stack[top]);  termInsert(root,"RP"); stack[top]=root;}
	;

`WR`is in the syntax of `EXP`.

    | WR		{root = noTermBuild("EXP"); noTermInsert(root, stack[top]); stack[top]=root;}

### Parsing Tree
In this part, in order to print a parsing tree, a tree data-structure is built up.
Such information are recorded for each treeNode:

    struct treeNode
    {
    	char* lable;
		struct treeNode* child[10];
		int code;
    };
These functions below are implemented for building tree and printing out  results:

    struct treeNode* noTermBuild(char* st); 						// build non-terminal in the tree
	struct treeNode* termBuild(char* pST,char* sST);					// build terminal in the tree
	void noTermInsert(struct treeNode* root, struct treeNode* point);					// insert non-terminal in the tree
	void termInsert(struct treeNode* root, char* st);					// build terminal in the tree
	void printTree(struct treeNode* root, int depth);					// print out the parsing tree


## Target LLVM code generation
In this part, quite a lot of functions are used. `CG` stands for `Code Generation`. The function of these code could be understood easily.

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

Also, a struct is written here to record information:

    struct symbol
	{
    	char* word;
    	char type;
    	char* arrSize;
    	char* structName;
    	int structMem;
	};
	struct symbol* symTable[27][20];
