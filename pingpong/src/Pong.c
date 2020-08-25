#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
struct Pong_struct{
int pre_ebp;
int pre_esp;
int lock;
int system_next;
struct Ping_struct *other;
int bounces;
};
void  Ping_ping(int, struct Ping_struct *, void*);
void Pong_pong(struct Ping_struct *o,int b,struct Pong_struct *this, void* self){
this->other = o;
this->bounces = b;
}

void Pong_ping(struct Pong_struct *this, void* self)
{
Ping_ping(this->bounces,this->other, self);this->bounces = 0;
}
