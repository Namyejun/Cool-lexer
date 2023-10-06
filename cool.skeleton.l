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
%}

NEWLINE     (\r\n|\n)
WHITESPACE  [ \t]+

%%
                
{WHITESPACE}    /* SKIP */
{NEWLINE}       { lineNo++; }

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
