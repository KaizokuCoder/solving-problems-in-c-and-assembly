#include <stdio.h>

/* Desenvolva um programa que receba dois valores para efetuar operações
 * matemáticas de acordo com a opção do usuário, 1 para soma, 2 para subtração
 * (do primeiro pelo segundo), 3 para multiplicação, 4 para divisão (do primeiro
 * pelo segundo). Qualquer valor diferente desse deve retornar uma mensagem de
 * erro. Apresente o resultado da operação. */

int main(void) {
  int num1, num2, operador;

  printf("Escolha a operacao(1 = soma, 2 = subtracao, 3 = multiplicacao e 4 = divisao): ");
  scanf("%d", &operador);

  if (operador < 1 || operador > 4) {
    printf("OPERACAO INVALIDA");

  } else {
    printf("Primeiro numero: ");
    scanf("%d", &num1);

    printf("Segundo numero: ");
    scanf("%d", &num2);

    if (operador == 1) {
      printf("%d + %d = %d", num1, num2, num1 + num2);

    } else if (operador == 2) {
      printf("%d - %d = %d", num1, num2, num1 - num2);

    } else if (operador == 3) {
      printf("%d x %d = %d", num1, num2, num1 * num2);

    } else if (operador == 4) {
      printf("%d / %d = %d, de resto: %d", num1, num2, (int)num1 / num2, num1 % num2);
    }
  }

  return 0;
}
