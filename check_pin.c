#include <stdio.h>

#define PIN_SIZE 4

int check_pin(const char *pin) {
  return 0;
}

int get_and_check_pin(void) {
  int res = 0;
  char provided_pin[PIN_SIZE];

  printf("Enter your %d-digit PIN: ", PIN_SIZE);
  gets(provided_pin);

  if (check_pin(provided_pin)) {
    res = 1;
  }
  return res;
}

void main() {
  int res = get_and_check_pin();
  if (res) {
    printf("Correct pin!\n");
  } else {
    printf("Incorrect pin!\n");
  }
}
