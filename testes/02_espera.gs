# Teste 2 (valido): espera e repeticao
# Este ficheiro usa terminacoes de linha CRLF.
LIGAR(EST-AB07);

# Ventilacao aberta durante 60 segundos
ABRIR(); ESPERAR(60); FECHAR();

REPETIR(3) { ABRIR(); ESPERAR(60); FECHAR(); ESPERAR(30); }

# Repeticao contendo SE e SENAO
REPETIR(5) {
	SE (HUMIDADE(1) < 40) { REGAR(1,20); } SENAO { ESPERAR(120); }
}
DESLIGAR();
