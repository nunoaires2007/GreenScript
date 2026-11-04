# Teste 6 (invalido): caracteres nao reconhecidos e operadores incompletos
@
LIGAR(EST-AA01) @ DESLIGAR();
SE (HUMIDADE(2) = 30) { REGAR(2,15); }
SE (! HUMIDADE(2)) { ESPERAR(60); }
HUMIDADE(2)<==30
HUMIDADE(2)!==30
HUMIDADE(2)=!30
HUMIDADE(2)>==<30
AQUECER(20+4);
REGAR(2*3,15);
ESPERAR(60)$ % & [ ] . : "
