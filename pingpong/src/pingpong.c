/* Compile under Linux with "cc pingpong.c -o pingpong -lpthread; ./pingpong"
Does not run under macOS as unnamed semaphores with sem_init are not supported.

Unnamed pthread semaphores are used for passing the "ball" between a ping thread
and a pong thread. Two split binary semaphores (i.e. at most one of them is 1)
are used for synchronization and for mutually exclusive access to a global
variable with the number of remaining bounces of the ball. The ping and pong
threads "do not know" about each other, they only communicate via the semaphores
and the global variable.

The main program waits for the ping thread to terminate, which it does when the
number of remaining bounces reaches 0.
*/
#include <pthread.h>
#include <stdio.h>
#include <semaphore.h>
#include <stdlib.h>

// #define Rounds 100000

sem_t ping_mutex, pong_mutex;
int bounces = 0;

void *ping(void *argptr) {
  sem_wait(&ping_mutex);
  while (bounces > 0) {
    bounces -= 1;
    sem_post(&pong_mutex);
    sem_wait(&ping_mutex);
  }
  // printf("bounces: %d\n", bounces);
}
void *pong(void *argptr) {
  sem_wait(&pong_mutex);
  while (bounces > 0) {
    bounces -= 1;
    sem_post(&ping_mutex);
    sem_wait(&pong_mutex);
  }
}
int main(int argc, char *argv[]) {
  if(argc < 2){
      printf("The Usage: %s Rounds\n", argv[0]);
      exit(1);
  }
  
  bounces = atoi(argv[1]);
  pthread_t ping_tid, pong_tid;
  sem_init(&ping_mutex, 0, 1);
  sem_init(&pong_mutex, 0, 0);
  pthread_create(&ping_tid, NULL, ping, NULL);
  pthread_create(&pong_tid, NULL, pong, NULL);
  pthread_join(ping_tid, NULL);
  return 0;
}
