#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
struct Node_struct{
int pre_ebp;
int pre_esp;
int lock;
int system_next;
struct Node_struct *next;
int token;
};
void  Node_pass(int, struct Node_struct *, void*);
void Node_pass(int t,struct Node_struct *this, void* self){
this->token = t;
}
void Node_setNext(struct Node_struct *n,struct Node_struct *this, void* self){
this->next = n;
}

void Node_forward(struct Node_struct *this, void* self)
{
Node_pass(this->token - 1,this->next, self);this->token = 0;
}
