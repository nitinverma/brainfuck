%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>   /* getopt, fdopen */

FILE *in;             /* input stream for ',' */
int trace_enabled = 0;

void yyerror(const char *s);
int yylex(void);
%}

%code requires {
    struct instr {
        int op;
        struct instr *next;
        struct instr *body;
    };
    typedef struct instr instr;

    typedef struct {
        instr *head;
        instr *tail;
    } instr_list;
}

%union {
    struct instr *ip;
    instr_list list;
}

%{
#define MEM_SIZE 30000
instr *program = NULL;

instr *make_instr(int op);
instr *make_loop(instr *body);
void exec(instr *p, unsigned char *mem, int *ptr);
void free_tree(instr *p);

/* Helper for trace labels */
const char* op_to_str(int op);
%}

%token GT LT PLUS MINUS DOT COMMA LBRACK RBRACK
%type <ip> instr
%type <list> instrs

%%

program
    : instrs { program = $1.head; }
    ;

instrs
    : instrs instr { 
        $$.head = $1.head;
        if ($1.tail) {
            $1.tail->next = $2;
            $$.tail = $2;
        } else {
            $$.head = $$.tail = $2;
        }
    }
    | /* empty */ { $$.head = $$.tail = NULL; }
    ;

instr
    : GT     { $$ = make_instr(GT); }
    | LT     { $$ = make_instr(LT); }
    | PLUS   { $$ = make_instr(PLUS); }
    | MINUS  { $$ = make_instr(MINUS); }
    | DOT    { $$ = make_instr(DOT); }
    | COMMA  { $$ = make_instr(COMMA); }
    | LBRACK instrs RBRACK { $$ = make_loop($2.head); }
    ;

%%

instr *make_instr(int op) {
    instr *p = calloc(1, sizeof(instr));
    if (!p) { perror("malloc"); exit(1); }
    p->op = op;
    return p;
}

instr *make_loop(instr *body) {
    instr *p = make_instr(LBRACK);
    p->body = body;
    return p;
}

const char* op_to_str(int op) {
    switch(op) {
        case GT: return ">"; case LT: return "<";
        case PLUS: return "+"; case MINUS: return "-";
        case DOT: return "."; case COMMA: return ",";
        case LBRACK: return "["; default: return "?";
    }
}

void exec(instr *p, unsigned char *mem, int *ptr) {
    while (p) {
        if (trace_enabled) {
             printf("[TRACE] Op: %s | Ptr: %d | Val: %d\n", op_to_str(p->op), *ptr, mem[*ptr]);
        }
        switch (p->op) {
            case GT:    (*ptr)++; if (*ptr >= MEM_SIZE) *ptr = 0; break;
            case LT:    (*ptr)--; if (*ptr < 0) *ptr = MEM_SIZE - 1; break;
            case PLUS:  mem[*ptr]++; break;
            case MINUS: mem[*ptr]--; break;
            case DOT:   
                putchar(mem[*ptr]); 
                fflush(stdout); /* CRITICAL: Force character to terminal */
                break;
            case COMMA: {
                int c = fgetc(in);
                mem[*ptr] = (c == EOF) ? 0 : (unsigned char)c;
                if (trace_enabled) {
                    printf("[TRACE] Op: , | Ptr: %d | Raw: %d | Stored: %u\n",*ptr, c, mem[*ptr]);
                }
                break;
            }
            case LBRACK:
                while (mem[*ptr]) exec(p->body, mem, ptr);
                break;
        }
        p = p->next;
    }
}

void free_tree(instr *p) {
    while (p) {
        instr *next = p->next;
        if (p->body) free_tree(p->body);
        free(p);
        p = next;
    }
}

void yyerror(const char *s) { fprintf(stderr, "Parse Error: %s\n", s); }

int main(int argc, char **argv) {
    int opt;
    int input_fd = 0;
    FILE *fp;

    /* Parse options */
    while ((opt = getopt(argc, argv, "ti:")) != -1) {
        switch (opt) {
        case 't':
            trace_enabled = 1;
            break;
        case 'i':
            input_fd = atoi(optarg);
            break;
        default:
            fprintf(stderr, "usage: %s [-t] [-i fd]\n", argv[0]);
            return 1;
        }
    }

    if (input_fd == 0) {
        in = stdin;
    } else {
        fp = fdopen(input_fd, "r");
        if (!fp) {
            perror("fdopen");
            return 1;
        }
        in = fp;
    }
    unsigned char *mem = calloc(MEM_SIZE, sizeof(unsigned char));
    int ptr = 0;

    if (yyparse() == 0) {
        if (program) {
            exec(program, mem, &ptr);
            free_tree(program);
            putchar('\n'); 
        }
    } else {
        fprintf(stderr, "Failed to parse Ook! program.\n");
    }
    
    free(mem);
    return 0;
}
