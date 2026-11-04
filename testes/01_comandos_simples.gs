# Teste 1 (valido): todos os comandos simples
LIGAR(EST-AA01);
ABRIR();
AQUECER(24);
REGAR(2,15);
REGAR(0,100);
FECHAR();
PARAR();
DESLIGAR();

# LIGAR(); e lexicalmente valido, embora falte o argumento:
# a analise sintatica (TP2) e que o rejeitara.
LIGAR();
LIGAR(EST-ZB99);
