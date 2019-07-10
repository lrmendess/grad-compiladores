#ifndef FRAME_H
#define FRAME_H

#include <stdlib.h>
#include <string.h>

#define MEM_SIZE 1024

struct frame;
typedef struct frame Frame;

struct frame_stack;
typedef struct frame_stack FrameStack;

int load_frame_val(Frame* frame, int addr);
int has_previous_frame(Frame* frame);

void store_frame_val(Frame* frame, int addr, int val);
void push_frame(FrameStack* stack, Frame* frame);

Frame* new_frame();
Frame* pop_frame(FrameStack* stack);

FrameStack* new_frame_stack();

#endif