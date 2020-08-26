/* Compile under Linux with
"cc threadring.sem.c -o threadring -lpthread -D Hops=100000 -D Nodes=1000"; run
with "./threadring". Does not run under macOS as unnamed semaphores
(using sem_init) are not supported.

Unnamed pthread semaphores are used for passing the token between node threads.
An array of split binary semaphores (i.e. at most one of them is 1) is used for
synchronization and for mutually exclusive access to global variable token with
the remaining number of hops. The node threads threads "do not know" about each
other, they only communicate via the semaphores and the token variable. When a
node thread decrements token to 0, it prints its id, otherwise it signals the
next node thread.

In C, a program terminates when the main program terminates. Here, the main
program waits for all node threads to terminate, which they do when they don't
expect any more tokens, i.e. the received token value is less than the number of
nodes.
*/

#include <pthread.h>
#include <stdio.h>
#include <semaphore.h>
#include <stdlib.h>

sem_t *node_sem;
int token;
int Nodes;
void *node(void *argptr) {
  long nid = (long) argptr;
  do {
    sem_wait(&node_sem[nid]);
    // printf("%d received %d\n", nid, token);
    if (token > 0) {
      token -= 1;
      sem_post(&node_sem[(nid + 1) % Nodes]);
    } else printf("%ld\n", nid);
  } while (token >= Nodes - 1);
}
int main(int argc, char *argv[]) {
  if(argc < 3){
      printf("The Usage: %s Hops Nodes\n", argv[0]);
      exit(1);
  }
  token = atoi(argv[1]);
  Nodes = atoi(argv[2]);
  node_sem = (sem_t *)malloc(sizeof(sem_t)*Nodes);
  pthread_t tid[Nodes];
  for (long n = 0; n < Nodes; n++) {
    sem_init(&node_sem[n], 0, 0);
    pthread_create(&tid[n], NULL, node, (void *) n);
  }
  sem_post(&node_sem[0]);
  for (long n = 0; n < Nodes; n++) {
    pthread_join(tid[n], NULL);
  }
}
