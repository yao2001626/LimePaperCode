#define _GNU_SOURCE 
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <sys/time.h>

typedef struct PriorityQueue {
    pthread_mutex_t lock;
    pthread_cond_t cv;
    struct PriorityQueue *next;
    int a, r, m, p;
    int num_actions;
    int (*actions[2])(void *); 
}PriorityQueue;

int pq_doAdd(void * self);
int pq_doRemove(void *self);
void * pq_doActions(void * self);

void *pq_init() {
    
    pthread_t thread_id;
    PriorityQueue * pq = (PriorityQueue *)malloc(sizeof(PriorityQueue));
    if(pq == NULL) {
        printf("Creat priority queue failed\n");
        exit(1);
    }
    pthread_mutex_init(&pq->lock, 0);
    pthread_cond_init(&pq->cv, 0);
    pq->next = NULL;
    pq->a = 0;
    pq->r = 0;
    pq->m = 0;
    pq->p = 0;
    pq->num_actions = 2; 
    pq->actions[0] = pq_doAdd;
    pq->actions[1] = pq_doRemove;
    
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    pthread_create(&thread_id, &attr, pq_doActions, (void *)pq);
    return pq;
}

int pq_empty(PriorityQueue * self) {
    int tmp;
    pthread_mutex_lock(&self->lock);
    while(self->r) {
        pthread_cond_wait(&self->cv, &self->lock);
    }
    tmp = (self->next == NULL);
    pthread_mutex_unlock(&self->lock);
    return tmp;
}

int pq_remove(PriorityQueue * self) {
    int tmp;
    pthread_mutex_lock(&self->lock);
    while(self->a || self->r) {
        pthread_cond_wait(&self->cv, &self->lock);
    }
    self->r = 1;
    pthread_cond_signal(&self->cv);
    tmp = self->m;
    pthread_mutex_unlock(&self->lock);
    return tmp;
}

void pq_add(int e, PriorityQueue * self) {
    // when not a 
    pthread_mutex_lock(&self->lock);
    while(self->a || self->r) {
        pthread_cond_wait(&self->cv, &self->lock);
    }
    if(self->next == NULL) {
        self->m = e;
        self->next = pq_init();
    } else {
        self->p = e;
        self->a = 1;
        //pthread_cond_signal(&self->cv);
    }
    pthread_mutex_unlock(&self->lock);
}

int pq_doAdd(void * self) {
    //when a do
    int done;
    PriorityQueue *this = (PriorityQueue *)self;
    if(this->a) {    
        if(this->m < this->p) {  
            pq_add(this->p, this->next);
        } else {
            
            pq_add(this->m, this->next);
            this->m = this->p;
        }
        this->a = 0;
        pthread_cond_signal(&this->cv);
        done = 1;
    }else{
        done = 0;
    }   
    return done;
}

int pq_doRemove(void * self) {
    int done;
    PriorityQueue *this = (PriorityQueue *)self;
    if(this->r) {    
        if(pq_empty(this->next)){
            this->next = NULL;
        } else {
            this->m = pq_remove(this->next);
        }
        this->r = 0;
        pthread_cond_signal(&this->cv);
        done = 1;
    } else {
        done = 0;
    }   
    return done;
}

void * pq_doActions(void * self) {
    int i = 0, done = 0;
    PriorityQueue *this = (PriorityQueue *)self;
    while(1) {
        pthread_mutex_lock(&this->lock);
        for(i = 0; i < this->num_actions; i++)
            done += this->actions[i](this);
        pthread_mutex_unlock(&this->lock);
        //yield to the scheduler
        pthread_yield();
    }
    return NULL;
}


int main(int argc, char* argv[]){
    if(argc < 3){
        printf("The Usage: %s num inputdata_dir \n", argv[0]);
        exit(1);
    }
    char *dir = argv[2];
    char filename[100];
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    snprintf(filename, 100, "%s/%s", dir, argv[1]);
    int num = atoi(argv[1]);
    //printf("%s\n", filename);
    FILE *file = fopen(filename, "r");
    if (file == NULL) exit(EXIT_FAILURE);
    int *input = (int *)malloc(sizeof(int) * num);
    int i = 0;
    while ((read = getline(&line, &len, file)) != -1) {
        //printf("Retrieved line of length %zu :\n", read);
        //printf("%s", line);
        input[i] = atoi(line);
        i++;
    }
    fclose(file);
    
    PriorityQueue * head = (PriorityQueue *)pq_init();
    for (i = 0; i < num; i++) {
        pq_add(input[i], head);
    }
    
    for (i = 0; i < num; i++){
        pq_remove(head);
        //printf("%d\n",remove_pq(pq));
    }   
    return 0;
}