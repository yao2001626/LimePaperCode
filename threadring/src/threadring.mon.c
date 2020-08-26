/* Compile under Linux and macOS with
"cc threadring.mon.c -o threadring -lpthread -D Hops=100000 -D Nodes=1000"; run
with "./threadring".

Each node is a monitor with NodeStruct as its state and pass as a monitor
procedure. Each node has also a thread, node_thread, that accesses the monitor
state, thus implementing an active object. There are no global variable
declarations, each node has a pointer to its successor. Pthread mutexes and
condition variables are used to access the node state. When a node thread
receives a token with value 0, it prints its id, otherwise it passes the token
minus 1 to the successor node.

In C, a program terminates when the main program terminates. Here, the main
program waits for all node threads to terminate, which they do when they don't
expect any more tokens, i.e. the received token value is less than the number of
nodes.
*/

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct NodeStruct {
  pthread_mutex_t lock;
  pthread_cond_t empty, full;
  struct NodeStruct *next;
  int token, nid, nodes;
} node_t;

void pass(node_t *this, int token) {
  pthread_mutex_lock(&this->lock);
  while (this->token != -1) pthread_cond_wait(&this->empty, &this->lock);
  this->token = token;
  pthread_cond_signal(&this->full);
  pthread_mutex_unlock(&this->lock);
}
void *node_thread(void *argptr) {
  node_t *this = (node_t *) argptr;
  pthread_mutex_lock(&this->lock);
  for (;;) {
    while (this->token == -1) pthread_cond_wait(&this->full, &this->lock);
    //printf("%d processing %d\n", this->nid, this->token);
    if (this->token > 0) pass(this->next, this->token - 1);
    else printf("%d\n", this->nid);
    if (this->token < this->nodes) break;
    this->token = -1;
    pthread_cond_signal(&this->empty);
  }
  pthread_mutex_unlock(&this->lock);
  return NULL;
}
int main(int argc, char *argv[]) {
  if(argc < 3){
      printf("The Usage: %s Hops Nodes\n", argv[0]);
      exit(1);
  }
  int Hops = atoi(argv[1]);
  int Nodes = atoi(argv[2]);
  node_t *node = (node_t *)malloc(sizeof(node_t)*Nodes);
  pthread_t *nt = (pthread_t *)malloc(sizeof(pthread_t)*Nodes);
  for (int n = 0; n < Nodes; n++) {
    pthread_mutex_init(&node[n].lock, NULL);
    pthread_cond_init(&node[n].empty, NULL);
    pthread_cond_init(&node[n].full, NULL);
    node[n].next = &node[(n + 1) % Nodes];
    node[n].token = -1;
    node[n].nid = n;
    node[n].nodes = Nodes;
  }
  for (int n = 0; n < Nodes; n++) {
    pthread_create(&nt[n], NULL, node_thread, &node[n]);
  }
  pass(&node[0], Hops);
  for (int n = 0; n < Nodes; n++) {
    pthread_join(nt[n], NULL);
  }
}
