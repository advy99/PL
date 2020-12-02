%{
#include <stdlib.h>
#include <string.h>
#include <y.tab.h>


%}

letra		[a-zA-Z]
digito		[0-9]
%option noyywrap
%%

"\n"								num_linea++;
[" ""\t"]+						;
"variable"						printf("%s ", yytext);
"principal()"					printf("%s", yytext);
"entero"							yylval = 0; printf("%s",yytext);
"real"							yylval = 1; printf("%s",yytext);
"caracter"						yylval = 2; printf("%s",yytext);
"booleano"						yylval = 3; printf("%s",yytext);
"vacio"							yylval = 4; printf("%s",yytext);
"}"								printf("%s",yytext);
"{"								printf("%s",yytext);
"listade"						printf("%s",yytext);
"="								printf("%s",yytext);
"sino"							printf("%s",yytext);
"si"								printf("%s",yytext);
"devuelve"						printf("%s",yytext);
"repetir"						printf("%s",yytext);
"mientras"						printf("%s",yytext);
"salida"							printf("%s",yytext);
"entrada"						printf("%s",yytext);
"<<"								printf("%s",yytext);
">>"								printf("%s",yytext);
"$"								printf("%s",yytext);
")"								printf("%s",yytext);
"("								printf("%s",yytext);
";"								printf("%s",yytext);
"++"								printf("%s",yytext);
"@"								printf("%s",yytext);
"!"								printf("%s",yytext);
"#"								printf("%s",yytext);
"?"								printf("%s",yytext);
"-"								printf("%s",yytext);
"+"								yylval = 0; printf("%s",yytext);
"*"								yylval = 1; printf("%s",yytext);
"/"								yylval = 2; printf("%s",yytext);
"&&"								yylval = 3; printf("%s",yytext);
"||"								yylval = 4; printf("%s",yytext);
"^"								yylval = 5; printf("%s",yytext);
"<"								yylval = 6; printf("%s",yytext);
">"								yylval = 7; printf("%s",yytext);
"<="								yylval = 8; printf("%s",yytext);
">="								yylval = 9; printf("%s",yytext);
"=="								yylval = 10; printf("%s",yytext);
"!="								yylval = 11; printf("%s",yytext);
"--"								yylval = 12; printf("%s",yytext);
"%"								yylval = 13; printf("%s",yytext);
"**"								yylval = 14; printf("%s",yytext);
","								printf("%s",yytext);
"]"								printf("%s",yytext);
"["								printf("%s",yytext);
{digito}+						yylval = 0; printf("%s",yytext);
{digito}+"."{digito}+		yylval = 1; printf("%s",yytext);
"\'"{letra}"\'"				yylval = 2; printf("%s",yytext);
"verdadero" | "falso"		yylval = 3; printf("%s",yytext);
"\""(" "|{letra}|{digito})*"\"" yylval = 4; printf("%s",yytext);
{letra}[{letra}{digito}]*	printf("%s",yytext);
.							printf("Símbolo erróneo: '%s' en línea %s\n",yytext, num_linea");

%%
