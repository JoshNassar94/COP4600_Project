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
[0-9]+                  return NUMBER;
bye						return BYE;
cd						return CD;
ls						return LS;
printenv				return PRINTENV;
alias					return ALIAS;
\n                      /* ignore end of line */;
[ \t]+                  /* ignore whitespace */;
%%

