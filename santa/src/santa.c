#include <stdio.h>
#include <stdbool.h>
#include <pthread.h>
#include <semaphore.h>
#define P(sem)  (sem_wait(&(sem)))  /* uses P and V for the wait and ... */
#define V(sem)  (sem_post(&(sem)))  /* ... signal semaphore operations */

sem_t wakeup, wakeupReindeer, wakeupElves;
sem_t harness, harnessDone;
sem_t pull, pullDone;
sem_t enter, enterDone;
sem_t consult, consultDone;
sem_t reindeerBack, reindeerBackDone;
sem_t reindeerHarness, reindeerHarnessDone;
sem_t reindeerPull, reindeerPullDone;
sem_t elfPuzzled, elfPuzzledDone;
sem_t elfEnter, elfEnterDone;
sem_t elfConsult, elfConsultDone;

bool b;

void *Santa(void *arg) {
    for (int t = 0; t < 100000; t++) { // Sleeping
        // printf("Santa sleeping\n");
        P(wakeup); // woken up by Sleigh or Shop
        if (b) { // Delivering
            b = false; V(wakeupReindeer);
            // printf("Santa harnessing\n");
            P(harness); V(harnessDone);
            // printf("Santa riding\n");
            P(pull); V(pullDone);
        } else { // Helping
            V(wakeupElves);
            for (int i = 0; i < 3; i++) {
                // printf("Santa welcoming\n");
                P(enter); V(enterDone);
                // printf("Santa explaining\n");
                P(consult); V(consultDone);
            }
        }
    }
}
void *Sleigh(void *arg) {
    for (;;) {
        for (int i = 0; i < 9; i++) V(reindeerBack);
        for (int i = 0; i < 9; i++) P(reindeerBackDone);
        // printf("9 reindeer back\n");
        b = true; V(wakeup); P(wakeupReindeer);
        // printf("9 reindeer stating to harness\n");
        for (int i = 0; i < 9; i++) V(reindeerHarness);
        for (int i = 0; i < 9; i++) P(reindeerHarnessDone);
        // printf("9 reindeer done harnessing\n");
        V(harness); P(harnessDone);
        // printf("9 reindeer stating to pull\n");
        for (int i = 0; i < 9; i ++) V(reindeerPull);
        for (int i = 0; i < 9; i ++) P(reindeerPullDone);
        // printf("9 reindeer done pulling\n");
        V(pull); P(pullDone);
        // printf("Sleigh starting over\n");
    }
}
void *Reindeer(void *arg) {
    for (int t = 0; t < 20000; t++) {
        P(reindeerBack); V(reindeerBackDone);
        P(reindeerHarness); V(reindeerHarnessDone);
        P(reindeerPull); V(reindeerPullDone);
    }
}
void *Shop(void *arg) {
    for (;;) {
        for (int i = 0; i < 3; i++) V(elfPuzzled);
        for (int i = 0; i < 3; i++) P(elfPuzzledDone);
        // printf("3 elves puzzled\n");
        V(wakeup); P(wakeupElves);
        for (int i = 0; i < 3; i++) {
            V(elfEnter); P(elfEnterDone);
            // printf("1 elf entered\n");
            V(enter); P(enterDone);
            V(elfConsult); P(elfConsultDone);
            // printf("1 elf consulting\n");
            V(consult); P(consultDone);
        }
    }
}
void *Elf(void *arg) {
    for (;;) {
        P(elfPuzzled); V(elfPuzzledDone);
        P(elfEnter); V(elfEnterDone);
        P(elfConsult); V(elfConsultDone);
    }
}
void main() {
    sem_init(&wakeup, 0, 0); sem_init(&wakeupReindeer, 0, 0); sem_init(&wakeupElves, 0, 0);
    sem_init(&harness, 0, 0); sem_init(&harnessDone, 0, 0);
    sem_init(&pull, 0, 0); sem_init(&pullDone, 0, 0);
    sem_init(&enter, 0, 0); sem_init(&enterDone, 0, 0);
    sem_init(&consult, 0, 0); sem_init(&consultDone, 0, 0);
    sem_init(&reindeerBack, 0, 0); sem_init(&reindeerBackDone, 0, 0);
    sem_init(&reindeerHarness, 0, 0); sem_init(&reindeerHarnessDone, 0, 0);
    sem_init(&reindeerPull, 0, 0); sem_init(&reindeerPullDone, 0, 0);
    sem_init(&elfPuzzled, 0, 0); sem_init(&elfPuzzledDone, 0, 0);
    sem_init(&elfEnter, 0, 0); sem_init(&elfEnterDone, 0, 0);
    sem_init(&elfConsult, 0, 0); sem_init(&elfConsultDone, 0, 0);
    pthread_t tid;
    for (int i = 0; i < 9; i++) pthread_create(&tid, NULL, Reindeer, NULL);
    for (int i = 0; i < 20; i++) pthread_create(&tid, NULL, Elf, NULL);
    pthread_create(&tid, NULL, Sleigh, NULL); pthread_create(&tid, NULL, Shop, NULL);
    pthread_create(&tid, NULL, Santa, NULL); pthread_join(tid, NULL);
}