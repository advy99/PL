%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void yyerror(char * mensaje);

int linea_actual = 1;

%}

%error-verbose



%token CONSTANTE_BASICA
%token CORCHETE_ABRE
%token CORCHETE_CIERRA
%token COMA
%token OP_EXC_BIN
%token MENOS
%token OP_EXC_UN
%token ARROBA
%token MASMAS
%token ID
%token PYC
%token PARENTESIS_ABRE
%token PARENTESIS_CIERRA
%token COMILLAS
%token DOLAR
%token AVANZAR
%token RETROCEDER
%token ENTRADA
%token SALIDA
%token MIENTRAS
%token REPETIR
%token DEVUELVE
%token SI
%token SINO
%token ASIGNACION
%token LISTADE
%token LLAVE_ABRE
%token LLAVE_CIERRA
%token TIPO_BASICO
%token PRINCIPAL
%token CADENA

%%

programa					: PRINCIPAL bloque

bloque						: LLAVE_ABRE declar_variables declar_subp sentencias LLAVE_CIERRA

declar_variables			: declar_variables cuerpo_declar_var
						 		| cuerpo_declar_var
								| ;

cuerpo_declar_var			: tipo ident_variables PYC

ident_variables             : ident_variables COMA ID CORCHETE_ABRE ASIGNACION expresion CORCHETE_CIERRA
                                | ID CORCHETE_ABRE ASIGNACION expresion CORCHETE_CIERRA

expresion                   : PARENTESIS_ABRE expresion PARENTESIS_CIERRA
                                | OP_EXC_UN expresion
                                | expresion OP_EXC_BIN expresion
                                | expresion MASMAS
                                | expresion ARROBA expresion
                                | llamada_subprograma
                                | ID
                                | constante

constante                   : CONSTANTE_BASICA
                                | LISTADE

llamada_subprograma         :   




%%



