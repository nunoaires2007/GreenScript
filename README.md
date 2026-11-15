# GreenScript – Analisador Lexical

**Trabalho Prático 1 · Compiladores · Licenciatura em Engenharia Informática · UTAD**

| Grupo | |
| --- | --- |
| afonso martins | n.º2025163917 |
| afonso salgado | n.º2025167316 |
| nuno aires | n.º2025164088 |

---

## Índice

1. [Descrição](#1-descrição)
2. [Ferramentas e requisitos](#2-ferramentas-e-requisitos)
3. [Estrutura do projeto](#3-estrutura-do-projeto)
4. [Compilação](#4-compilação)
5. [Execução](#5-execução)
6. [Especificação lexical implementada](#6-especificação-lexical-implementada)
7. [Formato da saída](#7-formato-da-saída)
8. [Exemplos](#8-exemplos)
9. [Decisões de implementação](#9-decisões-de-implementação)
10. [Testes](#10-testes)
11. [Limitações e âmbito](#11-limitações-e-âmbito)
12. [Fontes e referências](#12-fontes-e-referências)

---

## 1. Descrição

GreenScript é a linguagem textual usada para comunicar com o controlador de uma estufa experimental: ventilação, aquecimento, rega, esperas e condições sobre a humidade do solo.

Este projeto implementa o **analisador lexical** da linguagem em **FLEX/C**. O programa lê um ficheiro de texto cujo caminho é recebido na linha de comandos e:

- identifica os tokens por ordem de ocorrência, indicando linha de início, categoria e lexema;
- ignora separadores (espaços, tabulações, mudanças de linha) e comentários;
- assinala os erros lexicais com linha e lexema e continua a análise;
- apresenta no fim os totais de tokens reconhecidos e de erros lexicais.

O analisador **não** valida a ordem dos tokens, o número de argumentos dos comandos, a estrutura das condições nem o estado da estufa, e não executa instruções. Essa validação pertence à análise sintática (TP2).

---

## 2. Ferramentas e requisitos

| Ferramenta | Versão testada | Função |
| --- | --- | --- |
| FLEX | 2.6.4 | gerador do analisador lexical |
| gcc | qualquer versão recente | compilação do código C |
| make | GNU Make | automatização da compilação |

Instalação das dependências:

```bash
# Debian / Ubuntu
sudo apt install flex gcc make

# Fedora
sudo dnf install flex gcc make

# macOS (Homebrew)
brew install flex
```

Só é usada a biblioteca standard de C (`stdio.h`). Não há dependências externas.

---

## 3. Estrutura do projeto

```
greenscript/
├── Makefile
├── README.md
├── src/
│   ├── scanner.l          especificação FLEX (regras, contadores, função de análise)
│   ├── main.c             programa principal (argumentos e resumo final)
│   └── greenscript.h      declaração dos contadores globais e da função de entrada
└── testes/
    ├── teste1_valido_comandos.gs          (+ .esperado)
    ├── teste2_valido_espera.gs            (+ .esperado)
    ├── teste3_valido_condicao.gs          (+ .esperado)
    ├── teste4_valido_sintaxe_invalida.gs  (+ .esperado)
    ├── teste5_erro_identificadores.gs     (+ .esperado)
    ├── teste6_erro_operadores.gs          (+ .esperado)
    ├── teste7_so_comentarios.gs           (+ .esperado)
    └── teste8_vazio.gs                    (+ .esperado)
```

Ficheiros gerados pela compilação (não fazem parte do código-fonte): `src/lex.yy.c` e o executável `greenscript`.

---

## 4. Compilação

Na raiz do projeto:

```bash
make
```

Isto executa o FLEX sobre `src/scanner.l`, gera `src/lex.yy.c` e compila-o com `src/main.c`, produzindo o executável `greenscript`.

Para apagar os ficheiros gerados:

```bash
make clean
```

Compilação manual, sem `make`:

```bash
flex -o src/lex.yy.c src/scanner.l
gcc -Wall -Wextra -O2 -Isrc -o greenscript src/lex.yy.c src/main.c
```

A compilação não deve produzir avisos.

---

## 5. Execução

```bash
./greenscript <ficheiro.gs>
```

O caminho do ficheiro é obrigatório e único.

| Situação | Comportamento | Código de saída |
| --- | --- | --- |
| análise concluída | imprime tokens, erros e resumo | 0 |
| ficheiro não abre | mensagem de erro em `stderr` | 1 |
| número de argumentos errado | mensagem de uso em `stderr` | 2 |

Os erros lexicais **não** alteram o código de saída: são parte do resultado da análise, não uma falha do programa.

---

## 6. Especificação lexical implementada

A linguagem distingue maiúsculas de minúsculas. Letras e algarismos dos tokens são ASCII; os comentários podem conter UTF-8.

### Tokens

| Categoria | Expressão regular (notação FLEX) | Exemplos válidos |
| --- | --- | --- |
| Palavras reservadas | `LIGAR` `DESLIGAR` `ABRIR` `FECHAR` `AQUECER` `PARAR` `REGAR` `ESPERAR` `SE` `SENAO` `HUMIDADE` `REPETIR` | `LIGAR`, `SENAO` |
| `ID_ESTUFA` | `EST-[A-Z][A-Z][0-9][0-9]` | `EST-AA01`, `EST-AB07` |
| `INTEIRO` | `0\|[1-9][0-9]*` | `0`, `15`, `1200` |
| `ABRE_PAR` / `FECHA_PAR` | `"("` / `")"` | `(` `)` |
| `ABRE_CHAVETA` / `FECHA_CHAVETA` | `"{"` / `"}"` | `{` `}` |
| `VIRGULA` | `","` | `,` |
| `PONTO_VIRG` | `";"` | `;` |
| `MENOR` / `MENOR_IGUAL` | `"<"` / `"<="` | `<` `<=` |
| `MAIOR` / `MAIOR_IGUAL` | `">"` / `">="` | `>` `>=` |
| `IGUAL_IGUAL` | `"=="` | `==` |
| `DIFERENTE` | `"!="` | `!=` |

As palavras reservadas têm como categoria o próprio nome.

### Ignorados

| Elemento | Expressão regular |
| --- | --- |
| Mudança de linha (LF ou CRLF) | `\r?\n` (incrementa a linha) |
| Espaços, tabulações e `\r` isolado | `[ \t\r]+` |
| Comentário | `#[^\n]*` (até ao fim da linha ou do ficheiro) |

### Erros lexicais

| Entrada | Resultado |
| --- | --- |
| sequência máxima de letras, algarismos, `-` ou `_` que não seja palavra reservada, `ID_ESTUFA` ou inteiro | **um** erro com a sequência completa: `LIGARX`, `ligar`, `EST-AA001`, `EST-A101`, `012`, `12abc` |
| carácter isolado não reconhecido | **um** erro por carácter: `=`, `!`, `+`, `*`, `@` |
| sequência de bytes não ASCII fora de comentários | **um** erro por sequência |

Os operadores usam reconhecimento mais longo: `<==` produz o token `<=` e um erro em `=`.

---

## 7. Formato da saída

Token válido (uma linha por token):

```
<LINHA> <CATEGORIA> <LEXEMA>
```

Erro lexical:

```
<LINHA> ERRO_LEXICAL <LEXEMA>   (motivo)
```

Resumo final:

```
Tokens: <X> | Erros lexicais: <Y>
```

- A linha começa em 1 e é a do **início** do lexema.
- Tokens e erros saem pela ordem de ocorrência, no mesmo fluxo (`stdout`).
- Os motivos possíveis são `sequencia invalida`, `carater nao reconhecido` e `carater nao-ASCII fora de comentario`.

---

## 8. Exemplos

### 8.1 Entrada válida

`exemplo.gs`:

```
# Preparação da estufa
LIGAR(EST-AA01);
REGAR(2,15);
```

```
$ ./greenscript exemplo.gs
2 LIGAR LIGAR
2 ABRE_PAR (
2 ID_ESTUFA EST-AA01
2 FECHA_PAR )
2 PONTO_VIRG ;
3 REGAR REGAR
3 ABRE_PAR (
3 INTEIRO 2
3 VIRGULA ,
3 INTEIRO 15
3 FECHA_PAR )
3 PONTO_VIRG ;
Tokens: 12 | Erros lexicais: 0
```

### 8.2 Condição com erros

`exemplo2.gs`:

```
SE (HUMIDADE(2)<=30) { REGAR(2,15); }
LIGARX @ <== 012
```

```
$ ./greenscript exemplo2.gs
1 SE SE
1 ABRE_PAR (
1 HUMIDADE HUMIDADE
1 ABRE_PAR (
1 INTEIRO 2
1 FECHA_PAR )
1 MENOR_IGUAL <=
1 INTEIRO 30
1 FECHA_PAR )
1 ABRE_CHAVETA {
1 REGAR REGAR
1 ABRE_PAR (
1 INTEIRO 2
1 VIRGULA ,
1 INTEIRO 15
1 FECHA_PAR )
1 PONTO_VIRG ;
1 FECHA_CHAVETA }
2 ERRO_LEXICAL LIGARX   (sequencia invalida)
2 ERRO_LEXICAL @   (carater nao reconhecido)
2 MENOR_IGUAL <=
2 ERRO_LEXICAL =   (carater nao reconhecido)
2 ERRO_LEXICAL 012   (sequencia invalida)
Tokens: 19 | Erros lexicais: 4
```

Repare-se que `LIGARX` e `012` geram um único erro cada, sem tokens parciais, e que `<==` dá `<=` mais um erro em `=`.

### 8.3 Análise lexical não é análise sintática

`LIGAR();` ou uma sequência como `) ( ; ;` produzem apenas tokens válidos e **nenhum** erro: a verificação da estrutura fica para o TP2.

---

## 9. Decisões de implementação

**Candidato lexical.** O FLEX escolhe o lexema mais longo e, em caso de empate, a regra escrita primeiro. O `scanner.l` aproveita isto: as regras específicas (palavras reservadas, `ID_ESTUFA`, `INTEIRO`) vêm antes da regra genérica `[A-Za-z0-9_-]+`. Se a sequência máxima for válida, a regra específica empata em comprimento e ganha; caso contrário, a genérica é mais longa e gera um único erro. Assim nunca se devolvem tokens parciais (`12abc` nunca dá `12` + `abc`).

**Contagem de linhas.** O analisador mantém a sua própria variável `linha`, atualizada só pela regra `\r?\n`. LF e CRLF contam uma mudança de linha. Um `\r` isolado é tratado como espaço. O comentário consome até ao `\n`, por isso um comentário em ficheiro CRLF também conta a linha corretamente.

**Comentários e UTF-8.** `#[^\n]*` aceita qualquer byte até ao fim da linha, pelo que texto UTF-8 em comentários não gera tokens nem erros. Fora de comentários, bytes não ASCII geram um único erro por sequência (`[\x80-\xFF]+`), em vez de um erro por byte.

**Recuperação de erros.** Após um erro o analisador consome o candidato inválido completo, ou apenas o carácter isolado, e continua.

**Organização do código.** O `scanner.l` define os contadores e a função `analisa_ficheiro()`; o `main.c` só trata dos argumentos e do resumo final. Os inteiros ficam como texto, sem conversão numérica nem limite semântico.

---

## 10. Testes

Cada `testes/<nome>.gs` tem a saída esperada em `testes/<nome>.esperado`, obtida com este analisador e verificada à mão contra as regras do enunciado.

| Ficheiro | Conteúdo | Tokens | Erros |
| --- | --- | --- | --- |
| `teste1_valido_comandos.gs` | todos os comandos simples, incluindo `LIGAR();` | 37 | 0 |
| `teste2_valido_espera.gs` | `ESPERAR` com `0`, `60` e `1200` | 23 | 0 |
| `teste3_valido_condicao.gs` | `SE`/`SENAO` e os 6 operadores, com e sem espaços | 192 | 0 |
| `teste4_valido_sintaxe_invalida.gs` | tokens válidos em ordem sintaticamente errada; `REPETIR`, `SE`/`SENAO` | 75 | 0 |
| `teste5_erro_identificadores.gs` | `LIGARX`, `ligar`, `EST-AA001`, `EST-A101`, `EST-aa01`, `012`, `12abc`, `00`, `060`, `SENAOO`, `EST-AB07-`, `_x` | 10 | 12 |
| `teste6_erro_operadores.gs` | `=` e `!` isolados, `<==`, `>==`, `+`, `*`, `@` | 54 | 7 |
| `teste7_so_comentarios.gs` | comentários (com UTF-8), linhas vazias, espaços e tabulações | 0 | 0 |
| `teste8_vazio.gs` | ficheiro vazio | 0 | 0 |

Para acrescentar um teste, basta criar `testes/<nome>.gs` e o respetivo `testes/<nome>.esperado`.

### Executar todos os testes

```bash
for f in testes/*.gs; do
  ./greenscript "$f" | diff -q - "${f%.gs}.esperado" > /dev/null \
    && echo "OK     $f" || echo "FALHA  $f"
done
```

Resultado esperado: oito linhas `OK`.

### Executar um teste e ver a saída

```bash
./greenscript testes/teste5_erro_identificadores.gs
```

---

## 11. Limitações e âmbito

- Não há validação sintática nem semântica (ordem dos tokens, argumentos, intervalos de valores, correspondência de chavetas).
- Os operadores aritméticos `+` e `*` são erros lexicais nesta versão.
- A regra do candidato lexical (`[A-Za-z0-9_-]+`) é específica desta versão da linguagem e será adaptada no TP2 para permitir operadores aritméticos, já que o `-` passará a ter outro papel.
- O ficheiro de entrada é lido em modo binário; não há tratamento de outras codificações além de ASCII/UTF-8.
