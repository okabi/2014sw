#include <stdio.h>
main(){
  int i;
  int j;
  for(i = 0; i < 20; i++){
    printf("fact(%d) => %d\n", i, fact(i));
  }
}
