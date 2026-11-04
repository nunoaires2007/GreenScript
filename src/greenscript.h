#ifndef GREENSCRIPT_H
#define GREENSCRIPT_H

/* Contadores globais definidos em scanner.l */
extern int total_tokens;
extern int total_erros;

/* Analisa o ficheiro indicado; devolve 0 em sucesso, -1 se não abrir. */
int analisa_ficheiro(const char *caminho);

#endif
