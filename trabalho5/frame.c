#include "frame.h"

struct frame {
    int mem[MEM_SIZE];
    Frame* previous;
};

struct frame_stack {
    Frame* top;
};

Frame* new_frame() {
    Frame* frame = (Frame*) malloc(sizeof(Frame));
    memset(frame->mem, 0, sizeof(int) * 512);
    frame->previous = NULL;
    return frame;
}

void store_frame_val(Frame* frame, int addr, int val) {
   frame->mem[addr] = val;
}

int load_frame_val(Frame* frame, int addr) {
    return frame->mem[addr];
}

FrameStack* new_frame_stack() {
    FrameStack* stack = (FrameStack*) malloc(sizeof(FrameStack));
    stack->top = NULL;
    return stack;
}

int has_previous_frame(Frame* frame) {
    return frame->previous != NULL;
}

void push_frame(FrameStack* stack, Frame* frame) {
    frame->previous = stack->top;
    stack->top = frame;
}

Frame* pop_frame(FrameStack* stack) {
    Frame* top = stack->top;
    stack->top = top->previous;
    return top;
}