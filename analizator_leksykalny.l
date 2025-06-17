%{
  #include "gramatyka.tab.h"
  extern int yylineno;
  void yyerror(const char *s);
%}

%x COMMENT
%option yylineno

%%

\n                    {}

[ \t\r]+              { /* ignoruj białe znaki */ }

"#".*                       { /* komentarz jednoliniowy */ }
"/#"                        { BEGIN(COMMENT); }
<COMMENT>{
  "#/"                      { BEGIN(INITIAL); }
  .|\n                      { /* nic */ }
}

"CAŁKOWITA"               { return T_INT; }
"program"                 { return MAIN; }
"jeżeli"                  { return F_IF; }
"jaknie"                  { return F_ELSE; }
"dopóki"                  { return F_WHILE; }
"wtedy"                   { return F_THEN; }
"koniec"                  { return F_STOP; }
"zakończ program"         { return F_END; }
"wypisz"                  { return F_PRINT; }
"przeczytaj"              { return F_READ; }

"=="|"!="|"<="|">="|"<"|">" { yylval.sval = strdup(yytext); return COMPARATOR; }

"&&"|"||"                   { yylval.sval = strdup(yytext); return BINARY_OP; }
"!"                         { yylval.sval = strdup(yytext); return NOT_OP; }

[()]                        { return yytext[0]; }

"+"|"-"|"*"|"/"             { yylval.sval = strdup(yytext); return OPERATOR; }
"="                         { return EQUALS; }

[0-9]+                      { yylval.ival = atoi(yytext); return IVAL; }

[a-zA-Z_][a-zA-Z0-9_]*      { yylval.sval = strdup(yytext); return NAME; }

["].*["]                    { yylval.sval = strdup(yytext); return STRING; }


.                       { printf("Nieznany znak: %s w linii %d\n", yytext, yylineno); exit(1); }

%%
