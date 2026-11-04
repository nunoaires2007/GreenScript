# Teste 3 (válido): condição com SENAO e todos os operadores relacionais
SE (HUMIDADE(2) < 30) { REGAR(2,15); } SENAO { ESPERAR(60); }

# Com espaços
SE (HUMIDADE(1) <= 30) { REGAR(1,10); }
SE (HUMIDADE(1) > 70) { ABRIR(); }
SE (HUMIDADE(1) >= 80) { ABRIR(); }
SE (HUMIDADE(3) == 50) { ESPERAR(10); }
SE (HUMIDADE(3) != 0) { FECHAR(); }

# Sem espaços entre operandos e operadores
HUMIDADE(2)<=30
HUMIDADE(2)<30
HUMIDADE(2)>30
HUMIDADE(2)>=30
HUMIDADE(2)==30
HUMIDADE(2)!=30
SE(HUMIDADE(4)<10){REGAR(4,30);}SENAO{ESPERAR(15);}
# Comentário no fim do ficheiro sem mudança de linha: ºçãé€