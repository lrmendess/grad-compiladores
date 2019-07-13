#include "interpreter.h"

extern LitTable* lit_table;
extern VarTable* var_table;
extern FuncTable* func_table;

// Data stack -----------------------------------------------------------------

#define DATA_STACK_SIZE 512

int stack[DATA_STACK_SIZE];
int sp;

/*
 * Insere um valor no topo da pilha
 */
void push(int arg) {
    stack[++sp] = arg;
}

/*
 * Retorna o valor do topo da pilha
 */
int pop() {
    return stack[sp--];
}

/*
 * Inicializa a pilha de dados
 */
void new_stack() {
    memset(stack, 0, sizeof(int) * DATA_STACK_SIZE);
    sp = -1;
}

// Frame stack ----------------------------------------------------------------

#define FRAME_STACK_SIZE 2048

int fstack[FRAME_STACK_SIZE];
int ftop;
int fbase;

/*
 * Inicializa a pilha de frames
 */
void new_fstack() {
    memset(fstack, 0, sizeof(int) * FRAME_STACK_SIZE);
    ftop = 0;
    fbase = 0;
}

// Interpreter ----------------------------------------------------------------

// #define TRACE
#ifdef TRACE
#define trace(msg) printf("TRACE: %s\n", msg)
#else
#define trace(msg)
#endif

void rec_run_ast(AST *ast);

void run_if(AST* ast) {
    trace("if");

    // Empilhamento do resultado da condicao do if
    rec_run_ast(get_child(ast, 0));
    int boolean_value = pop();
    int child_count = get_child_count(ast);

    if (boolean_value) {
        rec_run_ast(get_child(ast, 1));
    // Tratamento do caso onde possa ou nao existir um else
    } else if (child_count == 3) {
        rec_run_ast(get_child(ast, 2));
    }
}

void run_input(AST* ast) {
    trace("input");

    int temp;
    scanf("%d", &temp);
    printf("input: %d\n", temp);
    push(temp);
}

void run_output(AST* ast) {
    trace("output");

    rec_run_ast(get_child(ast, 0));
    int arg = pop();

    printf("%d", arg);
}

void run_return(AST* ast) {
    trace("return");

    rec_run_ast(get_child(ast, 0));
}

void run_while(AST* ast) {
    trace("while");

    // Empilha o booleano referente a condicao do while
    rec_run_ast(get_child(ast, 0));
    int boolean_value = pop();

    while (boolean_value) {
        // Executa o bloco do while
        rec_run_ast(get_child(ast, 1));
        // Reavalia a condicao do while
        rec_run_ast(get_child(ast, 0));
        boolean_value = pop();
    }
}

void run_write(AST* ast) {
    trace("write");
    rec_run_ast(get_child(ast, 0));

    int index = pop();
    char* string = get_literal(lit_table, index);

    int len = strlen(string) - 1;

    // Tratamento das aspas e quebras linha
    for (int i = 1; i < len; i++) {
        if (string[i] == '\\' && (i + 1) < len) {
            if (string[i + 1] == 'n') {
                printf("\n"); i++;
            } else {
                printf("%c", string[i]);
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
    trace("plus");
    bin_op();
    push(l + r);
}

void run_minus(AST* ast) {
    trace("minus");
    bin_op();
    push(l - r);
}

void run_times(AST* ast) {
    trace("times");
    bin_op();
    push(l * r);
}

void run_over(AST* ast) {
    trace("over");
    bin_op();
    push((int) l / r);
}

void run_lt(AST* ast) {
    trace("lt");
    bin_op();
    push(l < r);
}

void run_le(AST* ast) {
    trace("le");
    bin_op();
    push(l <= r);
}

void run_gt(AST* ast) {
    trace("gt");
    bin_op();
    push(l > r);
}

void run_ge(AST* ast) {
    trace("ge");
    bin_op();
    push(l >= r);
}

void run_eq(AST* ast) {
    trace("eq");
    bin_op();
    push(l == r);
}

void run_neq(AST* ast) {
    trace("neq");
    bin_op();
    push(l != r);
}

void run_assign(AST* ast) {
    trace("assign");

    // Reserva o valor apos o sinal de atribuicao
    rec_run_ast(get_child(ast, 1));
    int value = pop();

    AST* var_node = get_child(ast, 0);

    int var_index = get_data(var_node);
    int offset = get_var_offset(var_table, var_index);
    int var_size = get_var_size(var_table, var_index);

    // Caso seja uma referencia para um vetor de outro frame
    if (var_size == -1) {
        rec_run_ast(get_child(var_node, 0));
        int step = pop();
        // Na posicao de memoria fstack[offset] esta armazenado o offset
        // da primeira posicao do vetor apontado
        fstack[fstack[fbase + offset] + step] = value;
    // Caso seja um vetor local
    } else if (var_size > 0) {
        rec_run_ast(get_child(var_node, 0));
        int step = pop();
        fstack[fbase + offset + step] = value;
    // Caso seja apenas um inteiro local
    } else {
        fstack[fbase + offset] = value;
    }
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
    trace("vdecl");

    int var_index = get_data(ast);
    int var_size = get_var_size(var_table, var_index);

    // Eh setado o offset da variavel de acordo com o topo da pilha
    set_var_offset(var_table, var_index, ftop - fbase);

    // Atualizacao do topo de fstack de acordo com o tamanho da variavel
    if (var_size > 0) {
        ftop += var_size;
    } else {
        ftop++;
    }
}

void run_vuse(AST* ast) {
    trace("vuse");

    int index = get_data(ast);
    int offset = get_var_offset(var_table, index);
    int var_size = get_var_size(var_table, index);

    // Caso seja uma referencia para um vetor
    if (var_size == -1) {
        // Caso estejamos acessando algum valor desse vetor
        if (get_child_count(ast) > 0) {
            rec_run_ast(get_child(ast, 0));
            int step = pop();
            // Na posicao de memoria fstack[offset] esta armazenado o offset
            // da primeira posicao do vetor apontado
            push(fstack[fstack[fbase + offset] + step]);
        // Caso estejamos passando o vetor como referencia
        } else {
            push(fstack[fbase + offset]);
        }
    // Caso seja um vetor local
    } else if (var_size > 0) {
        // Caso estejamos acessando algum valor desse vetor
        if (get_child_count(ast) > 0) {
            rec_run_ast(get_child(ast, 0));
            int step = pop();
            push(fstack[fbase + offset + step]);
        // Caso estejamos passando o vetor local como referencia
        } else {
            push(fbase + offset);
        }
    // Caso seja apenas um inteiro local
    } else {
        push(fstack[fbase + offset]);
    }
}

void run_flist(AST* ast) {
    trace("flist");

    // Inicializacao do frame da main
    ftop = 0;
    fbase = 0;

    // Executa a main
    rec_run_ast(get_child(ast, get_child_count(ast) - 1));
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

    // Executa param_list para que os valores da chamada de funcao sejam
    // atribuidos as suas respectivas variaveis
    rec_run_ast(get_child(ast, 1));
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
    trace("fname");
}

void run_plist(AST* ast) {
    trace("plist");
    int size = get_child_count(ast);

    for (int i = size - 1; i >= 0; i--) {
        // Para cada parametro, uma variavel eh declarada
        AST* param = get_child(ast, i);
        rec_run_ast(param);

        // Com a variavel ja criada, podemos atualizar o valor na memoria
        int var_index = get_data(param);
        int offset = get_var_offset(var_table, var_index);

        // Este valor pode ser uma referencia para outra posicao de memoria ou nao
        fstack[fbase + offset] = pop();
    }
}

void run_fcall(AST* ast) {
    trace("fcall");

    // Executa o arg_list de fcall para empilhar os valores
    // passados como parametro para a funcao chamada
    AST* arg_list = get_child(ast, 0);
    rec_run_ast(arg_list);

    // Criamos um novo frame para nova chamada de funcao
    fstack[ftop] = fbase;
    fbase = ftop++;

    int index = get_data(ast);
    AST* func_ast = get_func_ast(func_table, index);

    // Executa efetivamente a funcao e causa os efeitos colaterais necessarios
    rec_run_ast(func_ast);

    // Ao fim da execucao da funcao, podemos voltar para o frame anterior
    ftop = fbase;
    fbase = fstack[fbase];
}

void run_alist(AST* ast) {
    trace("alist");
    int size = get_child_count(ast);

    for (int i = 0; i < size; i++) {
        AST* child = get_child(ast, i);
        rec_run_ast(child);
    }
}

void run_num(AST* ast) {
    trace("num");
    int num = get_data(ast);

    push(num);
}

void run_string(AST* ast) {
    trace("string");
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
    new_fstack();
    rec_run_ast(ast);
}
