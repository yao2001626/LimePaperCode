/* Compile under Linux with "cc big.c -o big -lpthread"; run with "./big". Does
not run under macOS as unnamed semaphores (using sem_init) are not supported.

This implementation of the Big benchmark uses pthread semaphores for monitors
with open calls: each worker has two procedures, ping and pong, as well as
a mutex, a binary semaphore. The mutex is acquired at entry to ping and pong
and is released at their exits; additionally, the mutex is released when
a call leaves the monitor and re-acquired on return.

In C, a program terminates when the main program terminates. Here, the main
program waits for all worker threads to terminate, which they do after the
specified number of rounds.
*/

#include <pthread.h>
#include <stdio.h>
#include <assert.h>
#include <semaphore.h>

#define Workers 100
#define Neighbourhoods 10
#define Rounds 10000

/* Supervisor */
sem_t sup_mutex;
int min = 0, max = 0;
void done(int pingpong) {
  sem_wait(&sup_mutex); // monitor entry
    if (pingpong < min) min = pingpong;
    else if (pingpong > max) max = pingpong;
  sem_post(&sup_mutex); // monitor exit
}

/* Workers */
typedef struct Worker {
  pthread_t tid;
  sem_t mutex;
  int id;
  struct Worker *neighbours;
  int rand;
  int pingpong;
} Worker;

int recipient(Worker *this) { // random neighbour different from this->id
  while (1) {
    this->rand = (32236 * this->rand) % 65521; // 2^16 - 15
    int result = this->rand % Workers;
    if (result != this->id) return result;
  }
}
void pong(Worker *this, int this_id) {
  sem_wait(&this->mutex); // monitor entry
    assert(this->id == this_id);
    this->pingpong -= 1;
  sem_post(&this->mutex); // monitor exit
}
void ping(Worker *this, Worker *w, int id) {
  sem_wait(&this->mutex); // monitor entry
    sem_post(&this->mutex);
    pong(w, id); // open monitor call
    sem_wait(&this->mutex);
  sem_post(&this->mutex); // monitor exit
}
void *worker(void *argptr) {
  Worker *this = ((Worker *) argptr);
  sem_wait(&this->mutex); // monitor entry
    for (int r = 0; r < Rounds; r++) {
      this->pingpong += 1;
      int n = recipient(this);
      sem_post(&this->mutex);
      ping(&this->neighbours[n], this, this->id); // open monitor call
      sem_wait(&this->mutex);
    }
    done(this->pingpong);
  sem_post(&this->mutex); // monitor exit
}
int main(int argc, char *argv[]) {
  sem_init(&sup_mutex, 0, 1);
  Worker allworkers[Neighbourhoods][Workers];
  for (int n = 0; n < Neighbourhoods; n++) {
    for (int w = 0; w < Workers; w++) {
      sem_init(&allworkers[n][w].mutex, 0, 1);
      allworkers[n][w].id = w;
      allworkers[n][w].neighbours = allworkers[n];
      allworkers[n][w].rand = 12345 + w;
      allworkers[n][w].pingpong = 0;
    }
    for (int w = 0; w < Workers; w++) {
      pthread_create(&allworkers[n][w].tid, NULL, worker, &allworkers[n][w]);
    }
  }
  for (int n = 0; n < Neighbourhoods; n++) {
    for (int w = 0; w < Workers; w++) {
      pthread_join(allworkers[n][w].tid, NULL);
    }
  }
  printf("min, max: %d, %d\n", min, max);
}
