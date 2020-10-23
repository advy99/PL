%{
#include <stdlib.h>
#include <string.h>
#include <y.tab.h>
#include "tabla_tokens.h"

int num_linea = 1;

%}

letra		[a-zA-Z]
digito		[0-9]

%%

"\n"								num_linea++;
[" ""\t"]+						;
"principal()"					printf("lexema='%s' token='PRINCIPAL'\n",yytext); return(PRINCIPAL);
"entero"							printf("lexema='%s' token='TIPO_BASICO' atributo='0'\n",yytext); return(TIPO_BASICO);
"real"							printf("lexema='%s' token='TIPO_BASICO' atributo='1'\n",yytext); return(TIPO_BASICO);
"caracter"						printf("lexema='%s' token='TIPO_BASICO' atributo='2'\n",yytext); return(TIPO_BASICO);
"booleano"						printf("lexema='%s' token='TIPO_BASICO' atributo='3'\n",yytext); return(TIPO_BASICO);
"}"								printf("lexema='%s' token='LLAVE_CIERRA'\n",yytext); return(LLAVE_CIERRA);
"{"								printf("lexema='%s' token='LLAVE_ABRE'\n",yytext); return(LLAVE_ABRE);
"listade"						printf("lexema='%s' token='LISTADE'\n",yytext); return(LISTADE);
"="								printf("lexema='%s' token='ASIGNACION'\n",yytext); return(ASIGNACION);
"sino"							printf("lexema='%s' token='SINO'\n",yytext); return(SINO);
"si"								printf("lexema='%s' token='SI'\n",yytext); return(SI);
"devuelve"						printf("lexema='%s' token='DEVUELVE'\n",yytext); return(DEVUELVE);
"repetir"						printf("lexema='%s' token='REPETIR'\n",yytext); return(REPETIR);
"mientras"						printf("lexema='%s' token='MIENTRAS'\n",yytext); return(MIENTRAS);
"salida"							printf("lexema='%s' token='SALIDA'\n",yytext); return(SALIDA);
"entrada"						printf("lexema='%s' token='ENTRADA'\n",yytext); return(ENTRADA);
"<<"								printf("lexema='%s' token='RETROCEDER'\n",yytext); return(RETROCEDER);
">>"								printf("lexema='%s' token='AVANZAR'\n",yytext); return(AVANZAR);
"$"								printf("lexema='%s' token='DOLAR'\n",yytext); return(DOLAR);
"\""								printf("lexema='%s' token='COMILLAS'\n",yytext); return(COMILLAS);
")"								printf("lexema='%s' token='PARENTESIS_CIERRA'\n",yytext); return(PARENTESIS_CIERRA);
"("								printf("lexema='%s' token='PARENTESIS_ABRE'\n",yytext); return(PARENTESIS_ABRE);
";"								printf("lexema='%s' token='PYC'\n",yytext); return(PYC);
"++"								printf("lexema='%s' token='MASMAS'\n",yytext); return(MASMAS);
"@"								printf("lexema='%s' token='ARROBA'\n",yytext); return(ARROBA);
"!"								printf("lexema='%s' token='OP_EXC_UN' atributo='0'\n",yytext); return(OP_EXC_UN);
"#"								printf("lexema='%s' token='OP_EXC_UN' atributo='1'\n",yytext); return(OP_EXC_UN);
"?"								printf("lexema='%s' token='OP_EXC_UN' atributo='2'\n",yytext); return(OP_EXC_UN);
"-"								printf("lexema='%s' token='MENOS'\n",yytext); return(MENOS);
"+"								printf("lexema='%s' token='OP_EXC_BIN' atributo='0'\n",yytext); return(OP_EXC_BIN);
"*"								printf("lexema='%s' token='OP_EXC_BIN' atributo='1'\n",yytext); return(OP_EXC_BIN);
"/"								printf("lexema='%s' token='OP_EXC_BIN' atributo='2'\n",yytext); return(OP_EXC_BIN);
"&&"								printf("lexema='%s' token='OP_EXC_BIN' atributo='3'\n",yytext); return(OP_EXC_BIN);
"||"								printf("lexema='%s' token='OP_EXC_BIN' atributo='4'\n",yytext); return(OP_EXC_BIN);
"^"								printf("lexema='%s' token='OP_EXC_BIN' atributo='5'\n",yytext); return(OP_EXC_BIN);
"<"								printf("lexema='%s' token='OP_EXC_BIN' atributo='6'\n",yytext); return(OP_EXC_BIN);
">"								printf("lexema='%s' token='OP_EXC_BIN' atributo='7'\n",yytext); return(OP_EXC_BIN);
"<="								printf("lexema='%s' token='OP_EXC_BIN' atributo='8'\n",yytext); return(OP_EXC_BIN);
">="								printf("lexema='%s' token='OP_EXC_BIN' atributo='9'\n",yytext); return(OP_EXC_BIN);
"=="								printf("lexema='%s' token='OP_EXC_BIN' atributo='10'\n",yytext); return(OP_EXC_BIN);
"!="								printf("lexema='%s' token='OP_EXC_BIN' atributo='11'\n",yytext); return(OP_EXC_BIN);
"--"								printf("lexema='%s' token='OP_EXC_BIN' atributo='12'\n",yytext); return(OP_EXC_BIN);
"%"								printf("lexema='%s' token='OP_EXC_BIN' atributo='13'\n",yytext); return(OP_EXC_BIN);
"**"								printf("lexema='%s' token='OP_EXC_BIN' atributo='14'\n",yytext); return(OP_EXC_BIN);
","								printf("lexema='%s' token='COMA'\n",yytext); return(COMA);
"]"								printf("lexema='%s' token='CORCHETE_CIERRA'\n",yytext); return(CORCHETE_CIERRA);
"["								printf("lexema='%s' token='CORCHETE_ABRE'\n",yytext); return(CORCHETE_ABRE);
{digito}+						printf("lexema='%s' token='CONSTANTE_BASICA' atributo='0'\n",yytext); return(CONSTANTE_BASICA);
{digito}+"."{digito}+		printf("lexema='%s' token='CONSTANTE_BASICA' atributo='1'\n",yytext); return(CONSTANTE_BASICA);
"\'"{letra}"\'"				printf("lexema='%s' token='CONSTANTE_BASICA' atributo='2'\n",yytext); return(CONSTANTE_BASICA);
"verdadero" | "falso"		printf("lexema='%s' token='CONSTANTE_BASICA' atributo='3'\n",yytext); return(CONSTANTE_BASICA);
{letra}[{letra}{digito}]*	printf("lexema='%s' token='ID'\n",yytext); return(ID);
.							return("Símbolo erróneo: '%s' en línea %d\n",yytext, num_linea);

%%
