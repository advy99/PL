%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int yylex();
void yyerror(const char * mensaje);

int num_linea = 1;

#include "estructuras_datos.h"

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
%token VAR

%left OP_EXC_BIN
%right OP_EXC_UN
%left MENOS
%left MASMAS
%left ARROBA


%left CORCHETE_ABRE
%left CORCHETE_CIERRA


%start programa

%%

programa					: PRINCIPAL bloque ;


bloque						: LLAVE_ABRE  { TS_InsertaMARCA(); }
								  variables
								  declar_subprogramas
								  sentencias
								  LLAVE_CIERRA { TS_VaciarEntradas(); };



variables					: declar_variables
				 				| ;

declar_variables			: declar_variables cuerpo_declar_var
						 		| cuerpo_declar_var ;

cuerpo_declar_var			: VAR
						  		  tipo { tipoTmp = $1.tipo  }
								  ident_variables PYC ;

ident_variables             : ident_variables COMA ID { TS_insertaIDENT($3); }
                                | ident_variables COMA ID ASIGNACION expresion { TS_insertaIDENT($3); }
                                | ID { TS_insertaIDENT($1); }
                                | ID ASIGNACION expresion {  TS_insertaIDENT($1);  }
										  | error ;

expresion                   : PARENTESIS_ABRE expresion PARENTESIS_CIERRA
                                | OP_EXC_UN expresion
                                | expresion OP_EXC_BIN expresion
                                | expresion MENOS expresion
                                | expresion MASMAS expresion ARROBA expresion
                                | MENOS expresion
                                | llamada_subprograma
                                | ID
                                | constante
										  | error ;

constante                   : CONSTANTE_BASICA
                                | CORCHETE_ABRE contenido_lista CORCHETE_CIERRA ;

contenido_lista             : contenido_lista_preced CONSTANTE_BASICA
                                | CONSTANTE_BASICA
                                | ;

contenido_lista_preced      : contenido_lista_preced CONSTANTE_BASICA COMA
                                | CONSTANTE_BASICA COMA ;


llamada_subprograma         : ID PARENTESIS_ABRE lista_variables_constantes PARENTESIS_CIERRA;



declar_subprogramas         : declar_subprogramas declar_subp
                                | ;

declar_subp                 : cabecera_subp bloque  ;

cabecera_subp               : tipo ID PARENTESIS_ABRE parametros PARENTESIS_CIERRA { TS_InsertaSUBPROG($2);  }
									 | error;

tipo                        : TIPO_BASICO
                                | LISTADE TIPO_BASICO
										  | error ;

parametros                  : parametro
                                | parametro_preced parametro
                                | ;

parametro                   : tipo ID { TS_InsertaPARAMF($2); };

parametro_preced            : parametro_preced parametro COMA
                                | parametro COMA;

sentencias                  : sentencias sentencia
                                | ;

sentencia                   : bloque
                                | ID ASIGNACION expresion PYC
                                | SI expresion sentencia
                                | SI expresion sentencia SINO sentencia
                                | MIENTRAS expresion sentencia
                                | REPETIR sentencia MIENTRAS PARENTESIS_ABRE expresion PARENTESIS_CIERRA PYC
                                | DEVUELVE expresion PYC
                                | ID AVANZAR PYC
                                | ID RETROCEDER PYC
                                | DOLAR ID PYC
                                | ENTRADA lista_variables PYC
                                | SALIDA lista_expresiones_o_cadena PYC ;

lista_variables             : lista_variables COMA ID
                                | ID ;


lista_variables_constantes  : lista_variables_constantes COMA ID
                                | lista_variables_constantes COMA constante
                                | constante
                                | ID ;

lista_expresiones_o_cadena  : lista_expresiones_o_cadena COMA CADENA
									 	  | lista_expresiones_o_cadena COMA expresion
                                | CADENA
                                | expresion ;

%%


#include "lex.yy.c"


void yyerror(const char *msg)
{
    fprintf(stderr,"[Linea %d]: %s\n", num_linea, msg) ;
}

