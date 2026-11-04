# Teste 1 (válido): todos os comandos simples
LIGAR(EST-AA01);
ABRIR();
AQUECER(24);
REGAR(2,15);
REGAR(0,100);
FECHAR();
PARAR();
DESLIGAR();

# LIGAR(); é lexicalmente válido, embora falte o argumento:
# a análise sintática (TP2) é que o rejeitará.
LIGAR();
LIGAR(EST-ZB99);
