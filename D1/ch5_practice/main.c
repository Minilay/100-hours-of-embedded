#include<stdio.h>

void handler0(){
    printf("Handler 0 fired\n");
}

void handler1(){
    printf("Handler 1 fired\n");
}

void handler2(){
    printf("Handler 2 fired\n");
}

void handler3(){
    printf("Handler 3 fired\n");
}

void (*vector_table[4])(void) = {handler0, handler1, handler2, handler3};

void dispatch(int irq) {
    (*(vector_table + irq))();
}

void relocate_vector(int irq, void (*new_handler)(void)) {
    (*(vector_table + irq)) = new_handler;
}

int main(){
    dispatch(2);
    relocate_vector(2, handler0);
    dispatch(2);
}