#define _GNU_SOURCE 
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <sys/time.h>

typedef struct Reducer {
    pthread_mutex_t lock;
    pthread_cond_t cv;
    int index, a1, a2, e1, e2;
    struct Reducer *next;
    int num_actions;
    void (*actions[1])(void *);
}reducer_t;

typedef struct Mapper {
    pthread_mutex_t lock;
    pthread_cond_t cv;
    int index, e, a;
    struct Reducer *next;
    int num_actions;
    void (*actions[1])(void *);
}mapper_t;

typedef struct Tree {
    mapper_t ** m;
    reducer_t ** r;
}tree_t;

void Reducer_doReduce(void * this);
void Mapper_doMap(void * this);
void * Reducer_doActions(void * self);
void * Mapper_doActions(void * self);

struct Reducer * Reducer_init(int e) {
    pthread_t thread_id;
    struct Reducer *tmp = (struct Reducer *)malloc(sizeof(struct Reducer));
    if(tmp == NULL){
        printf("Create reducer failed\n");
        exit(1);
    }
    //printf("creating reducer %p lock %p\n", tmp, &tmp->lock );
    pthread_mutex_init(&tmp->lock, 0);
    pthread_cond_init(&tmp->cv, 0);
    tmp->index = e;
    tmp->a1 = 0;
    tmp->a2 = 0;
    tmp->e1 = 0;
    tmp->e2 = 0;
    tmp->next = NULL;
    tmp->num_actions = 1;
    tmp->actions[0] = Reducer_doReduce;

    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    pthread_create(&thread_id, &attr, Reducer_doActions, (void *)tmp);
    //printf("Thread is created\n");
    return tmp;
}

struct Mapper * Mapper_init(int e) {
    pthread_t thread_id;
    struct Mapper * tmp = (struct Mapper *)malloc(sizeof(struct Mapper));
    if(tmp == NULL) {
        printf("Create mapper failed\n");
        exit(1);
    }
    //printf("creating mapper %p lock %p\n", tmp, &tmp->lock );
    pthread_mutex_init(&tmp->lock, 0);
    pthread_cond_init(&tmp->cv, 0);
    tmp->index = e;
    tmp->e = 0;
    tmp->a = 0;
    tmp->next = NULL;
    tmp->num_actions = 1;
    tmp->actions[0] = Mapper_doMap;

    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    pthread_create(&thread_id, &attr, Mapper_doActions, (void *)tmp);
    //printf("Thread is created\n");
    return tmp;
}

void Reducer_reduce1(int e, struct Reducer * self) {
    pthread_mutex_lock(&self->lock);
    while(self->a1) {
        pthread_cond_wait(&self->cv, &self->lock);
    }
    self->e1 = e;
    self->a1 = 1;
    pthread_mutex_unlock(&self->lock);
}

void Reducer_reduce2(int e, struct Reducer *self) {
    pthread_mutex_lock(&self->lock);
    while(self->a2) {
        pthread_cond_wait(&self->cv, &self->lock);
    }
    self->e2 = e;
    self->a2 = 1;
    pthread_mutex_unlock(&self->lock);
}

void Reducer_doReduce(void * this) {
    struct Reducer *self = (struct Reducer *)this;
    if(self->a1 && self->a2) {
        if(self->index == 1) {
            //printf("result %d\n", self->e1+self->e2);
            self->e1 = 0;
            self->e2 = 0;
        } else {
            if(self->index % 2 == 0) {
                Reducer_reduce1(self->e1 + self->e2, self->next);
            } else {
                Reducer_reduce2(self->e1 + self->e2, self->next);
            }
        }
        self->a1 = 0;
        self->a2 = 0;
        //pthread_cond_signal(&self->cv);
        pthread_cond_broadcast(&self->cv);
    }
}

void * Reducer_doActions(void * self) {
    int i = 0;
    struct Reducer *this = (struct Reducer *)self;
    while(1) {
        pthread_mutex_lock(&this->lock);
        for(i = 0; i < this->num_actions; i++)
            this->actions[i](this);
        pthread_mutex_unlock(&this->lock);
        //yield to the scheduler
        pthread_yield();
    }
    return NULL;
}

void Mapper_map(int e, struct Mapper * self) {
    pthread_mutex_lock(&self->lock);
    while(self->a) {
        pthread_cond_wait(&self->cv, &self->lock);
    }
    self->e = e;
    self->a = 1;
    pthread_mutex_unlock(&self->lock);
}

void Mapper_doMap(void * self) {
    struct Mapper * this = (struct Mapper *)self;
    if(this->a) {
        if(this->index % 2 == 0) {
            Reducer_reduce1(this->e * this->e, this->next);
        } else {
            Reducer_reduce2(this->e * this->e, this->next);
        }
        this->a = 0;
        pthread_cond_signal(&this->cv);
    }
}

void * Mapper_doActions(void * self) {
    int i;
    struct Mapper * this = (struct Mapper *)self;
    while(1) {
        pthread_mutex_lock(&this->lock);
        for(i = 0; i < this->num_actions; i++)
            this->actions[i](this);
        pthread_mutex_unlock(&this->lock);
        //yield to the scheduler
        pthread_yield();
    }
    return NULL;
}

tree_t * tree_init(int object_num) {
    tree_t * n = (tree_t *) malloc (sizeof(tree_t));
    n->m = (mapper_t **)malloc(sizeof(mapper_t *) * object_num);
    n->r = (reducer_t **)malloc(sizeof(reducer_t *) * object_num);

    n->m[0] = (mapper_t *)Mapper_init(0);

    for(int i = 1; i < object_num; ++i) {
        n->m[i] = (mapper_t *)Mapper_init(i);
        n->r[i] = (struct Reducer *)Reducer_init(i);
    }

    for(int i = 1; i < object_num / 2; ++i) {
        n->r[i * 2]->next = n->r[i];
        n->r[i * 2 + 1]->next = n->r[i];
    }

    for(int i = 0; i < object_num; ++i) {
        n->m[i]->next = n->r[(i + object_num) / 2];
    }

    return n;
}


int main(int argc, char* argv[]){
    if(argc < 3){
        printf("The Usage: %s num repeat\n", argv[0]);
        exit(1);
    }
    int i;
    int num = atoi(argv[1]);
    int repeat = atoi(argv[2]);
    //printf("before init_tree\n");
    tree_t *t = tree_init(num);
    while(repeat > 0){
        for(i = 0; i < num; i++) {
            Mapper_map(i, t->m[i]);
            //printf("i %d\n", i);
        }
        //printf("round: %d\n", repeat);
        repeat--;
    }
    //free
    free(t);
    return 0;
}
