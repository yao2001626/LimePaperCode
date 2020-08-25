#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
struct Ping_struct{
int pre_ebp;
int pre_esp;
int lock;
int system_next;
struct Pong_struct *other;
int bounces;
};
void  Pong_pong(struct Ping_struct *,int, struct Pong_struct *, void*);
void Ping_ping(int b,struct Ping_struct *this, void* self){
this->bounces = b;
}

void Ping_pong(struct Ping_struct *this, void* self)
{
Pong_pong(this, this->bounces - 1,this->other, self);this->bounces = 0;
}
