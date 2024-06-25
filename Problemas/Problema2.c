#include <stdio.h>
#include <string.h>

int main() {
  int n;
  int n_dividers = 0;

  printf("Digite um numero para saber se ele eh primo: ");
  scanf("%d", &n);

  for (int i = 2; i <= (int)n/2; i++) {
    if (n % i == 0) {
      if (n_dividers == 0) {
        printf("%d nao eh primo e tem como divisores 1", n);
        n_dividers++;
      }
      printf(" %d", i);
    }
  }

  if (n_dividers == 0) {
    printf("%d eh primo", n);
  }

  return 0;
}

