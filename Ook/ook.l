%{
#include "y.tab.h"
#include <string.h>

int first_part = 0;
int type1 = 0; /* 1 for '.', 2 for '?', 3 for '!' */
%}

%%

"Ook."|"Ook?"|"Ook!" {
    int current_type = (yytext[3] == '.') ? 1 : (yytext[3] == '?') ? 2 : 3;

    if (!first_part) {
        first_part = 1;
        type1 = current_type;
    } else {
        first_part = 0;
        if (type1 == 1 && current_type == 2) return GT;
        if (type1 == 2 && current_type == 1) return LT;
        if (type1 == 1 && current_type == 1) return PLUS;
        if (type1 == 3 && current_type == 3) return MINUS;
        if (type1 == 3 && current_type == 1) return DOT;
        if (type1 == 1 && current_type == 3) return COMMA;
        if (type1 == 3 && current_type == 2) return LBRACK;
        if (type1 == 2 && current_type == 3) return RBRACK;
        if (type1 == 2 && current_type == 2) ; /* NOOP: Do nothing */
    }
}

[ \t\r\n]+     ;
.              ;

%%
int yywrap(void) { return 1; }
