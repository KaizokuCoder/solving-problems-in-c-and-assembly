#include <stdio.h>

int main() {
  // Declaração de variáveis
  int n;
  int is_prime = 1;

  // Imprime a mensagem
  printf("Digite um numero para saber se ele eh primo: ");
  // Pega o input do usuário
  scanf("%d", &n);

  // Imprime o número
  printf("%d ", n);

  // Loop de 2 até n/2
  for (int i = 2; i <= (int)n/2; i++) {
    if (n % i == 0) {
      if (is_prime == 1) {
        printf("nao eh primo e tem como divisores");
        is_prime = 0;
      }
      printf(" %d", i);
    }
  }

  // Verifica se o número é primo
  if (is_prime) {
    printf("eh primo");
  }

  return 0;
}
