CC     = gcc
CFLAGS = -Wall -Wextra -O2 -Isrc
FLEX   = flex

greenscript: src/lex.yy.c src/main.c src/greenscript.h
	$(CC) $(CFLAGS) -o $@ src/lex.yy.c src/main.c

src/lex.yy.c: src/scanner.l src/greenscript.h
	$(FLEX) -o $@ src/scanner.l

# Corre cada testes/*.gs e compara a saída com o .esperado correspondente.
# O tr remove o \r que o stdout acrescenta em Windows.
test: greenscript
	@falhas=0; \
	for f in testes/*.gs; do \
		esperado="$${f%.gs}.esperado"; \
		if ./greenscript "$$f" | tr -d '\r' | diff -q - "$$esperado" > /dev/null; then \
			echo "OK    $$f"; \
		else \
			echo "FALHA $$f"; \
			./greenscript "$$f" | tr -d '\r' | diff - "$$esperado" | head -n 20; \
			falhas=$$((falhas + 1)); \
		fi; \
	done; \
	echo "Testes falhados: $$falhas"; \
	test $$falhas -eq 0

clean:
	rm -f greenscript src/lex.yy.c

.PHONY: test clean
