%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void yyerror(char * mensaje);

int num_linea = 1;

%}


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

%left OP_EXC_BIN
%right OP_EXC_UN
%left MENOS
%left MASMAS
%left ARROBA

%left COMA

%left CORCHETE_ABRE
%left CORCHETE_CIERRA


%start programa

%%

programa					: PRINCIPAL bloque ;

bloque						: LLAVE_ABRE declar_variables declar_subprogramas sentencias LLAVE_CIERRA ;

declar_variables			: declar_variables cuerpo_declar_var
						 		| cuerpo_declar_var
								| ;

cuerpo_declar_var			: tipo ident_variables PYC ;

ident_variables             : ident_variables COMA ID
                                | ident_variables COMA ID ASIGNACION expresion
                                | ID
                                | ID ASIGNACION expresion ;

expresion                   : PARENTESIS_ABRE expresion PARENTESIS_CIERRA
                                | OP_EXC_UN expresion
                                | expresion OP_EXC_BIN expresion
                                | expresion MASMAS expresion ARROBA expresion
                                | MENOS expresion
                                | llamada_subprograma
                                | ID
                                | constante ;

constante                   : CONSTANTE_BASICA
                                | CORCHETE_ABRE contenido_lista CORCHETE_CIERRA ;

contenido_lista             : contenido_lista_preced CONSTANTE_BASICA
                                | CONSTANTE_BASICA
                                | ;

contenido_lista_preced      : contenido_lista_preced contenido_lista_preced
                                | CONSTANTE_BASICA COMA ;


llamada_subprograma         : ID PARENTESIS_ABRE parametros PARENTESIS_CIERRA PYC ;



declar_subprogramas         : declar_subprogramas declar_subp
                                | ;

declar_subp                 : cabecera_subp bloque ;

cabecera_subp               : tipo ID PARENTESIS_ABRE parametros PARENTESIS_CIERRA
                                | ID PARENTESIS_ABRE parametros PARENTESIS_CIERRA ;

tipo                        : TIPO_BASICO
                                | LISTADE TIPO_BASICO ;

parametros                  : parametro
                                | parametro_preced parametro
                                | ;

parametro                   : tipo ID ;

parametro_preced            : parametro_preced parametro_preced
                                | parametro COMA;

sentencias                  : sentencias sentencia
                                | ;

sentencia                   : bloque
                                | ID ASIGNACION expresion PYC
                                | SI expresion sentencia
                                | SI expresion sentencia SINO sentencia
                                | MIENTRAS expresion sentencia
                                | REPETIR sentencia MIENTRAS PARENTESIS_ABRE expresion PARENTESIS_CIERRA PYC
                                | DEVUELVE ID PYC
                                | ID AVANZAR PYC
                                | ID RETROCEDER PYC
                                | DOLAR ID PYC
                                | ENTRADA lista_variables
                                | SALIDA lista_expresiones_o_cadena ;

lista_variables             : lista_variables COMA ID
                                | ID ;

lista_expresiones_o_cadena  : lista_expresiones_o_cadena COMA CADENA
                                | expresion COMA lista_expresiones_o_cadena
                                | CADENA
                                | expresion ;

%%


#include "lex.yy.c"

void yyerror( char *msg )
{
    fprintf(stderr,"[Linea %d]: %s\n", num_linea, msg) ;
}

