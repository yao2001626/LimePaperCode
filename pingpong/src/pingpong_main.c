#include <stdio.h>
#include <stdlib.h>
;
;
extern int argc_g;
extern char ** argv_g;
int * input;
int getRand(int);
void setRand(int);
void print(int x);
int getArg(int);
void lime_main(void * self);
void print(int x){
	// This is the default built-in function: print
	printf("%d\n", x);
	return;
}
int getArg(int index){
	// This is the default built-in function: getArg
	// System global variables: int argc_g, char **argv_g
	return atoi(argv_g[index]);
}
void setRand(int num){
    char *dir = argv_g[2];
	 char filename[100];
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    //snprintf(filename, 100, "%s/%s", dir, argv_g[1]);
    snprintf(filename, 100, "%s", dir);
    FILE *file= fopen(filename, "r");
    if (file == NULL) exit(EXIT_FAILURE);
    input = (int *)malloc(sizeof(int)*num);
    int i = 0;
    while ((read = getline(&line, &len, file)) != -1) {
        input[i]=atoi(line);
        i++;
    }
    fclose(file);
}
int getRand(int index){
	return input[index];
}
void lime_main(void * self){
void * ping;

void * pong;

int tokens;

tokens = getArg(1);
pong = (void *)Pong_init();
ping = (void *)Ping_init(pong, tokens);

}