#define _GNU_SOURCE 
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>

typedef struct Node {
    pthread_mutex_t lock;
    pthread_cond_t cv;
    int key, p, a; 
    struct Node *left;
    struct Node *right;
    int num_actions;
    void (*actions[1])(void *); 
}node_t;

void * LOT_doActions(void * self);
void LOT_doAdd(void * this);

struct Node * LOT_init(int x) {
    pthread_t thread_id;
    struct Node * tmp = (struct Node *)malloc(sizeof(struct Node));
    if(tmp == NULL) {
        printf("Create Node failed\n");
        exit(1);
    }
    pthread_mutex_init(&tmp->lock, 0);
    pthread_cond_init(&tmp->cv, 0);
    tmp->key = x;
    tmp->left = NULL;
    tmp->right = NULL;
    tmp->a = 0;
    tmp->num_actions = 1;
    tmp->actions[0] = LOT_doAdd;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    pthread_create(&thread_id, &attr, LOT_doActions, (void *)tmp);
    return tmp;   
}

void LOT_add(int x, struct Node * self) {
    pthread_mutex_lock(&self->lock);
    while(self->a) {
        pthread_cond_wait(&self->cv, &self->lock);
    }
    if(self->left != NULL) {
        self->a = 1;
        self->p = x;
    } else if(x < self->key) {
        self->left = LOT_init(x);
        self->right = LOT_init(self->key);
        self->key = x;
    } else if(x > self->key) {
        self->left = LOT_init(self->key);
        self->right = LOT_init(x);
    }
    pthread_mutex_unlock(&self->lock);
}

int LOT_has(int x, struct Node * self) {
    int ret=0;
    pthread_mutex_lock(&self->lock);
    while(self->a) {
        pthread_cond_wait(&self->cv, &self->lock);
    }
    if(self->left == NULL) {
        ret = (x == self->key);
    } else if(x <= self->key) {
        ret = LOT_has(x, self->left);
    } else {
        ret = LOT_has(x, self->right);
    }
    pthread_mutex_unlock(&self->lock);
    return ret;
}

void LOT_doAdd(void * self) {
    struct Node * this = (struct Node *)self;
    if(this->a) {
        if(this->p <= this->key) {
            LOT_add(this->p, this->left);
        } else {
            LOT_add(this->p, this->right);
        }
        this->a = 0;
        pthread_cond_signal(&this->cv);
    }
}

void * LOT_doActions(void * self) {
    struct Node * this = (struct Node *)self;
    while(1) {
        pthread_mutex_lock(&this->lock);
        for(int i = 0; i < this->num_actions; i++)
            this->actions[i](this);
        //pthread_cond_signal(&this->cv);
        pthread_mutex_unlock(&this->lock);
        pthread_yield();
    }
    return NULL;
}

int main(int argc, char* argv[]){
    if(argc < 3){
        printf("The Usage: %s pq_num inputdir\n", argv[0]);
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

    struct Node * root = LOT_init(5000);
    
    for(i = 0; i < num; i++) {
        //printf("add %d\n", input[i]);
        LOT_add(input[i], root);
    }

    for(i = 0; i < num; i++) {
        //printf("search %d\n", input[i]);
        if(LOT_has(input[i], root) == 0) {
            //printf("add %d\n", input[i]);
            LOT_add(input[i], root);
        }
    }
    free(root);
    return 0;
}
