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
unsigned long int TOPE_PARAMF = 0;
bool subprog = false;
dtipo tipoTmp;
dtipo tipoSubprog;
bool listaTmp;

entradaTS TS[MAX_TS];

// necesitamos pila auxiliar para los parametros, porque si no
// los introduce antes de la funcion, por la forma de expandir reglas de bison
entradaTS TS_paramf[MAX_TS];

typedef struct {
	int atrib = 0;
	string lexema = "";
	bool lista = false;
	dtipo tipo = desconocido;
} atributos;

unsigned long TOPE_SUBPROG = 0;
atributos TS_llamadas_subprog[MAX_TS];

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

entradaTS encontrarEntrada(string nombre, bool quiero_que_este);

bool esFuncion(string nombre);

void comprobarEsVarOParamametroFormal(atributos atrib);

void comprobarEsTipo(dtipo tipo, dtipo tipo2);

void comprobarEsLista(atributos atrib);

dtipo comprobarLlamadaFuncion(atributos atrib);

void comprobarDevuelveSubprog(atributos atrib);

void comprobarAsignacionListas(atributos id, atributos exp);

void TS_subprog_inserta(atributos atrib);

string tipoAstring(dtipo tipo);


dtipo comprobarOpBinario(atributos izq, atributos operador, atributos der);
dtipo comprobarOpBinarioMenos(atributos izq, atributos der);
dtipo comprobarEsEnteroReal (atributos atrib);
dtipo comprobarOpUnarios( atributos atrib );

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

cuerpo_declar_var			: VAR tipo ident_variables PYC ;

ident_variables             : ident_variables COMA ID { TS_InsertaIDENT($3); }
                                | ident_variables COMA ID ASIGNACION expresion { TS_InsertaIDENT($3); }
                                | ID { TS_InsertaIDENT($1); }
                             	  | ID ASIGNACION expresion {  TS_InsertaIDENT($1); comprobarEsTipo($1.tipo, $3.tipo); comprobarAsignacionListas($1, $3); }
										  | error ;


expresion                   : PARENTESIS_ABRE expresion PARENTESIS_CIERRA {$$.tipo = $2.tipo; $$.lista = $2.lista;}
                                | OP_EXC_UN expresion {$$.tipo = comprobarOpUnarios($2); $$.lista = false;}
                                | expresion OP_EXC_BIN expresion	{$$.tipo = comprobarOpBinario($1, $2, $3); $$.lista = $1.lista || $3.lista; }
                                | expresion MENOS expresion {$$.tipo = comprobarOpBinarioMenos($1, $3); $$.lista = $1.lista || $3.lista;}
                                | expresion MASMAS expresion ARROBA expresion {comprobarEsLista($1); comprobarEsTipo($1.tipo, $3.tipo); comprobarEsTipo(entero, $5.tipo); $$.tipo = $1.tipo; $$.lista = $1.lista;}
                                | MENOS expresion { comprobarEsEnteroReal($2); $$.tipo = $2.tipo;}
                                | llamada_subprograma {$$.tipo = $1.tipo;}
                                | ID							{entradaTS ent = encontrarEntrada($1.lexema, true); $$.tipo = ent.tipoDato; $$.lista = ent.es_lista;}
                                | constante {$$.tipo = $1.tipo; $$.lista = $1.lista;}
										  | error ;

constante                   : CONSTANTE_BASICA {tipoTmp = $1.tipo; $$.tipo = $1.tipo; $$.lista = false;}
                                | CORCHETE_ABRE contenido_lista CORCHETE_CIERRA {tipoTmp = $2.tipo; $$.tipo = $2.tipo; $$.lista = true;} ;

contenido_lista             : contenido_lista_preced CONSTANTE_BASICA {comprobarEsTipo($2.tipo, $1.tipo); $$.tipo = $1.tipo;}
                                | CONSTANTE_BASICA {$$.tipo = $1.tipo;}
                                | ;

contenido_lista_preced      : contenido_lista_preced CONSTANTE_BASICA COMA {comprobarEsTipo($2.tipo, $1.tipo); $$.tipo = $2.tipo;}
                                | CONSTANTE_BASICA COMA {$$.tipo = $1.tipo;};


llamada_subprograma         : ID PARENTESIS_ABRE lista_variables_constantes PARENTESIS_CIERRA { $$.tipo =  comprobarLlamadaFuncion($1);} ;



declar_subprogramas         : declar_subprogramas declar_subp
                                | ;

declar_subp                 : cabecera_subp {subprog = true;}
									 	bloque  {subprog = false;} ;

cabecera_subp               : tipo ID PARENTESIS_ABRE parametros PARENTESIS_CIERRA {tipoSubprog = $1.tipo; TS_InsertaSUBPROG($2);  }
									 | error;

tipo                        : TIPO_BASICO {listaTmp = false; tipoTmp = $1.tipo; }
                                | LISTADE TIPO_BASICO {listaTmp = true; tipoTmp = $2.tipo;}
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
                                | ID ASIGNACION expresion PYC { comprobarEsTipo(encontrarEntrada($1.lexema, true).tipoDato, $3.tipo); comprobarAsignacionListas($1, $3);}
                                | SI PARENTESIS_ABRE expresion PARENTESIS_CIERRA sentencia {comprobarEsTipo(booleano, $3.tipo); }
                                | SI PARENTESIS_ABRE expresion PARENTESIS_CIERRA sentencia SINO sentencia {comprobarEsTipo(booleano, $3.tipo); }
                                | MIENTRAS PARENTESIS_ABRE expresion PARENTESIS_CIERRA sentencia {comprobarEsTipo(booleano, $3.tipo); }
                                | REPETIR sentencia MIENTRAS PARENTESIS_ABRE expresion PARENTESIS_CIERRA PYC {comprobarEsTipo(booleano, $5.tipo); }
                                | DEVUELVE expresion PYC {comprobarDevuelveSubprog($2);}
                                | ID AVANZAR PYC		{ comprobarEsLista($1); }
                                | ID RETROCEDER PYC { comprobarEsLista($1); }
                                | DOLAR ID PYC { comprobarEsLista($2); }
                                | ENTRADA lista_variables PYC
										  | llamada_subprograma PYC
                                | SALIDA lista_expresiones_o_cadena PYC ;

lista_variables             : lista_variables COMA ID {comprobarEsVarOParamametroFormal($3);}
                                | ID {comprobarEsVarOParamametroFormal($1);} ;


lista_variables_constantes  : lista_variables_constantes COMA ID { TS_subprog_inserta($3);}
                                | lista_variables_constantes COMA constante { TS_subprog_inserta($3);}
                                | constante { TS_subprog_inserta($1);}
                                | ID { TS_subprog_inserta($1);}
										  | ;

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


// Funcion para insertar un atributo en la tabla de simbolos
void TS_InsertaIDENT(atributos atributo){

	//printf("Identificador %s\n\n", atributo.lexema.c_str());

	// preparamos la nueva entrada
	entradaTS nueva_entrada;

	// es de tipo variable
	nueva_entrada.entrada = variable;

	// y tiene el nombre del atributo dado
	nueva_entrada.nombre = atributo.lexema;

	// ponemos parametros a 0 porque no este a basura
	nueva_entrada.parametros = 0;

	nueva_entrada.es_lista = listaTmp;

	// el tipo es el leido en la variable temporal en yacc
	nueva_entrada.tipoDato = tipoTmp;


	// pasamos a buscar si se ha declarado otro con el mismo nombre dentro de la
	// misma marca
	int pos_id_buscado = TOPE - 1;
	bool encontrado = false;

	while ( pos_id_buscado >= 0 && TS[pos_id_buscado].entrada != marca && !encontrado) {

		if ( atributo.lexema == TS[pos_id_buscado].nombre ) {
			encontrado = true;
		} else {
			pos_id_buscado--;
		}
	}

	// si no se ha declarado, lo añadimos
	if ( !encontrado ) {

		TS[TOPE] = nueva_entrada;

		incrementaTOPE();

	} else {
		// si se ha declarado antes, mostramos un error
		// como los parametros de funciones son añadidos tras la marca de bloque, se tendrá en cuenta sus redeclaraciones
		printf("Error semantico en la linea %d: Redeclaración de '%s'\n", num_linea, atributo.lexema.c_str());
	}


}

// funcion para insertar el comienzo de bloque
void TS_InsertaMARCA(){

	// preparamos la nueva entrada, que sera una marca
	entradaTS nueva_entrada;

	nueva_entrada.entrada = marca;

	// metemos cadena vacia siempre al meter algo, por si encontramos sin querer
	// por el tema de basura
	nueva_entrada.nombre = "";
	nueva_entrada.tipoDato = no_asignado;

	// la introducimos en la pila, y la incrementamos el tope
	TS[TOPE] = nueva_entrada;

	incrementaTOPE();

	// si estamos en un subprograma, debemos añadir los parametros formales
	// como variables. Tambien vaciamos la pila de parametros ya que es el
	// ultimo paso en el que la usamos
	if ( subprog ){

		// mientras queden elementos en la pila
		while (TOPE_PARAMF > 0){
			// simplemente vamos volcandolos, decrementando un contador e
			// incrementando otro

			// lo ponemos como variable, como nos pide el guion
			entradaTS entrada_tmp = TS_paramf[TOPE_PARAMF - 1];
			entrada_tmp.entrada = variable;
			TS[TOPE] = entrada_tmp;

			TOPE_PARAMF--;
			incrementaTOPE();
		}
	}

}

// vaciar las entradas de la pila hasta la ultima marca
void TS_VaciarENTRADAS(){

	// simplemente decrementamos el tope hasta llegar a la marca
	while ( TS[TOPE - 1].entrada != marca && TOPE > 0 ){
		TOPE--;
	}

	// tambien eliminamos la marca
	TOPE--;

}

// funcion para añadir un subprograma
void TS_InsertaSUBPROG(atributos atributo){

	// buscamos si ya está añadida una entrada con el mismo lexema
	dtipo tipo_buscar = encontrarEntrada(atributo.lexema, false).tipoDato;

	// si no lo ha encontrado, lo añadimos
	if ( tipo_buscar == desconocido ){
		// sera una funcion, en principio con 0 parametros, y del tipo leido temporalmente
		entradaTS nueva_entrada;

		nueva_entrada.entrada = funcion;

		nueva_entrada.nombre = atributo.lexema;

		nueva_entrada.parametros = 0;

		nueva_entrada.tipoDato = tipoSubprog;

		TS[TOPE] = nueva_entrada;

		incrementaTOPE();

	} else {
		// si lo ha encontrado en la tabla de simbolos, imprime un error por la
		// redefinicion
		printf("\nError semantico en la linea %d. Redefinición de '%s'\n", num_linea, atributo.lexema.c_str());
	}


	// volcamos la pila de parametros, dejamos TOPE_PARAMF ya que necesitamos
	// añadir los parametros como si fueran variables al comenzar el bloque
	// la pila de paramtros se vaciará al meter la marca de bloque, ya que
	// necesitamos meter los parametros como variables
	int num_params = TOPE_PARAMF;
	// TOPE-1 es la funcion, así que antes de meter los parametros establecemos
	// el número de parámetros que tiene
	TS[TOPE - 1].parametros = num_params;
	while (num_params > 0){
		TS[TOPE] = TS_paramf[num_params - 1];

		num_params--;
		incrementaTOPE();
	}


}

// insertamos un parametro formal, utilizaremos una pila auxiliar
// ya que si no introducirá los parametros antes del subprograma
void TS_InsertaPARAMF(atributos atributo){

	bool encontrado = false;

	int n_params = TOPE_PARAMF - 1;

	// buscamos si ya existe un parametro con ese nombre
	while ( n_params > 0 && !encontrado ) {

		encontrado = atributo.lexema == TS_paramf[n_params].nombre;

		n_params--;
	}

	// si no existe lo añadimos
	if ( !encontrado ) {

		entradaTS nueva_entrada;

		nueva_entrada.entrada = parametro_formal;

		nueva_entrada.nombre = atributo.lexema;

		nueva_entrada.parametros = 0;

		nueva_entrada.tipoDato = tipoTmp;

		TS_paramf[TOPE_PARAMF] = nueva_entrada;

		TOPE_PARAMF++;

	} else {
		// si existe lo añadimos
		printf("Error semantico en la linea %d: El parámetro %s ya existe\n", num_linea, atributo.lexema.c_str());
	}

}


// funcion para encontrar una entrada en toda la pila
// muchas veces no la usamos porque solo buscamos hasta la marca anterior
entradaTS encontrarEntrada(string nombre, bool quiero_que_este) {
	// devuelve la posicion de una entrada con mismo nombre, -1 si no la encuentra

	int pos_actual = TOPE - 1;
	entradaTS entrada;

	entrada.tipoDato = desconocido;

	while ( (TS[pos_actual].nombre != nombre || TS[pos_actual].entrada == parametro_formal ) && pos_actual >= 0 ) {
		// son distintos, seguimos buscando
		pos_actual-- ;
	}

	// si lo encontramos, devolvemos el tipo encontrado
	if ( pos_actual != -1 ) {
		entrada = TS[pos_actual];
	} else if (quiero_que_este) {
		printf("\nError semantico en la linea %d. Identificador '%s' no declarado\n", num_linea, nombre.c_str());
	}

	return entrada;

}

// incrementar el tope de la pila contemplando que se puede llenar
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

// comprobamos si un lexema es de una función o no
bool esFuncion(string nombre){
	bool es_funcion = false;
	bool encontrado = false;

	int pos = TOPE - 1;

	while ( pos > 0 && !encontrado ) {
		if ( nombre == TS[pos].nombre ) {
			encontrado = true;
			es_funcion = TS[pos].entrada == funcion;
		}

		pos --;
	}

	return es_funcion;

}

// comprobamos si es una variable o parametro formal, si no lo es damos un error
void comprobarEsVarOParamametroFormal(atributos atrib) {

	// simplemente buscamos en la pila
	dtipo t = encontrarEntrada(atrib.lexema, true).tipoDato;

	// y si es desconocido, no asignado, o una funcion, damos el error
	if ( t == desconocido || t == no_asignado || esFuncion(atrib.lexema) ){
		printf("Error semantico en la linea %d: Esperado variables, parametro formal o constante.\n", num_linea);
	}
}

// comprobamos si dos tipos coinciden, y si no mostramos un error
void comprobarEsTipo(dtipo tipo, dtipo tipo2){


	if (tipo != tipo2) {

		printf("Error semantico en la linea %d: Esperado tipo %s, encontrado tipo %s\n", num_linea, tipoAstring(tipo).c_str(), tipoAstring(tipo2).c_str());
	}
}

// funcion para pasar el tipo a string, para usarlo en mensajes de salida
string tipoAstring(dtipo tipo){

	string tipo_str = "desconocido";

	if ( tipo == real ) {
		tipo_str = "real";
	} else if (tipo == entero) {
		tipo_str = "entero";
	} else if ( tipo == booleano ) {
		tipo_str = "booleano";
	} else if ( tipo == caracter ) {
		tipo_str = "caracter";
	}

	return tipo_str;
}


void comprobarEsLista(atributos atrib) {


	entradaTS entrada = encontrarEntrada(atrib.lexema, true);

	if ( !entrada.es_lista ) {
		printf("Error semantico en la linea %d: Operación solo aplicable a una lista.\n", num_linea);
	}

}


dtipo comprobarLlamadaFuncion(atributos atrib) {

	dtipo tipo_funcion = desconocido;

	// comprobamos que el lexema existe en la tabla de simbolos
	entradaTS entrada_funcion = encontrarEntrada(atrib.lexema, true);
	dtipo existe = entrada_funcion.tipoDato;

	// si existe la entrada, y no es una funcion, sacamos un error de llamada
	if ( existe != desconocido && entrada_funcion.entrada != funcion ){
		printf("Error semantico en la linea %d: %s no es una funcion\n", num_linea, entrada_funcion.nombre.c_str());

	} else if ( existe != desconocido ) {

		// buscamos la posicion donde comiznan los parametros formales
		int pos_entrada = TOPE - 1;

		while ( entrada_funcion.nombre != TS[pos_entrada].nombre || TS[pos_entrada].entrada != funcion ) {
			pos_entrada--;
		}


		int pos_funcion = pos_entrada;

		// comprobamos la pila al reves, porque al volcarla se le dio la vuelta
		pos_entrada += TS[pos_funcion].parametros;

		// si el numero de parámetros de la definicion no coincide con el numero
		// de parametros dados en la llamada
		if (TS[pos_funcion].parametros != TOPE_SUBPROG){
			printf("Error semantico en la linea %d: La funcion %s necesita %d parámetros y se han proporcionado %d\n", num_linea, entrada_funcion.nombre.c_str(), entrada_funcion.parametros, TOPE_SUBPROG);
		} else {

			// pasamos al primer parámetro
			int num_parametros = 0;

			// para todos los parametros dados
			while ( num_parametros < TOPE_SUBPROG ) {

				entradaTS parametro_en_TS;

				parametro_en_TS.tipoDato = TS_llamadas_subprog[num_parametros].tipo;


				if ( TS_llamadas_subprog[num_parametros].lexema != "" ){
					// buscamos el parametro en la tabla de simbolos
					// diciendo que es necesario que lo encuentre
					parametro_en_TS = encontrarEntrada(TS_llamadas_subprog[num_parametros].lexema, true);

				}

				// si el tipo encontrado no es del tipo esperado, sacamos el error
				// por pantalla
				if ( TS[pos_entrada].tipoDato != parametro_en_TS.tipoDato ){

					string tipo_esperado = tipoAstring(TS[pos_entrada].tipoDato);
					string tipo_encontrado = tipoAstring(parametro_en_TS.tipoDato);

					printf("Error semantico en la linea %d: El parámetro %d es de tipo %s pero se espera un tipo %s en la llamada a %s\n", num_linea , num_parametros + 1, tipo_encontrado.c_str(), tipo_esperado.c_str(), entrada_funcion.nombre.c_str());
				}

				// seguimos al siguiente parametro
				num_parametros++;
				pos_entrada--;
			}

			tipo_funcion = entrada_funcion.tipoDato;

		}

	}

	// una vez comprobados todos, vaciamos la pila de parametros
	TOPE_SUBPROG = 0;

	return tipo_funcion;

}


void TS_subprog_inserta(atributos atrib) {

	if ( TOPE_SUBPROG == MAX_TS ) {
		printf("ERROR: Tope de la pila alcanzado. Demasiadas entradas en la tabla de símbolos. Abortando compilación");
	} else {
		TS_llamadas_subprog[TOPE_SUBPROG] = atrib;

		TOPE_SUBPROG++;

	}

}

void comprobarDevuelveSubprog(atributos atrib) {

	entradaTS funcion_actual;

	int entrada = TOPE - 1;

	// nos vamos hasta la ultima marca
	while ( entrada > 0 && TS[entrada].entrada != marca) {
		entrada--;
	}

	// nos vamos a la funcion de justo antes la marca
	while ( entrada > 0 && TS[entrada].entrada != funcion) {
		entrada--;
	}



	if ( entrada == 0 ){
		printf("Error semantico en la linea %d: No se puede devolver un valor en la seccion principal\n", num_linea);
	} else {
		comprobarEsTipo(TS[entrada].tipoDato, atrib.tipo);
	}

}


dtipo comprobarOpBinario(atributos izq, atributos operador, atributos der) {

	dtipo tipo_exp = desconocido;

	string t_izq = tipoAstring(izq.tipo);
	string t_der = tipoAstring(der.tipo);

	// operadores de + * / y relacion
	if ( (operador.atrib >= 0 && operador.atrib <= 2) ||
		  ( operador.atrib >= 6 && operador.atrib <= 9  )) {

		if ( izq.lista ) {
			if ( der.lista ) {
				printf("Error semantico en la linea %d: No se puede aplicar el operador entre dos listas\n", num_linea);
			} if ( der.tipo != entero && der.tipo != real) {
				printf("Error semantico en la linea %d: Operador solo aplicable a enteros o reales, encontrados tipos lista de %s y %s\n", num_linea, t_izq.c_str(), t_der.c_str());
			}

		} else if ( der.lista ){

			 if ( izq.tipo != entero && izq.tipo != real ) {
				printf("Error semantico en la linea %d: Operador solo aplicable a enteros o reales, encontrados tipos %s y lista de %s\n", num_linea, t_izq.c_str(), t_der.c_str());
			}

		} else {
			// tiene que ser entero o real y del mismo tipo
			if ( (izq.tipo != entero && izq.tipo != real) || (der.tipo != entero && der.tipo != real) ) {
				printf("Error semantico en la linea %d: Operador solo aplicable a enteros o reales, encontrados tipos %s y %s\n", num_linea, t_izq.c_str(), t_der.c_str());
			} else {
				// comprobamos que izq y der son del mismo tipo
				comprobarEsTipo(izq.tipo, der.tipo);
			}
		}

	} else if (operador.atrib == 10 || operador.atrib == 11){
		// operaciones de comprobar si son iguales o distintos, aplicables a todos los tipos
		comprobarEsTipo(izq.tipo, der.tipo);

	} else if ( operador.atrib >= 3 && operador.atrib <= 5 ) {
		if ( izq.tipo != booleano && der.tipo != booleano ){
			printf("Error semantico en la linea %d: Operador solo aplicable a booleanos, encontrados tipos %s y %s\n", num_linea, t_izq.c_str(), t_der.c_str());
		} else {
			// comprobamos que izq y der son del mismo tipo
			comprobarEsTipo(izq.tipo, der.tipo);
		}

	// operador l--x l%x
	} else if ( operador.atrib == 12 || operador.atrib == 13){
		comprobarEsLista(izq);
		comprobarEsTipo(entero, der.tipo);
	} else if ( operador.atrib == 14 ) {
		comprobarEsLista(izq);
		comprobarEsLista(der);
	}

	if ( operador.atrib >= 3 && operador.atrib <= 11 ){
		tipo_exp = booleano;

	} else {
		tipo_exp = izq.tipo;

	}

	return tipo_exp;

}

dtipo comprobarOpBinarioMenos(atributos izq, atributos der) {
	if ( (izq.tipo != entero && izq.tipo != real) || (der.tipo != entero && der.tipo != real) ){
		string t_izq = tipoAstring(izq.tipo);
		string t_der = tipoAstring(der.tipo);
		printf("Error semantico en la linea %d: Operador solo aplicable a enteros o reales, encontrados tipos %s y %s\n", num_linea, t_izq.c_str(), t_der.c_str());
	} else {
		// comprobamos que izq y der son del mismo tipo
		comprobarEsTipo(izq.tipo, der.tipo);
	}

	return izq.tipo;

}

dtipo comprobarEsEnteroReal (atributos atrib){
	if ( atrib.tipo != entero && atrib.tipo != real){
		string t = tipoAstring(atrib.tipo);
		printf("Error semantico en la linea %d: Operador solo aplicable a enteros o reales, encontrado tipo %s\n", num_linea, t.c_str());
	}
	return atrib.tipo;
}

dtipo comprobarOpUnarios( atributos exp ){

	entradaTS entrada;
	dtipo tipo_a_devolver;

	if ( exp.lexema != "" ) {
		entrada = encontrarEntrada(exp.lexema, true);
	}

	// operador !
	if ( exp.atrib == 0 ) {
		comprobarEsTipo(booleano, exp.tipo);
		tipo_a_devolver = booleano;
	// operador # y ?
	} else {
		comprobarEsLista(exp);
		tipo_a_devolver = exp.tipo;
	}

	return tipo_a_devolver;

}


void comprobarAsignacionListas(atributos id, atributos exp){
	entradaTS entrada_id = encontrarEntrada(id.lexema, true);

	if ( entrada_id.es_lista && !exp.lista ){
		printf("Error semantico en la linea %d: Asignando tipo basico a una lista\n", num_linea);
	} else if ( !entrada_id.es_lista && exp.lista ){
		printf("Error semantico en la linea %d: Asignando lista a un tipo basico\n", num_linea);
	}

}



