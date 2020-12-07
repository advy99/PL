%{

#include <cstdlib>
#include <cstdio>
#include <string>

using namespace std;

int yylex();
void yyerror(const char * mensaje);

int num_linea = 1;

#include "estructuras_datos.h"

#define MAX_TS 500

unsigned long int TOPE = 0;
unsigned int subprog;
dtipo tipoTmp;


entradaTS TS[MAX_TS];

typedef struct {
	int atrib;
	string lexema;
	dtipo tipo;
} atributos;

#define YYSTYPE atributos

// falta funciones:
// insertar
// modificar
// consultar

void TS_InsertaIDENT(atributos atrib);

void TS_InsertaMARCA();

void TS_VaciarENTRADAS();

void TS_InsertaSUBPROG(atributos atrib);

void TS_InsertaPARAMF(atributos atrib);

int incrementaTOPE();

dtipo encontrarEntrada(string nombre, bool quiero_que_este);


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
								  LLAVE_CIERRA { TS_VaciarENTRADAS(); };



variables					: declar_variables
				 				| ;

declar_variables			: declar_variables cuerpo_declar_var
						 		| cuerpo_declar_var ;

cuerpo_declar_var			: VAR
						  		  tipo { tipoTmp = $1.tipo;  }
								  ident_variables PYC ;

ident_variables             : ident_variables COMA ID { TS_InsertaIDENT($3); }
                                | ident_variables COMA ID ASIGNACION expresion { TS_InsertaIDENT($3); }
                                | ID { TS_InsertaIDENT($1); }
                                | ID ASIGNACION expresion {  TS_InsertaIDENT($1);if ($1.tipo != $3.tipo) {printf("Error semantico en la linea %d: Los tipos son distintos\n", num_linea);} }
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

parametro                   : tipo ID { tipoTmp = $1.tipo; TS_InsertaPARAMF($2); };

parametro_preced            : parametro_preced parametro COMA
                                | parametro COMA;

sentencias                  : sentencias sentencia
                                | ;

sentencia                   : bloque
                                | ID ASIGNACION expresion PYC { if ($1.tipo != $3.tipo) {printf("Error semantico en la linea %d: Los tipos son distintos\n", num_linea);}}
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

#include "estructuras_datos.h"

void yyerror(const char *msg)
{
    fprintf(stderr,"[Linea %d]: %s\n", num_linea, msg) ;
}


void TS_InsertaIDENT(atributos atributo){

	//printf("Identificador %s\n\n", atributo.lexema.c_str());

	entradaTS nueva_entrada;

	nueva_entrada.entrada = variable;

	nueva_entrada.nombre = atributo.lexema;

	nueva_entrada.parametros = 0;

	nueva_entrada.tipoDato = tipoTmp;

	int pos_id_buscado = TOPE - 1;
	bool encontrado = false;

	while ( pos_id_buscado >= 0 && TS[pos_id_buscado].entrada != marca && !encontrado) {

		if ( atributo.lexema == TS[pos_id_buscado].nombre ) {
			encontrado = true;
		} else {
			pos_id_buscado--;
		}
	}

	if ( !encontrado ) {
		TS[TOPE] = nueva_entrada;

		incrementaTOPE();

	} else {
		printf("Error semantico: Redeclaración de la variable '%s' en la linea %d\n", atributo.lexema.c_str(), num_linea);
	}


}

void TS_InsertaMARCA(){

	entradaTS nueva_entrada;

	nueva_entrada.entrada = marca;

	// metemos cadena vacia siempre al meter algo, por si encontramos sin querer
	// por el tema de basura
	nueva_entrada.nombre = "";

	TS[TOPE] = nueva_entrada;

	incrementaTOPE();
}

void TS_VaciarENTRADAS(){

	// lo mismo habria que comprobar si ha llegado a encontrar
	// la marca, por el tema de error semantico si tenemos un cierra llave

	while ( TS[TOPE].entrada != marca && TOPE > 0 ){
		TOPE--;
	}

	// tambien eliminamos la marca
	TOPE--;

}

void TS_InsertaSUBPROG(atributos atributo){


	dtipo tipo_buscar = encontrarEntrada(atributo.lexema, false);

	if ( tipo_buscar == desconocido ){
		entradaTS nueva_entrada;

		nueva_entrada.entrada = funcion;

		nueva_entrada.nombre = atributo.lexema;

		nueva_entrada.parametros = 0;

		nueva_entrada.tipoDato = tipoTmp;

		TS[TOPE] = nueva_entrada;

		subprog = TOPE;

		incrementaTOPE();

	} else {
		printf("\nError semantico en la linea %d. Redefinición de '%s'\n", num_linea, atributo.lexema.c_str());
	}



}

void TS_InsertaPARAMF(atributos atributo){
	// aqui hay que utilizar TOPE	- 1 porque es sobre la funcion que hemos añadido antes

	entradaTS nueva_entrada;

	nueva_entrada.entrada = parametro_formal;

	nueva_entrada.nombre = atributo.lexema;

	nueva_entrada.parametros = 0;

	nueva_entrada.tipoDato = tipoTmp;

	TS[TOPE] = nueva_entrada;

	TS[subprog].parametros++;

	incrementaTOPE();

}



dtipo encontrarEntrada(string nombre, bool quiero_que_este) {
	// devuelve la posicion de una entrada con mismo nombre, -1 si no la encuentra

	int pos_actual = TOPE;
	dtipo tipo = desconocido;

	while ( TS[pos_actual].nombre != nombre && pos_actual >= 0 ) {
		// son distintos, seguimos buscando
		pos_actual-- ;
	}

	if ( pos_actual != -1 ) {
		tipo = TS[pos_actual].tipoDato;
	} else if (quiero_que_este) {
		printf("\nError semantico en la linea %d. Identificador '%s' no declarado\n", num_linea, nombre.c_str());
	}

	return tipo;

}


int incrementaTOPE(){

	int salida = 1;

	if (TOPE == MAX_TS) {
		printf("ERROR: Tope de la pila alcanzado. Demasiadas entradas en la tabla de símbolos. Abortando compilación");

		salida = 0;

	} else {
		TOPE++;
	}

	return salida;
}


