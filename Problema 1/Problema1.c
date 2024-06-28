#include <stdio.h>

/* Desenvolva um programa que receba dois valores para efetuar operações
 * matemáticas de acordo com a opção do usuário, 1 para soma, 2 para subtração
 * (do primeiro pelo segundo), 3 para multiplicação, 4 para divisão (do primeiro
 * pelo segundo). Qualquer valor diferente desse deve retornar uma mensagem de
 * erro. Apresente o resultado da operação. */

int main(void) {

  int num_1, num_2, operador;
  printf(
      "Escolha a operacao(1 para soma, 2 para subtracao, 3 para multiplicacao, "
      "4 para divisao):  ");
  scanf("%d", &operador);

  if (operador < 1 || operador > 6) {
    printf("OPERACAO INVALIDA");

  } else {
    printf("Primeiro numero: ");
    scanf("%d", &num_1);

    printf("Segundo numero: ");
    scanf("%d", &num_2);

    if (operador == 1) {
      printf("Soma: %d + %d = %d", num_1, num_2, num_1 + num_2);

    } else if (operador == 2) {
      printf("Subtracao: %d - %d = %d", num_1, num_2, num_1 - num_2);

    } else if (operador == 3) {
      printf("Multiplicacao: %d x %d = %d", num_1, num_2, num_1 * num_2);

    } else if (operador == 4) {
      printf("Divisao: %d / %d = %d", num_1, num_2, num_1 / num_2);
    }
  }

  return 0;
}
