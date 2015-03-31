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
cd          			return CD;
bye				return BYE;
printenv			return PRINT_ENV;
setenv				return SET_ENV;
unsetenv			return UNSET_ENV;
alias				return ALIAS;
unalias				return UNALIAS;
&				return AMPERSAND;
\"[ a-zA-Z0-9\/.-]+\"		yylval.string=strdup(yytext); return WORD;
["$"\{\}~a-zA-Z0-9\/.-]+   		yylval.string=strdup(yytext); return WORD;
\n          			return NEW_LINE;       
[ \t]+                  /* ignore whitespace */;
%%


