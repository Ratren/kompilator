%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
int yyerror(const char* msg);
extern int yylineno;
extern char* yytext;


%}

%define parse.error verbose

%union {
  int ival;
  char* sval;
}

%token T_INT MAIN F_IF F_ELSE F_WHILE F_THEN F_PRINT F_READ F_STOP EQUALS F_END
%token <sval> COMPARATOR BINARY_OP OPERATOR NAME NOT_OP STRING
%token <ival> IVAL

%type <sval> expression value condition operand Instructions Instruction ifelsestop

%left OPERATOR
%left COMPARATOR
%left BINARY_OP
%right NOT_OP 

%%

Program : 
    MAIN Instructions F_END {
      printf( "#include<stdio.h>\n\nint main() {\n%s\nreturn 0;\n}\n", $2 );
    }
  ;

Instructions : 
    Instructions Instruction {
      asprintf(&$$, "%s%s", $1, $2);
      free($1);
      free($2);
    }
  | Instruction {
      $$ = $1;
    }
  ;

Instruction :
    T_INT NAME EQUALS expression {
      asprintf(&$$, " int %s = %s;\n", $2, $4);
      free($2);
      free($4);
    }
  | T_INT NAME {
      asprintf(&$$, " int %s;\n", $2);
      free($2);
    }
  | NAME EQUALS expression {
      asprintf(&$$, " %s = %s;\n", $1, $3);
      free($1);
      free($3);
    }
  | F_PRINT expression {
      asprintf(&$$, " printf(\"%%d\\n\", %s);\n", $2);
      free($2);
    }
  | F_PRINT STRING {
      asprintf(&$$, " printf(%s);\n", $2);
    }
  | F_READ NAME {
      asprintf(&$$, " scanf(\"%%d\", &%s);\n", $2);
      free($2);
    }
  | F_IF condition F_THEN Instructions ifelsestop {
      asprintf(&$$, " if (%s) {\n%s} %s\n", $2, $4, $5);
      free($2);
      free($4);
      free($5);
    }
  | F_WHILE condition F_THEN Instructions F_STOP {
      asprintf(&$$, " while (%s) {\n%s}\n", $2, $4);
      free($2);
      free($4);
    }
  ;

ifelsestop :
    F_STOP {
      $$ = strdup("");
    }
  | F_ELSE F_THEN Instructions F_STOP{
      asprintf(&$$, " else {\n%s}\n", $3);
      free($3);
    }
  | F_ELSE F_IF condition F_THEN Instructions ifelsestop {
      asprintf(&$$, " else if (%s) {\n%s} %s\n", $3, $5, $6);
      free($3);
      free($5);
      free($6);
    } 
  ;

expression :
    expression OPERATOR value {
      asprintf(&$$, "%s %s %s", $1, $2, $3);
      free($1);
      free($2);
      free($3);
    }
  | value {
    $$ = $1;
  }
  ;

value :
    '(' expression ')' {
      asprintf(&$$, "(%s)", $2);
      free($2);
    }
  | IVAL {
      asprintf(&$$, "%d", $1);
    }
  | NAME {
      $$ = $1;
    }
  ;

condition :
    operand COMPARATOR operand {
      asprintf(&$$, "%s %s %s", $1, $2, $3);
      free($1);
      free($2);
      free($3);
    }
  | condition BINARY_OP condition {
      asprintf(&$$, "%s %s %s", $1, $2, $3);
      free($1);
      free($2);
      free($3);
    }
  | '(' condition ')' {
      asprintf(&$$, "(%s)", $2);
      free($2);
    }
  | NOT_OP condition { 
      asprintf(&$$, "!%s", $2);
      free($2);
    }
  | operand {
      $$ = $1;
    }
  ;

operand : 
    IVAL { 
      asprintf(&$$, "%d", $1);
    }
  | NAME {}
  ;

%%

int yyerror(const char* msg) {
  fprintf(stderr, "Błąd gramatyki w linii %d: %s przy \"%s\"\n", yylineno, msg, yytext);
  return 0;
}

int main() {
  yyparse();
}
