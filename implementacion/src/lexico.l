%{
#include <stdlib.h>
#include <string.h>
#include <y.tab.h>


%}

letra		[a-zA-Z]
digito		[0-9]


%option noyywrap
%%

"variable"						return(VAR);
"principal()"					return(PRINCIPAL);
"entero"							yylval = 0; return(TIPO_BASICO);
"real"							yylval = 1; return(TIPO_BASICO);
"caracter"						yylval = 2; return(TIPO_BASICO);
"booleano"						yylval = 3; return(TIPO_BASICO);
"vacio"							yylval = 4; return(TIPO_BASICO);
"}"								return(LLAVE_CIERRA);
"{"								return(LLAVE_ABRE);
"listade"						return(LISTADE);
"="								return(ASIGNACION);
"sino"							return(SINO);
"si"								return(SI);
"devuelve"						return(DEVUELVE);
"repetir"						return(REPETIR);
"mientras"						return(MIENTRAS);
"salida"						return(SALIDA);
"entrada"						return(ENTRADA);
"<<"								return(RETROCEDER);
">>"								return(AVANZAR);
"$"								return(DOLAR);
")"								return(PARENTESIS_CIERRA);
"("								return(PARENTESIS_ABRE);
";"								return(PYC);
"++"								return(MASMAS);
"@"								return(ARROBA);
"!"								return(OP_EXC_UN);
"#"								return(OP_EXC_UN);
"?"								return(OP_EXC_UN);
"-"								return(MENOS);
"+"								yylval = 0; return(OP_EXC_BIN);
"*"								yylval = 1; return(OP_EXC_BIN);
"/"								yylval = 2; return(OP_EXC_BIN);
"&&"								yylval = 3; return(OP_EXC_BIN);
"||"								yylval = 4; return(OP_EXC_BIN);
"^"								yylval = 5; return(OP_EXC_BIN);
"<"								yylval = 6; return(OP_EXC_BIN);
">"								yylval = 7; return(OP_EXC_BIN);
"<="								yylval = 8; return(OP_EXC_BIN);
">="								yylval = 9; return(OP_EXC_BIN);
"=="								yylval = 10; return(OP_EXC_BIN);
"!="								yylval = 11; return(OP_EXC_BIN);
"--"								yylval = 12; return(OP_EXC_BIN);
"%"								yylval = 13; return(OP_EXC_BIN);
"**"								yylval = 14; return(OP_EXC_BIN);
","								return(COMA);
"]"								return(CORCHETE_CIERRA);
"["								return(CORCHETE_ABRE);
{digito}+						yylval = 0; return(CONSTANTE_BASICA);
{digito}+"."{digito}+		yylval = 1; return(CONSTANTE_BASICA);
"\'"."\'"						yylval = 2; return(CONSTANTE_BASICA);
("verdadero"|"falso")		yylval = 3; return(CONSTANTE_BASICA);
\'[^\']+\'						return(CADENA);
{letra}({letra}|{digito})*	yylval.lexema = strdup (yytext); return(ID);
"\n"								num_linea++;
[" ""\t"]+						;
.							printf("Error lexico - símbolo erróneo: '%s' en línea %d\n",yytext, num_linea);

%%
