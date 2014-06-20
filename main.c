#include <stdio.h>
main(){
  int i;
  int j;
  for(i = 0; i < 20; i++){
    printf("fact(%d) => %d\n", i, fact(i));
  }
  for(i = 0; i < 15; i++){
    printf("bigger(%d) => %d\n", 10*i, bigger(10*i));
  }
}
