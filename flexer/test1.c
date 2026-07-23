#include <stdio.h>

/* # For tgc.v */
fn add<T>(T a, T b) {
  return a + b;
}

int main(void) {
  double res = add<double>(22.0/7.0, 100.0/3.0);
  printf("res is %f", res);
  return 123;
}