/*
Precedence Rules:
	Rules that are matched more specifically come first.
	If both match the same, first rule written in this file is used.
*/
%{
#include <stdio.h>
#include "y.tab.h"
%}
%%
[/]			return FRONTSLASH;
[\\]		return BACKSLASH;
[<]			return LESSTHAN;
[>]			return GREATERTHAN;
[|]			return PIPE;
["]			return DOUBLEQUOTE;
[&]			return AMPERSAND;
\.			return PERIOD;
[0-9]+		return NUMBER;
cd          return CD;
ls			return LS;
bye			return BYE;
printenv	return PRINT_ENV;
setenv		return SET_ENV;
unsetenv	return UNSET_ENV;
\.\.		yylval.string=strdup(yytext); return WORD;
[a-zA-Z][a-zA-Z0-9_()\.]*    yylval.string=strdup(yytext); return WORD;
\n                      /* ignore end of line */;
[ \t]+                  /* ignore whitespace */;
%%

