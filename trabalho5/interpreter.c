#include "interpreter.h"

extern LitTable* lit_table;

// Data stack -----------------------------------------------------------------

#define STACK_SIZE 512

int stack[STACK_SIZE];
int stack_pointer;

void push(int arg) {
    stack[++stack_pointer] = arg;
}

int pop() {
    return stack[stack_pointer--];
}

void new_stack() {
    memset(stack, 0, sizeof(int) * STACK_SIZE);
    stack_pointer = -1;
}

void print_stack() {
    printf("*** STACK: ");
    for (int i = 0; i <= stack_pointer; i++) {
        printf("%d ", stack[i]);
    }
    printf("\n");
}

// ----------------------------------------------------------------------------

// Variables memory -----------------------------------------------------------

#define MEM_SIZE 256

int mem[MEM_SIZE];

void store(int addr, int val) {
    mem[addr] = val;
}

int load(int addr) {
    return mem[addr];
}

void new_mem() {
    memset(mem, 0, sizeof(int) * MEM_SIZE);
}

// ----------------------------------------------------------------------------

// #define TRACE
#ifdef TRACE
#define trace(msg) printf("TRACE: %s\n", msg)
#else
#define trace(msg)
#endif

void rec_run_ast(AST *ast);

void run_if(AST* ast) {

}

void run_input(AST* ast) {

}

void run_output(AST* ast) {

}

void run_return(AST* ast) {

}

void run_while(AST* ast) {

}

void run_write(AST* ast) {
    trace("write");
    rec_run_ast(get_child(ast, 0));

    int index = pop();
    char* string = get_literal(lit_table, index);

    int len = strlen(string) - 1;

    for (int i = 1; i < len; i++) {
        if (string[i] == '\\' && (i + 1) < len) {
            if (string[++i] == 'n') {
                printf("\n");
            } else {
                printf("%c%c", string[i - 1], string[i]);
            }
        } else {
            printf("%c", string[i]);
        }
    }
}

#define bin_op() \
    rec_run_ast(get_child(ast, 0)); \
    rec_run_ast(get_child(ast, 1)); \
    int r = pop(); \
    int l = pop()

void run_plus(AST* ast) {

}

void run_minus(AST* ast) {

}

void run_times(AST* ast) {

}

void run_over(AST* ast) {

}

void run_lt(AST* ast) {

}

void run_le(AST* ast) {

}

void run_gt(AST* ast) {

}

void run_ge(AST* ast) {

}

void run_eq(AST* ast) {

}

void run_neq(AST* ast) {

}

void run_assign(AST* ast) {

}

void run_block(AST* ast) {
    trace("block");
    int size = get_child_count(ast);

    for (int i = 0; i < size; i++) {
        AST* child = get_child(ast, i);
        rec_run_ast(child);
    }
}

void run_vdecl_list(AST* ast) {
    trace("vlist");
    int size = get_child_count(ast);

    for (int i = 0; i < size; i++) {
        AST* child = get_child(ast, i);
        rec_run_ast(child);
    }
}

void run_vdecl(AST* ast) {

}

void run_vuse(AST* ast) {

}

void run_flist(AST* ast) {
    trace("flist");
    int size = get_child_count(ast);

    for (int i = 0; i < size; i++) {
        AST* child = get_child(ast, i);
        rec_run_ast(child);
    }
}

void run_fdecl(AST* ast) {
    trace("fdecl");
    int size = get_child_count(ast);

    for (int i = 0; i < size; i++) {
        AST* child = get_child(ast, i);
        rec_run_ast(child);
    }
}

void run_fheader(AST* ast) {
    trace("fheader");
    int size = get_child_count(ast);

    for (int i = 0; i < size; i++) {
        AST* child = get_child(ast, i);
        rec_run_ast(child);
    }
}

void run_fbody(AST* ast) {
    trace("fbody");
    int size = get_child_count(ast);

    for (int i = 0; i < size; i++) {
        AST* child = get_child(ast, i);
        rec_run_ast(child);
    }
}

void run_fname(AST* ast) {

}

void run_plist(AST* ast) {

}

void run_fcall(AST* ast) {

}

void run_alist(AST* ast) {

}

void run_num(AST* ast) {

}

void run_string(AST* ast) {
    int index = get_data(ast);
    push(index);
}

void rec_run_ast(AST *ast) {
    switch(get_kind(ast)) {
        case IF_NODE:
            run_if(ast);
            break;
        case INPUT_NODE:
            run_input(ast);
            break;
        case OUTPUT_NODE:
            run_output(ast);
            break;
        case RETURN_NODE:
            run_return(ast);
            break;
        case WHILE_NODE:
            run_while(ast);
            break;
        case WRITE_NODE:
            run_write(ast);
            break;

        case PLUS_NODE:
            run_plus(ast);
            break;
        case MINUS_NODE:
            run_minus(ast);
            break;
        case TIMES_NODE:
            run_times(ast);
            break;
        case OVER_NODE:
            run_over(ast);
            break;
        case LT_NODE:
            run_lt(ast);
            break;
        case LE_NODE:
            run_le(ast);
            break;
        case GT_NODE:
            run_gt(ast);
            break;
        case GE_NODE:
            run_ge(ast);
            break;
        case EQ_NODE:
            run_eq(ast);
            break;
        case NEQ_NODE:
            run_neq(ast);
            break;
        case ASSIGN_NODE:
            run_assign(ast);
            break;

        case BLOCK_NODE:
            run_block(ast);
            break;
        case VDECL_LIST_NODE:
            run_vdecl_list(ast);
            break;
        case VDECL_NODE:
            run_vdecl(ast);
            break;
        case VUSE_NODE:
            run_vuse(ast);
            break;
        case FLIST_NODE:
            run_flist(ast);
            break;
        case FDECL_NODE:
            run_fdecl(ast);
            break;
        case FHEADER_NODE:
            run_fheader(ast);
            break;
        case FBODY_NODE:
            run_fbody(ast);
            break;
        case FNAME_NODE:
            run_fname(ast);
            break;
        case PLIST_NODE:
            run_plist(ast);
            break;
        case FCALL_NODE:
            run_fcall(ast);
            break;
        case ALIST_NODE:
            run_alist(ast);
            break;

        case NUM_NODE:
            run_num(ast);
            break;
        case STRING_NODE:
            run_string(ast);
            break;
            
        default:
            fprintf(stderr, "Invalid kind: %s!\n", kind2str(get_kind(ast)));
            exit(1);
    }
}

void run_ast(AST* ast) {
    new_stack();
    new_mem();
    rec_run_ast(ast);
}

// void run_stmt_seq(AST *ast) {
//     trace("stmt_seq");
//     int size = get_child_count(ast);
//     for (int i = 0; i < size; i++) {
//         rec_run_ast(get_child(ast, i));
//     }
// }
// 
// void run_if(AST *ast) {
//     trace("if");
//     rec_run_ast(get_child(ast, 0));
//     int test = pop();
//     if (test == 1) {
//         rec_run_ast(get_child(ast, 1));
//     } else if (test == 0 && get_child_count(ast) == 3) {
//         rec_run_ast(get_child(ast, 2));
//     }
// }
// 
// void run_repeat(AST *ast) {
//     trace("repeat");
//     int again = 1;
//     while (again) {
//         rec_run_ast(get_child(ast, 0)); // Run body.
//         rec_run_ast(get_child(ast, 1)); // Run test.
//         again = !pop();
//     }
// }
// 
// void run_assign(AST *ast) {
//     trace("assign");
//     rec_run_ast(get_child(ast, 1));
//     AST *child = get_child(ast, 0);
//     int var_idx = get_data(child);
//     store(var_idx, pop());
// }
// 
// void run_read(AST *ast) {
//     trace("read");
//     int x;
//     printf("read: ");
//     scanf("%d", &x);
//     AST *child = get_child(ast, 0);
//     int var_idx = get_data(child);
//     store(var_idx, x);
// }
// 
// void run_write(AST *ast) {
//     trace("write");
//     rec_run_ast(get_child(ast, 0));
//     int x = pop();
//     printf("write: %d\n", x);
// }
// 

/*
#define bin_op() \
    rec_run_ast(get_child(ast, 0)); \
    rec_run_ast(get_child(ast, 1)); \
    int r = pop(); \
    int l = pop()
*/

// void run_plus(AST *ast) {
//     trace("plus");
//     bin_op();
//     push(l + r);
// }
// 
// void run_minus(AST *ast) {
//     trace("minus");
//     bin_op();
//     push(l - r);
// }
// 
// void run_times(AST *ast) {
//     trace("times");
//     bin_op();
//     push(l * r);
// }
// 
// void run_over(AST *ast) {
//     trace("over");
//     bin_op();
//     push((int) l / r);
// }
// 
// void run_lt(AST *ast) {
//     trace("lt");
//     bin_op();
//     push(l < r);
// }
// 
// void run_eq(AST *ast) {
//     trace("eq");
//     bin_op();
//     push(l == r);
// }
// 
// void run_num(AST *ast) {
//     trace("num");
//     push(get_data(ast));
// }
// 
// void run_id(AST *ast) {
//     trace("id");
//     int var_idx = get_data(ast);
//     push(load(var_idx));
// }
// 
// void rec_run_ast(AST *ast) {
//     switch(get_kind(ast)) {
//         case BLOCK_NODE:
//             run_stmt_seq(ast);
//             break;
//         case IF_NODE:
//             run_if(ast);
//             break;
//         case WHILE_NODE:
//             run_repeat(ast);
//             break;
//         case ASSIGN_NODE:
//             run_assign(ast);
//             break;
//         case INPUT_NODE:
//             run_read(ast);
//             break;
//         case WRITE_NODE:
//             run_write(ast);
//             break;
//         case PLUS_NODE:
//             run_plus(ast);
//             break;
//         case MINUS_NODE:
//             run_minus(ast);
//             break;
//         case TIMES_NODE:
//             run_times(ast);
//             break;
//         case OVER_NODE:
//             run_over(ast);
//             break;
//         case LT_NODE:
//             run_lt(ast);
//             break;
//         case EQ_NODE:
//             run_eq(ast);
//             break;
//         case NUM_NODE:
//             run_num(ast);
//             break;
//         case ID_NODE:
//             run_id(ast);
//             break;
//         default:
//             fprintf(stderr, "Invalid kind: %s!\n", kind2str(get_kind(ast)));
//             exit(1);
//     }
// }
// 
// void run_ast(AST *ast) {
//     init_stack();
//     init_mem();
//     rec_run_ast(ast);
// }
