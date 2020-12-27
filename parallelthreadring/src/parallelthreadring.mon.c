/* Compile under Linux and macOS with
"cc parallelthreadring.mon.c -o parallelthreadring -lpthread -D Hops=10000 -D Nodes=1000 -D Tokens=100";
run with "./threadring".

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

typedef struct NodeStruct {
  pthread_mutex_t lock;
  pthread_cond_t empty, full;
  struct NodeStruct *next;
  int token, nid;
} node_t;

struct CounterStruct {
  pthread_mutex_t lock;
  pthread_cond_t zero;
  int count;
} counter;

void pass(node_t *this, int token) {
  pthread_mutex_lock(&this->lock);
  while (this->token != -1) pthread_cond_wait(&this->empty, &this->lock);
  this->token = token;
  pthread_cond_signal(&this->full);
  pthread_mutex_unlock(&this->lock);
}
void dec() {
  pthread_mutex_lock(&counter.lock);
  counter.count -= 1;
  if (counter.count == 0) pthread_cond_signal(&counter.zero);
  pthread_mutex_unlock(&counter.lock);
}
void zero() {
  pthread_mutex_lock(&counter.lock);
  if (counter.count != 0) pthread_cond_wait(&counter.zero, &counter.lock);
  pthread_mutex_unlock(&counter.lock);
}
void *node_action(void *argptr) {
  node_t *this = (node_t *) argptr;
  pthread_mutex_lock(&this->lock);
  for (;;) {
    while (this->token == -1) pthread_cond_wait(&this->full, &this->lock);
    // printf("%d processing %d\n", this->nid, this->token);
    if (this->token > 0) pass(this->next, this->token - 1);
    else printf("%d\n", this->nid);
    if (this->token < Nodes) dec();
    this->token = -1;
    pthread_cond_signal(&this->empty);
  }
  pthread_mutex_unlock(&this->lock);
}
int main(int argc, char *argv[]) {
  node_t node[Nodes];
  pthread_t nt[Nodes];
  for (int n = 0; n < Nodes; n++) {
    pthread_mutex_init(&node[n].lock, NULL);
    pthread_cond_init(&node[n].empty, NULL);
    pthread_cond_init(&node[n].full, NULL);
    node[n].next = &node[(n + 1) % Nodes];
    node[n].token = -1;
    node[n].nid = n;
    pthread_create(&nt[n], NULL, node_action, &node[n]);
  }
  for (int t = 0; t < Tokens; t++) pass(&node[0], Hops);
  for (int t = 0; t < Tokens; t++) zero();
}
