/*
 * GreenScript - programa principal do analisador lexical.
 * Uso: ./greenscript <ficheiro.gs>
 */
#include <stdio.h>
#include "greenscript.h"

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <ficheiro.gs>\n", argv[0]);
        return 2;
    }

    if (analisa_ficheiro(argv[1]) != 0)
        return 1;

    printf("Tokens: %d | Erros lexicais: %d\n", total_tokens, total_erros);
    return 0;
}
