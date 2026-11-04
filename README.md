# GreenScript - Analisador Lexical (TP1)

Trabalho Prático 1 da unidade curricular de Compiladores (UTAD).
Analisador lexical para a linguagem de controlo de estufas GreenScript desenvolvido em FLEX e C.

## Requisitos de Ferramentas
* **FLEX** (versão 2.6.4 ou superior)
* **GCC** (suporte para C99/C11)
* **Make**

Em Ubuntu/WSL: `sudo apt install flex build-essential`

## Estrutura
```
src/scanner.l        especificação FLEX (regras, diagnósticos, analisa_ficheiro)
src/main.c           programa principal (argumentos e totais)
src/greenscript.h    declarações partilhadas
testes/*.gs          ficheiros de entrada
testes/*.esperado    saída esperada de cada teste
Makefile
```

## Compilação
Para compilar o projeto e gerar o executável `greenscript`:

```bash
make
```

Equivalente sem Make:

```bash
flex -o src/lex.yy.c src/scanner.l
gcc -Wall -Wextra -O2 -Isrc -o greenscript src/lex.yy.c src/main.c
```

Para apagar os ficheiros gerados: `make clean`

## Execução
```bash
./greenscript <ficheiro.gs>
```

Exemplo:

```bash
./greenscript testes/01_comandos_simples.gs
```

Códigos de saída: `0` análise concluída (mesmo com erros lexicais), `1` ficheiro não abre, `2` número de argumentos errado.

## Formato da saída
Cada token é escrito numa linha, pela ordem de ocorrência, com a linha onde começa, a categoria e o lexema:

```
2 LIGAR       LIGAR
2 ABRE_PAR    (
2 ID_ESTUFA   EST-AA01
```

Cada erro lexical indica a linha e o lexema, e a análise continua a seguir:

```
Erro lexical na linha 3: sequencia invalida 'LIGARX'
Erro lexical na linha 4: caracter nao reconhecido '@'
```

No fim é apresentado o total:

```
Tokens: 12 | Erros lexicais: 0
```

## Categorias de tokens

| Categoria | Lexemas |
|---|---|
| `LIGAR`, `DESLIGAR`, `ABRIR`, `FECHAR`, `AQUECER`, `PARAR`, `REGAR`, `ESPERAR`, `SE`, `SENAO`, `HUMIDADE`, `REPETIR` | a própria palavra reservada |
| `ID_ESTUFA` | `EST-` + duas maiúsculas + dois algarismos (ex.: `EST-AB07`) |
| `INTEIRO` | `0` ou algarismos começados por 1-9 (ex.: `15`) |
| `ABRE_PAR` / `FECHA_PAR` | `(` / `)` |
| `ABRE_CHAV` / `FECHA_CHAV` | `{` / `}` |
| `VIRGULA` / `PONTO_VIRG` | `,` / `;` |
| `MENOR` / `MENOR_IGUAL` | `<` / `<=` |
| `MAIOR` / `MAIOR_IGUAL` | `>` / `>=` |
| `IGUAL` / `DIFERENTE` | `==` / `!=` |

Tipos de erro:

| Diagnóstico | Quando ocorre |
|---|---|
| `sequencia invalida` | sequência máxima de letras, algarismos, `-` ou `_` que não é palavra reservada, identificador de estufa nem inteiro (ex.: `LIGARX`, `ligar`, `EST-A101`, `012`, `12abc`) |
| `caracter nao reconhecido` | qualquer outro carácter fora de comentários (ex.: `@`, `=` e `!` isolados, `+`, `*`) |

Espaços, tabulações, mudanças de linha (LF ou CRLF) e comentários (`#` até ao fim da linha) são ignorados.

## Testes
| Ficheiro | Conteúdo |
|---|---|
| `01_comandos_simples.gs` | válido: todos os comandos, incluindo `LIGAR();` |
| `02_espera.gs` | válido: `ESPERAR`, `REPETIR`, repetição com `SE`/`SENAO` (terminações CRLF) |
| `03_condicoes_operadores.gs` | válido: condição com `SENAO` e os seis operadores, com e sem espaços |
| `04_sintaxe_incorreta.gs` | válido lexicalmente, mas sintaticamente incorreto |
| `05_erros_sequencias.gs` | inválido: sequências malformadas |
| `06_erros_caracteres.gs` | inválido: caracteres não reconhecidos, `=` e `!` isolados, `<==`, `+`, `*` |
| `07_comentarios.gs` | só comentários e separadores (0 tokens, 0 erros) |
| `08_vazio.gs` | ficheiro vazio (0 tokens, 0 erros) |

Para compilar (se necessário), correr todos os testes e comparar com a saída esperada:

```bash
make test
```

Cada teste aparece como `OK` ou `FALHA`; nas falhas é mostrada a diferença (`<` saída obtida, `>` esperada). O comando termina com erro se algum teste falhar.

Para acrescentar um teste, basta criar `testes/<nome>.gs` e o respetivo `testes/<nome>.esperado`.
