%{
#include <cstdlib>
#include <string>
#include <y.tab.h>

using namespace std;

%}

letra		[a-zA-Z]
digito		[0-9]

%option noyywrap

%%

"variable"						return(VAR);
"principal()"					return(PRINCIPAL);
"entero"							yylval.atrib =  0; yylval.tipo = entero; return(TIPO_BASICO);
"real"							yylval.atrib =  1; yylval.tipo = real; return(TIPO_BASICO);
"caracter"						yylval.atrib =  2; yylval.tipo = caracter; return(TIPO_BASICO);
"booleano"						yylval.atrib =  3; yylval.tipo = booleano; return(TIPO_BASICO);
"vacio"							yylval.atrib =  4; yylval.tipo = vacio; return(TIPO_BASICO);
"}"								return(LLAVE_CIERRA);
"{"								return(LLAVE_ABRE);
"listade"						yylval.tipo = lista; return(LISTADE);
"="								return(ASIGNACION);
"sino"							return(SINO);
"si"								return(SI);
"devuelve"						return(DEVUELVE);
"repetir"						return(REPETIR);
"mientras"						return(MIENTRAS);
"salida"							return(SALIDA);
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
"+"								yylval.atrib =  0; return(OP_EXC_BIN);
"*"								yylval.atrib =  1; return(OP_EXC_BIN);
"/"								yylval.atrib =  2; return(OP_EXC_BIN);
"&&"								yylval.atrib =  3; return(OP_EXC_BIN);
"||"								yylval.atrib =  4; return(OP_EXC_BIN);
"^"								yylval.atrib =  5; return(OP_EXC_BIN);
"<"								yylval.atrib =  6; return(OP_EXC_BIN);
">"								yylval.atrib =  7; return(OP_EXC_BIN);
"<="								yylval.atrib =  8; return(OP_EXC_BIN);
">="								yylval.atrib =  9; return(OP_EXC_BIN);
"=="								yylval.atrib =  10; return(OP_EXC_BIN);
"!="								yylval.atrib =  11; return(OP_EXC_BIN);
"--"								yylval.atrib =  12; return(OP_EXC_BIN);
"%"								yylval.atrib =  13; return(OP_EXC_BIN);
"**"								yylval.atrib =  14; return(OP_EXC_BIN);
","								return(COMA);
"]"								return(CORCHETE_CIERRA);
"["								return(CORCHETE_ABRE);
{digito}+						yylval.atrib =  0; yylval.tipo = entero; return(CONSTANTE_BASICA);
{digito}+"."{digito}+		yylval.atrib =  1; yylval.tipo = real; return(CONSTANTE_BASICA);
"\'"."\'"						yylval.atrib =  2; yylval.tipo = caracter; return(CONSTANTE_BASICA);
("verdadero"|"falso")		yylval.atrib =  3; yylval.tipo = booleano; return(CONSTANTE_BASICA);
\'[^\']+\'						return(CADENA);
{letra}({letra}|{digito})*	yylval.lexema = string(strdup (yytext)); return(ID);
"\n"								num_linea++;
[" ""\t"]+						;
.							printf("Error lexico - símbolo erróneo: '%s' en línea %d\n",yytext, num_linea);

%%
