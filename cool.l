/*
 * Copyright 2020-2022. Heekuck Oh, all rights reserved
 * 이 프로그램은 한양대학교 ERICA 소프트웨어학부 재학생을 위한 교육용으로 제작되었다.
 */
%option noinput nounput
%{
#include <stdio.h>
#include <stdlib.h>
#include "cool.tab.h"

int lineNo = 1;
int comment_depth = 0;
int should_terminate = 0;
int in_nested_comment = 0;

%}

NEWLINE     (\r\n|\n)
WHITESPACE  (" "|\f|\r|\t|\v)
LOWER	[a-z_]
LETTER [a-zA-Z_]
UPPER	[A-Z]
DIGIT	[0-9]

%x NESTED_COMMENT
NESTED_COMMENT_START	"\(\*"
NESTED_COMMENT_END	"\*\)"

%x SIMPLE_COMMENT
SIMPLE_COMMENT_START	"--"
SIMPLE_COMMENT_END	"--"

%%  
(?i:class)	{ return CLASS; }
(?i:inherits)	{ return INHERITS; }
(?i:if)	{ return IF; }
(?i:then)	{ return THEN; }
(?i:ELSE)	{ return ELSE; }
(?i:fi)	{ return FI; }
(?i:while) 	{ return WHILE; }
(?i:loop)	{ return LOOP; }
(?i:pool)	{ return POOL; }
(?i:let)	{ return LET; }
(?i:in)	{ return IN; }
(?i:case)	{ return CASE; }
(?i:of)	{ return OF; }
(?i:esac)	{ return ESAC; }
(?i:new)	{ return NEW; }
(?i:isvoid)	{ return ISVOID; }
(?i:not)	{ return NOT; }
(?i:true)	{ return TRUE; }
(?i:false)	{ return FALSE; }

{NESTED_COMMENT_START}	{ comment_depth++; BEGIN(NESTED_COMMENT); in_nested_comment = 1; }
<NESTED_COMMENT>{NESTED_COMMENT_START} { comment_depth++; }
<NESTED_COMMENT>{NESTED_COMMENT_END}\n {
	comment_depth--;
	lineNo++;
	if (comment_depth < 0) {
		fprintf(stderr, "Unmatched *) in line number %d\n", lineNo);
		exit(1);
	}
	if (comment_depth == 0) {
		in_nested_comment = 0;
		BEGIN(INITIAL);	
	}
}
<NESTED_COMMENT>{NESTED_COMMENT_END} {
	comment_depth--;
	if (comment_depth < 0) {
		fprintf(stderr, "Unmatched *) in line number %d\n", lineNo);
		exit(1);
	}
	if (comment_depth == 0) {
		in_nested_comment = 0;
		BEGIN(INITIAL);	
	}
}
<NESTED_COMMENT>\n	{ lineNo++; }
<NESTED_COMMENT>.	{}
{NESTED_COMMENT_END} {
	if (!in_nested_comment) {
		fprintf(stderr, "Unmatched *) in line number %d\n", lineNo);
		exit(1);
	}
}

{SIMPLE_COMMENT_START}	{ BEGIN(SIMPLE_COMMENT); }
<SIMPLE_COMMENT>\n	{ lineNo++; BEGIN(INITIAL); }
<SIMPLE_COMMENT>.	{}

"\"\""	{ return STRING; }
"\""("\\\\"|"\\n"|"\\t"|"\\b"|"\\f"|"\\\""|[^\"\\])*"\""	{ return STRING; }
{NEWLINE}	{ lineNo++; }
{WHITESPACE}+    {}
({UPPER}|{UPPER}({LETTER}|{DIGIT})*)	{ return TYPE; }
{LOWER}({DIGIT}|{LETTER})*	{ return ID; }
{DIGIT}+	{ return INTEGER; }

"("     { return LPAREN; }
")"     { return RPAREN; }
"{"     { return LBRACE; }
"}"     { return RBRACE; }
"<="    { return LTE; }
"<-"    { return ASSIGN; }
"<"     { return LT; }
"=>"    { return DARROW; }
"="     { return EQUAL; }
","     { return COMMA; }
";"     { return SEMICOLON; }
":"     { return COLON; }
"."     { return DOT; }
"+"     { return PLUS; }
"-"     { return MINUS; }
"*"     { return MUL; }
"/"     { return DIV; }
"~"     { return NEG; }
"@"     { return ATSIGN; }

.       { fprintf(stderr, "Invalid character %s in line %d\n", yytext, lineNo);
          exit(1);
        }

%%

int main(int argc, char *argv[])
{
    int token;

    /*
     * 스캔할 COOL 파일을 연다. 파일명이 없으면 표준입력이 사용된다.
     */
    if (argc > 1)
        if (!(yyin = fopen(argv[1],"r"))) {
            printf("\"%s\"는 잘못된 파일 경로입니다.\n", argv[1]);
            exit(1);
        }
    /* 
     * 토큰을 식별할 때마다 줄번호, 타입, 문자열(lexeme)을 출력한다
     */
    for (token = yylex(); token != YY_NULL; token = yylex())
        printf("%03d:[%s] %s\n", lineNo, tokenName[token-100], yytext);
}