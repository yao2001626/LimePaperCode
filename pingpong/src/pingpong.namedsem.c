/* This version runs also under Linux and macOS, but execution takes about twice
as long as the version with unnamed semaphres. Compile and run with
"cc pingpong.c -o pingpong -lpthread; ./pingpong"

Named pthread semaphores are used for passing the "ball" between a ping thread
and a pong thread. Two split binary semaphores (i.e. at most one of them is 1)
are used for synchronization and for mutually exclusive access to a global
variable with the number of remaining bounces of the ball. The ping and pong
threads "do not know" about each other, they only communicate via the semaphores
and the global variable.

The main program waits for the the ping thread to terminate, which it does when
the number of remaining bounces reaches 0.
*/

#include <pthread.h>
#include <stdio.h>
#include <semaphore.h>
#include <fcntl.h> /* for O_CREAT etc. */

// #define Rounds 100000

sem_t *ping_mutex, *pong_mutex;
int bounces = 0;

void *ping(void *argptr) {
  sem_wait(ping_mutex);
  while (bounces > 0) {
    bounces -= 1;
    sem_post(pong_mutex);
    sem_wait(ping_mutex);
  }
  // printf("bounces: %d\n", bounces);
}
void *pong(void *argptr) {
  sem_wait(pong_mutex);
  while (bounces > 0) {
    bounces -= 1;
    sem_post(ping_mutex);
    sem_wait(pong_mutex);
  }
}
int main(int argc, char *argv[]) {
  if(argc < 2){
      printf("The Usage: %s Rounds\n", argv[0]);
      exit(1);
  }
  
  bounces = atoi(argv[1]);
  pthread_t ping_tid, pong_tid;
  ping_mutex = sem_open("ping", O_CREAT, S_IRUSR | S_IWUSR, 1);
  pong_mutex = sem_open("pong", O_CREAT, S_IRUSR | S_IWUSR, 0);
  sem_unlink ("ping"); /* prevents the semaphore existing */
  sem_unlink ("pong"); /* forever in case of crash */
  pthread_create(&ping_tid, NULL, ping, NULL);
  pthread_create(&pong_tid, NULL, pong, NULL);
  pthread_join(ping_tid, NULL);
}
