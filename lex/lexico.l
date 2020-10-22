#include <stdlib.h>
#include <string.h>
#include "tabla_tokens.h"

int num_linea = 1;

%%

letra		[a-zA-Z]
digito		[0-9]

%%

"\n"						num_linea++;
[" ""\t"]+					;
"principal()"				return(PRINCIPAL);
"entero"					return(TIPO_BASICO);
"real"						return(TIPO_BASICO);
"caracter"					return(TIPO_BASICO);
"booleano"					return(TIPO_BASICO);
"}"							return(LLAVE_CIERRA);
"{"							return(LLAVE_ABRE);
"listade"					return(LISTADE);
"="							return(ASIGNACION);
"sino"						return(SINO);
"si"						return(SI);
"devuelve"					return(DEVUELVE);
"repetir"					return(REPETIR);
"mientras"					return(MIENTRAS);
"salida"					return(SALIDA);
"entrada"					return(ENTRADA);
"<<"						return(RETROCEDER);
">>"						return(AVANZAR);
"$"							return(DOLAR);
"\""						return(COMILLAS);
")"							return(PARENTESIS_CIERRA);
"("							return(PARENTESIS_ABRE);
";"							return(PYC);
"++"						return(MASMAS);
"@"							return(ARROBA);
"!"							return(OP_EXC_UN);
"#"							return(OP_EXC_UN);
"?"							return(OP_EXC_UN);
"-"							return(MENOS);
"+"							return(OP_EXC_BIN);
"*"							return(OP_EXC_BIN);
"/"							return(OP_EXC_BIN);
"&&"						return(OP_EXC_BIN);
"||"						return(OP_EXC_BIN);
"^"							return(OP_EXC_BIN);
"<"							return(OP_EXC_BIN);
">"							return(OP_EXC_BIN);
"<="						return(OP_EXC_BIN);
">="						return(OP_EXC_BIN);
"=="						return(OP_EXC_BIN);
"!="						return(OP_EXC_BIN);
"--"						return(OP_EXC_BIN);
"%"							return(OP_EXC_BIN);
"**"						return(OP_EXC_BIN);
","							return(COMA);
"]"							return(CORCHETE_CIERRA);
"["							return(CORCHETE_ABRE);
							return(LISTA);
{digito}+					return(CONSTANTE_BASICA);
{digito}+"."{digito}+		return(CONSTANTE_BASICA);
"'"{letra}"'"				return(CONSTANTE_BASICA);
"verdadero" | "falso"		return(CONSTANTE_BASICA);
{letra}[{letra}{digito}]*	return(ID);
.							return("Símbolo erróneo: '%s' en línea %d\n",yytext, num_linea);

%%