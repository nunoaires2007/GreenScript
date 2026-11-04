/*
 * GreenScript - especificacao FLEX do analisador lexical (TP1).
 *
 * Cada token e escrito numa linha: <linha> <CATEGORIA> <lexema>
 * Cada erro e escrito como:      Erro lexical na linha <n>: <motivo> '<lexema>'
 */

%option noyywrap nounput noinput
%option yylineno
%option 8bit

%{
#include <stdio.h>
#include "greenscript.h"

int total_tokens = 0;
int total_erros  = 0;

/* Escreve um token reconhecido. */
static void token(const char *categoria)
{
    printf("%d %-11s %s\n", yylineno, categoria, yytext);
    total_tokens++;
}

/* Escreve um diagnostico e continua a analise. */
static void erro(const char *motivo)
{
    printf("Erro lexical na linha %d: %s '%s'\n", yylineno, motivo, yytext);
    total_erros++;
}
%}

DIGITO      [0-9]
MAIUSCULA   [A-Z]
ID_ESTUFA   "EST-"{MAIUSCULA}{2}{DIGITO}{2}
INTEIRO     "0"|[1-9]{DIGITO}*
CANDIDATO   [A-Za-z0-9_-]+
UTF8        [\xC2-\xF4][\x80-\xBF]{1,3}

%%

 /* Separadores e comentarios: ignorados */
[ \t\r\n]+          { /* CRLF: o \r e ignorado, so o \n conta a linha */ }
"#".*               { /* comentario ate ao fim da linha ou do ficheiro */ }

 /* Palavras reservadas */
"LIGAR"             { token("LIGAR"); }
"DESLIGAR"          { token("DESLIGAR"); }
"ABRIR"             { token("ABRIR"); }
"FECHAR"            { token("FECHAR"); }
"AQUECER"           { token("AQUECER"); }
"PARAR"             { token("PARAR"); }
"REGAR"             { token("REGAR"); }
"ESPERAR"           { token("ESPERAR"); }
"SE"                { token("SE"); }
"SENAO"             { token("SENAO"); }
"HUMIDADE"          { token("HUMIDADE"); }
"REPETIR"           { token("REPETIR"); }

{ID_ESTUFA}         { token("ID_ESTUFA"); }
{INTEIRO}           { token("INTEIRO"); }

 /*
  * Qualquer sequencia maxima de letras, algarismos, '-' ou '_' que nao
  * corresponda integralmente a uma das regras anteriores. Pelo
  * reconhecimento mais longo, LIGARX, 012 ou EST-AA001 sao apanhados aqui
  * por inteiro (um unico erro, sem tokens parciais).
  */
{CANDIDATO}         { erro("sequencia invalida"); }

 /* Operadores relacionais (os de dois caracteres tem prioridade) */
"<="                { token("MENOR_IGUAL"); }
">="                { token("MAIOR_IGUAL"); }
"=="                { token("IGUAL"); }
"!="                { token("DIFERENTE"); }
"<"                 { token("MENOR"); }
">"                 { token("MAIOR"); }

 /* Delimitadores */
"("                 { token("ABRE_PAR"); }
")"                 { token("FECHA_PAR"); }
"{"                 { token("ABRE_CHAV"); }
"}"                 { token("FECHA_CHAV"); }
","                 { token("VIRGULA"); }
";"                 { token("PONTO_VIRG"); }

 /* Caracter nao reconhecido (inclui = e ! isolados, + e *) */
{UTF8}              { erro("caracter nao reconhecido"); }
.                   { erro("caracter nao reconhecido"); }

%%

int analisa_ficheiro(const char *caminho)
{
    FILE *f = fopen(caminho, "rb");
    if (f == NULL) {
        fprintf(stderr, "Erro: nao foi possivel abrir '%s'\n", caminho);
        return -1;
    }

    yyin = f;
    yylineno = 1;
    total_tokens = 0;
    total_erros = 0;

    yylex();

    fclose(f);
    return 0;
}
