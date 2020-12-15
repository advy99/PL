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
"principal()"					yylval.lexema = "principal"; return(PRINCIPAL);
"entero"							yylval.atrib =  0; yylval.tipo = entero; return(TIPO_BASICO);
"real"							yylval.atrib =  1; yylval.tipo = real; return(TIPO_BASICO);
"caracter"						yylval.atrib =  2; yylval.tipo = caracter; return(TIPO_BASICO);
"booleano"						yylval.atrib =  3; yylval.tipo = booleano; return(TIPO_BASICO);
"vacio"							yylval.atrib =  4; yylval.tipo = vacio; return(TIPO_BASICO);
"}"								return(LLAVE_CIERRA);
"{"								return(LLAVE_ABRE);
"listade"						return(LISTADE);
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
"!"								yylval.atrib = 0;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_UN);
"#"								yylval.atrib = 1;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_UN);
"?"								yylval.atrib = 2;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_UN);
"-"								yylval.lexema = string(strdup(yytext)); return(MENOS);
"+"								yylval.atrib =  0;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_BIN);
"*"								yylval.atrib =  1;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_BIN);
"/"								yylval.atrib =  2;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_BIN);
"&&"								yylval.atrib =  3;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_BIN);
"||"								yylval.atrib =  4;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_BIN);
"^"								yylval.atrib =  5;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_BIN);
"<"								yylval.atrib =  6;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_BIN);
">"								yylval.atrib =  7;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_BIN);
"<="								yylval.atrib =  8;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_BIN);
">="								yylval.atrib =  9;  yylval.lexema = string(strdup(yytext)); return(OP_EXC_BIN);
"=="								yylval.atrib =  10; yylval.lexema = string(strdup(yytext));  return(OP_EXC_BIN);
"!="								yylval.atrib =  11; yylval.lexema = string(strdup(yytext));  return(OP_EXC_BIN);
"--"								yylval.atrib =  12; yylval.lexema = string(strdup(yytext));  return(OP_EXC_BIN);
"%"								yylval.atrib =  13; yylval.lexema = string(strdup(yytext));  return(OP_EXC_BIN);
"**"								yylval.atrib =  14; yylval.lexema = string(strdup(yytext));  return(OP_EXC_BIN);
","								return(COMA);
"]"								return(CORCHETE_CIERRA);
"["								return(CORCHETE_ABRE);
{digito}+						yylval.atrib =  0; yylval.tipo = entero; yylval.es_constante = true; yylval.lexema = string(strdup(yytext)); return(CONSTANTE_BASICA);
{digito}+"."{digito}+		yylval.atrib =  1; yylval.tipo = real;  yylval.es_constante = true; yylval.lexema =  string(strdup(yytext)); return(CONSTANTE_BASICA);
"\'"."\'"						yylval.atrib =  2; yylval.tipo = caracter;  yylval.es_constante = true; yylval.lexema = string(strdup(yytext)); return(CONSTANTE_BASICA);
("verdadero"|"falso")		yylval.atrib =  3; yylval.tipo = booleano;  yylval.es_constante = true; if ( string(strdup(yytext)) == "verdadero" ) {yylval.lexema = "true";} else {yylval.lexema = "false";}; return(CONSTANTE_BASICA);
\'[^\']+\'						yylval.lexema = string(strdup(yytext)); yylval.lexema = yylval.lexema.substr(1, yylval.lexema.size()-2); return(CADENA);
{letra}({letra}|{digito})*	yylval.lexema = string(strdup (yytext)); return(ID);
"\n"								num_linea++;
[" ""\t"]+						;
.							printf("Error lexico - símbolo erróneo: '%s' en línea %d\n",yytext, num_linea); num_errores++;

%%
