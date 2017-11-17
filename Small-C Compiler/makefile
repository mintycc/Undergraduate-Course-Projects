LEX=flex
YACC=bison
CC=g++
OBJECT=scc
$(OBJECT): lex.yy.o  smallc.tab.o
	$(CC) lex.yy.o	smallc.tab.o	-o	$(OBJECT)
lex.yy.o:	lex.yy.c	smallc.tab.h
	$(CC)	-c	lex.yy.c
smallc.tab.o:	smallc.tab.c
	$(CC)	-c	smallc.tab.c
smallc.tab.c	smallc.tab.h:	smallc.y
	$(YACC)	-d	smallc.y
lex.yy.c:	smallc.l
	$(LEX) smallc.l
clean:
	@rm	-f	$(OBJECT)	*.o *.yy.c *.yy.o *.tab.*
