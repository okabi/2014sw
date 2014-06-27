#include <stdio.h>
#include <math.h>
main(){
  int i;
  int j;
  for(i = 0; i < 20; i++){
    printf("fact(%d) => %d\n", i, fact(i));
  }
  for(i = 0; i < 20; i++){
    printf("fib(%d) => %d\n", i, fib(i));
  }
  for(i = 0; i < 20; i++){
    printf("sum(%d) => %d\n", i, sum(i));
  }
  for(i = -10; i < 30; i++){
    printf("compNum(%d) => %d\n", i, compNum(i));
  }
  printf("test(0,0) => %d\n", test(0,0));
  printf("test(1,2) => %d\n", test(1,2));
  printf("test(1,1) => %d\n", test(1,1));
  printf("test(15,8) => %d\n", test(15,8));

}
