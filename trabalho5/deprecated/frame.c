#include "frame.h"

struct frame {
    int mem[MEM_SIZE];
    int free_mem_index;
    Frame* previous;
};

struct frame_stack {
    Frame* top;
};

Frame* new_frame() {
    Frame* frame = (Frame*) malloc(sizeof(Frame));
    memset(frame->mem, 0, sizeof(int) * MEM_SIZE);
    frame->free_mem_index = 0;
    frame->previous = NULL;
    return frame;
}

int get_free_mem_index(Frame* frame) {
    return frame->free_mem_index;
}

void seek_mem_index(Frame* frame, int index) {
    frame->free_mem_index += index;
    
    if (frame->free_mem_index > (MEM_SIZE + 1)) {
        printf("ERR::STACK OVERFLOW");
        exit(EXIT_FAILURE);
    }
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

Frame* peek_frame(FrameStack* stack) {
    Frame* top = stack->top;
    return top;
}