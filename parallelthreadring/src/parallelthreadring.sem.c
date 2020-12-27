/* Compile under Linux with
"cc parallelthreadring.sem.c -o parallelthreadring -lpthread -D Hops=10000 -D Nodes=1000 -D Tokens=100";
run with "./threadring". Does not run under macOS as unnamed semaphores
(using sem_init) are not supported.

Unnamed pthread semaphores are used for passing the token between node threads.
An array of split binary semaphores (i.e. at most one of them is 1) is used for
synchronization and for mutually exclusive access to global variable token with
the remaining number of hops. The node threads threads "do not know" about each
other, they only communicate via the semaphores and the token variable. When a
node thread receives a token with value 0, it signals to the main thread that it
is done, otherwise it forwards the token minus 1 to the next node.

In C, a program terminates when the main program terminates. Here, the main
program waits for all node threads to signal that they are done.
*/

#include <pthread.h>
#include <stdio.h>
#include <semaphore.h>

sem_t done;
sem_t full[Nodes];
sem_t empty[Nodes];
int tok[Nodes];

void *node(void *argptr) {
  long nid = (long) argptr;
  for (;;) {
    sem_wait(&full[nid]);
    int t = tok[nid]; // printf("%d received %d\n", nid, t);
    sem_post(&empty[nid]);
    if (t > 0) {
      sem_wait(&empty[(nid + 1) % Nodes]);
      tok[(nid + 1) % Nodes] = t - 1;
      sem_post(&full[(nid + 1) % Nodes]);
    } else sem_post(&done);
  }
}
int main(int argc, char *argv[]) {
  pthread_t tid[Nodes];
  sem_init(&done, 0, 0);
  for (long n = 0; n < Nodes; n++) {
    sem_init(&full[n], 0, 0);
    sem_init(&empty[n], 0, 1);
    pthread_create(&tid[n], NULL, node, (void *) n);
  }
  for (int t = 0; t < Tokens; t++) {
    sem_wait(&empty[0]); tok[0] = Hops; sem_post(&full[0]);
  }
  for (int t = 0; t < Tokens; t++) sem_wait(&done);
}
