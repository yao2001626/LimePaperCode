/* Compile under Linux with "cc chameneos.c -o chameneos -lpthread"; run with
"./chameneos". Does not run under macOS as unnamed semaphores (using sem_init)
are not supported.

Unnamed pthread semaphores are used. The mall and each worker are threads that
synchronize with three binay semaphores:
- req_meet: for chameneos arriving at mall and requesting to meet
- sent_meet: for chameneos notifying that they provided their color
- req_other: for chameneos waiting to receive the color of their partner
Each chameneos has a local variable with the color of their partner. Chameneos
pass a pointer to that local variable together with their own color to the mall.

In C, a program terminates when the main program terminates. Here, the main
program waits for the mall thread to terminate.
*/

#include <pthread.h>
#include <stdio.h>
#include <semaphore.h>

#define Chams 100
#define Rounds 1000

typedef enum {blue, red, yellow} Color;

sem_t req_meet, sent_meet, req_other;
Color color;
Color *reply;

void *chameneos(void *colptr) {
  Color col = *((int *) colptr);
  Color othercol;
  for (;;) {
    // in forest
    sem_wait(&req_meet);
    color = col;
    reply = &othercol;
    sem_post(&sent_meet);
    // waiting to meet
    sem_wait(&req_other);
    // changing color
    if (col != othercol) col = 3 - col - othercol;
  }
}

void *mall(void *ptr) {
  int diff = 0;
  for (int r = 0; r < Chams * Rounds / 2; r++) {
    sem_wait(&sent_meet);
    Color fstcol = color;
    Color *fstreply = reply;
    sem_post(&req_meet);
    sem_wait(&sent_meet);
    Color sndcol = color;
    Color *sndreply = reply;
    sem_post(&req_meet);
    *fstreply = sndcol;
    *sndreply = fstcol;
    sem_post(&req_other);
    sem_post(&req_other);
    if (fstcol != sndcol) diff += 1;
  }
  printf("Color changes: %d\n", diff);
}

int main(int argc, char *argv[]) {
  pthread_t mid, cid[Chams];  // id's of mall, chameneos
  sem_init(&req_meet, 0, 1);  // semaphore req_meet = 1
  sem_init(&sent_meet, 0, 0); // semaphore sent_meet = 0
  sem_init(&req_other, 0, 0); // semaphore req_other = 0
  pthread_create(&mid, NULL, mall, NULL);
  for (int i = 0; i < Chams; i++) {
    int col = i % 3;
    pthread_create(&cid[i], NULL, chameneos, &col);
  }
  pthread_join(mid, NULL);
}
