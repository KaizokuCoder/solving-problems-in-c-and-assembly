#include <stdio.h>

short pa(int first, int last, int num) {
  return ((first + last) * num) / 2;
}

int main() {
  short first, last, num;

  printf("Digite o primeiro digito da PA:  ");
  scanf("%d", &first);

  printf("Digite o ultimo digito da PA:    ");
  scanf("%d", &last);

  printf("Digite o numero de termos da PA: ");
  scanf("%d", &num);

  short result = pa(first, last, num);

  printf("A soma da PA eh: %d", result);
}

