%{

#include <cstdlib>
#include <cstdio>
#include <string>

using namespace std;

int num_errores;

FILE * fichero_salida;

FILE * principal = NULL;
FILE * dec_fun = NULL;

int num_etiqueta = 0;
int num_var_temporal = 0;
bool variables_principal = true;

string codigoTmp = "";
string declaracionVar = "";


string codigoPrincipal = "";
string codigoFunc = "";

string cabeceraTmp = "";

string parametros_printf = "";
string parametros_scanf = "";

int yylex();
void yyerror(const char * mensaje);

int num_linea = 1;

#include "estructuras_datos.h"

#define MAX_TS 500

unsigned long int TOPE = 0;
unsigned long int TOPE_PARAMF = 0;
int subprog = 0;
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
;	bool es_constante = false;
	string codigo = "";
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



string tipoAtipoC(dtipo tipo);

void abrirFicherosTraduccion();
void cerrarFicherosTraduccion();

string generarCodigoVariable(atributos tipo, atributos identificador);

string traducirDeclarSubprog(atributos tipo, atributos identificador);

string generarCodigoOPBinarios(atributos * izq, atributos operador, atributos der);
string generarCodigoOPUnarios( atributos operador, atributos * der);

string generarCodigoMientrasRepetir(atributos expresion, atributos sentencias);
string generarCodigoRepetirMientras(atributos sentencias, atributos expresion);

string generarCodigoIf(atributos expresion, atributos sentencia);
string generarCodigoIfElse(atributos expresion, atributos sentencia, atributos sentencia_sino);
string tipoAprintf(dtipo tipo);

string generarEtiqueta();


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

programa					: PRINCIPAL {abrirFicherosTraduccion(); variables_principal = true; }
				 			  bloque { if ( num_errores != 0 ) { codigoPrincipal = "" ; codigoFunc = ""; }; fputs(codigoPrincipal.c_str(), principal); fputs(codigoFunc.c_str(), dec_fun);  cerrarFicherosTraduccion(); };


bloque						: LLAVE_ABRE  {
										TS_InsertaMARCA();
										if ( !variables_principal ) {
											$$.codigo += "{\n";
										};
									}
								  variables {
								  		if ( variables_principal ) {
											$$.codigo += declaracionVar;
											$$.codigo += "\n#include \"dec_fun.c\"\nint main() {  \n";
											$$.codigo += codigoTmp;
											variables_principal = false;
										} else {
											$$.codigo += declaracionVar;
											$$.codigo += codigoTmp;

										};
										declaracionVar = "";
										codigoTmp = "";

									}
								  declar_subprogramas
								  sentencias
								  LLAVE_CIERRA {
								  		TS_VaciarENTRADAS();
										if ( subprog == 0 ) {
											codigoPrincipal = $2.codigo + $4.codigo + $6.codigo +  "}\n";
										} else {
											codigoFunc = $2.codigo + $4.codigo + $6.codigo +  "}\n";
										}
										$$.codigo += $2.codigo + $4.codigo + $6.codigo +  "}\n";
										$2.codigo = "";
										$4.codigo = "";
										$5.codigo = "";
										$6.codigo = "";
									};


variables					: declar_variables {$$.codigo = $1.codigo; }
				 				| ;

declar_variables			: declar_variables cuerpo_declar_var {$$.codigo += $2.codigo; }
						 		| cuerpo_declar_var {$$.codigo += $1.codigo; } ;

cuerpo_declar_var			: VAR tipo ident_variables PYC {
						  				declaracionVar += generarCodigoVariable($2, $3);
									};

ident_variables             : ident_variables COMA ID { TS_InsertaIDENT($3); $$.lexema = $1.lexema + ", " + $3.lexema; }
                                | ident_variables COMA ID ASIGNACION expresion { TS_InsertaIDENT($3); $$.lexema = $1.lexema + ", " + $3.lexema; codigoTmp += $5.codigo + "\n" +  $3.lexema + " = " + $5.lexema + ";\n";  }
                                | ID { TS_InsertaIDENT($1); $$.lexema = $1.lexema; }
										  | ID ASIGNACION expresion {  TS_InsertaIDENT($1); comprobarEsTipo($1.tipo, $3.tipo); comprobarAsignacionListas($1, $3); $$.lexema = $1.lexema; codigoTmp += $3.codigo + "\n" + $1.lexema + " = " + $3.lexema + ";\n"; }
										  | error ;


expresion                   : PARENTESIS_ABRE expresion PARENTESIS_CIERRA {$$.tipo = $2.tipo; $$.lista = $2.lista; $$.lexema = "( " + $2.lexema + " )"; $$.codigo += $2.codigo;}
                                | OP_EXC_UN expresion {$$.tipo = comprobarOpUnarios($2); $$.lista = false; $$.lexema = generarCodigoOPUnarios($1, &$2); $$.codigo += $2.codigo; $2.codigo = "";}
                                | expresion OP_EXC_BIN expresion	{$$.tipo = comprobarOpBinario($1, $2, $3); $$.lista = $1.lista || $3.lista; $$.lexema = generarCodigoOPBinarios(&$1, $2, $3); $$.codigo += $1.codigo;}
                                | expresion MENOS expresion {$$.tipo = comprobarOpBinarioMenos($1, $3); $$.lista = $1.lista || $3.lista;$$.lexema = generarCodigoOPBinarios(&$1, $2, $3); $$.codigo += $1.codigo; }
                                | expresion MASMAS expresion ARROBA expresion {comprobarEsLista($1); comprobarEsTipo($1.tipo, $3.tipo); comprobarEsTipo(entero, $5.tipo); $$.tipo = $1.tipo; $$.lista = $1.lista;$$.lexema = generarEtiqueta();$$.codigo += $1.codigo + $3.codigo + $5.codigo +  "\nLista " + $$.lexema + " = inserta(&" + $1.lexema + ", " + $3.lexema + ", " + $5.lexema + ");\n"; }
                                | MENOS expresion { comprobarEsEnteroReal($2); $$.tipo = $2.tipo; $$.lexema = "-" + $2.lexema; $$.codigo += $2.codigo;}
                                | llamada_subprograma {$$.tipo = $1.tipo; $$.codigo += ""; }
                                | ID							{entradaTS ent = encontrarEntrada($1.lexema, true); $$.tipo = ent.tipoDato; $$.lista = ent.es_lista; $$.lexema = $1.lexema;}
                                | constante {$$.tipo = $1.tipo; $$.lista = $1.lista; $$.lexema = $1.lexema;}
										  | error ;

constante                   : CONSTANTE_BASICA {tipoTmp = $1.tipo; $$.tipo = $1.tipo; $$.lista = false; $$.lexema = $1.lexema; $$.codigo = "";}
                                | CORCHETE_ABRE contenido_lista CORCHETE_CIERRA {tipoTmp = $2.tipo; $$.tipo = $2.tipo; $$.lista = true;} ;

contenido_lista             : contenido_lista_preced CONSTANTE_BASICA {comprobarEsTipo($2.tipo, $1.tipo); $$.tipo = $1.tipo;}
                                | CONSTANTE_BASICA {$$.tipo = $1.tipo;}
                                | ;

contenido_lista_preced      : contenido_lista_preced CONSTANTE_BASICA COMA {comprobarEsTipo($2.tipo, $1.tipo); $$.tipo = $2.tipo;}
                                | CONSTANTE_BASICA COMA {$$.tipo = $1.tipo;};


llamada_subprograma         : ID PARENTESIS_ABRE lista_variables_constantes PARENTESIS_CIERRA { $$.tipo =  comprobarLlamadaFuncion($1); $$.lexema = $1.lexema + "( " + $3.lexema + " )"; $$.codigo = ""; } ;



declar_subprogramas         : declar_subprogramas declar_subp
                                | ;

declar_subp                 : cabecera_subp {subprog += 1; fichero_salida = dec_fun;}
									 	bloque  {subprog -= 1; $$.codigo = ""; if(subprog == 0) { codigoFunc = $1.codigo + codigoFunc; fichero_salida = principal; } else { $$.codigo = $1.codigo + $3.codigo;  }; } ;

cabecera_subp               : tipo ID PARENTESIS_ABRE parametros PARENTESIS_CIERRA {tipoSubprog = $1.tipo; $$.codigo = traducirDeclarSubprog($1, $2); TS_InsertaSUBPROG($2);  }
									 | error;

tipo                        : TIPO_BASICO {listaTmp = false; tipoTmp = $1.tipo; $$.lexema = $1.lexema; }
                                | LISTADE TIPO_BASICO {listaTmp = true; tipoTmp = $2.tipo;}
										  | error ;

parametros                  : parametro
                                | parametro_preced parametro
                                | ;

parametro                   : tipo ID { TS_InsertaPARAMF($2); };

parametro_preced            : parametro_preced parametro COMA
                                | parametro COMA;

sentencias                  : sentencias sentencia { $$.codigo += $2.codigo; }
                                | ;

sentencia                   : bloque {$$.codigo = $1.codigo; }
                                | ID ASIGNACION expresion PYC { comprobarEsTipo(encontrarEntrada($1.lexema, true).tipoDato, $3.tipo); comprobarAsignacionListas($1, $3);$$.codigo += $3.codigo + $1.lexema + " = " + $3.lexema + ";\n";}
                                | SI PARENTESIS_ABRE expresion PARENTESIS_CIERRA sentencia {comprobarEsTipo(booleano, $3.tipo); $$.codigo += generarCodigoIf($3, $5);}
                                | SI PARENTESIS_ABRE expresion PARENTESIS_CIERRA sentencia SINO sentencia {comprobarEsTipo(booleano, $3.tipo); $$.codigo += generarCodigoIfElse($3, $5, $7); }
                                | MIENTRAS PARENTESIS_ABRE expresion PARENTESIS_CIERRA sentencia {comprobarEsTipo(booleano, $3.tipo); $$.codigo += generarCodigoMientrasRepetir($3, $5); }
                                | REPETIR sentencia MIENTRAS PARENTESIS_ABRE expresion PARENTESIS_CIERRA PYC {comprobarEsTipo(booleano, $5.tipo); $$.codigo += generarCodigoRepetirMientras($2, $5); }
                                | DEVUELVE expresion PYC {comprobarDevuelveSubprog($2); $$.codigo += $2.codigo + "\nreturn " + $2.lexema + ";\n "; }
                                | ID AVANZAR PYC		{ comprobarEsLista($1); $$.codigo += "avanzarLista(&" + $2.lexema + "); \n"; }
                                | ID RETROCEDER PYC { comprobarEsLista($1); $$.codigo += "retrocederLista(&" + $2.lexema + "); \n"; }
                                | DOLAR ID PYC { comprobarEsLista($2); $$.codigo += "irAPosicion(&" + $2.lexema + ", 0); \n"; }
                                | ENTRADA lista_variables PYC { $$.codigo = "scanf(\" "  + $2.codigo + "\"," + parametros_scanf + ");\n"; parametros_scanf = ""; }
										  | llamada_subprograma PYC { $$.codigo += $1.lexema + ";\n"; }
                                | SALIDA lista_expresiones_o_cadena PYC { $$.codigo = "printf(\"" + $2.codigo + "\" " + parametros_printf + ");\n" ; parametros_printf = ""; } ;

lista_variables             : lista_variables COMA ID {comprobarEsVarOParamametroFormal($3); parametros_scanf = ", &" + $3.lexema; $$.codigo = $1.codigo + tipoAprintf($3.tipo);}
                                | ID {comprobarEsVarOParamametroFormal($1); parametros_scanf = "&" + $1.lexema; $$.codigo =  tipoAprintf($1.tipo) + $$.codigo; } ;


lista_variables_constantes  : lista_variables_constantes COMA ID { TS_subprog_inserta($3); $$.lexema = $1.lexema + ", " + $3.lexema;}
                                | lista_variables_constantes COMA constante { TS_subprog_inserta($3); $$.lexema = $1.lexema + ", " + $3.lexema;}
                                | constante { TS_subprog_inserta($1); $$.lexema = $1.lexema; }
                                | ID { TS_subprog_inserta($1); $$.lexema = $1.lexema;}
										  | ;

lista_expresiones_o_cadena  : lista_expresiones_o_cadena COMA CADENA {$$.codigo += $3.lexema ;}
									 	  | lista_expresiones_o_cadena COMA expresion {  $$.codigo = $1.codigo + tipoAprintf($3.tipo); parametros_printf += ", " + $3.lexema; }
                                | CADENA 		{ $$.codigo = $1.lexema; }
                                | expresion { $$.codigo =  tipoAprintf($1.tipo); parametros_printf = ", " +  $1.lexema;  };

%%


#include "lex.yy.c"

#include "estructuras_datos.h"

void yyerror(const char *msg)
{
    fprintf(stderr,"[Linea %d]: %s\n", num_linea, msg) ;
	 num_errores++;
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
	 	num_errores++;
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
	if ( subprog != 0 ){

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

	// tambien eliminamos la marca y la cambiamos por el fin de funcion
	TS[TOPE - 1].entrada = fin_bloque;

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
	 	num_errores++;
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
	 	num_errores++;
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
	 	num_errores++;
	}

	return entrada;

}

// incrementar el tope de la pila contemplando que se puede llenar
int incrementaTOPE(){

	int salida = 1;

	if (TOPE == MAX_TS) {
		printf("ERROR: Tope de la pila alcanzado. Demasiadas entradas en la tabla de símbolos. Abortando compilación");
	 	num_errores++;

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
	 	num_errores++;
	}
}

// comprobamos si dos tipos coinciden, y si no mostramos un error
void comprobarEsTipo(dtipo tipo, dtipo tipo2){


	if (tipo != tipo2) {

		printf("Error semantico en la linea %d: Esperado tipo %s, encontrado tipo %s\n", num_linea, tipoAstring(tipo).c_str(), tipoAstring(tipo2).c_str());
	 	num_errores++;
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
	 	num_errores++;
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
	 	num_errores++;

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
	 		num_errores++;
		} else {

			// pasamos al primer parámetro
			int num_parametros = 0;

			// para todos los parametros dados
			while ( num_parametros < TOPE_SUBPROG ) {

				entradaTS parametro_en_TS;

				parametro_en_TS.tipoDato = TS_llamadas_subprog[num_parametros].tipo;


				if ( !TS_llamadas_subprog[num_parametros].es_constante ){
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
	 				num_errores++;
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
	 	num_errores++;
	} else {
		TS_llamadas_subprog[TOPE_SUBPROG] = atrib;

		TOPE_SUBPROG++;

	}

}

void comprobarDevuelveSubprog(atributos atrib) {

	entradaTS funcion_actual;

	int entrada = TOPE - 1;

	bool parar = TS[entrada].entrada == marca && (TS[entrada - 1].entrada == parametro_formal || TS[entrada - 1].entrada == funcion);

	// nos vamos hasta la ultima marca
	while ( entrada > 0 && !parar )  {
		entrada--;
		parar = TS[entrada].entrada == marca && (TS[entrada - 1].entrada == parametro_formal || TS[entrada - 1].entrada == funcion);
	}

	// nos vamos a la funcion de justo antes la marca
	while ( entrada > 0 && TS[entrada].entrada != funcion) {
		entrada--;
	}



	if ( entrada == 0 ){
		printf("Error semantico en la linea %d: No se puede devolver un valor en la seccion principal\n", num_linea);
	 	num_errores++;
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
	 			num_errores++;
			} if ( der.tipo != entero && der.tipo != real) {
				printf("Error semantico en la linea %d: Operador solo aplicable a enteros o reales, encontrados tipos lista de %s y %s\n", num_linea, t_izq.c_str(), t_der.c_str());
	 			num_errores++;
			}

		} else if ( der.lista ){

			 if ( izq.tipo != entero && izq.tipo != real ) {
				printf("Error semantico en la linea %d: Operador solo aplicable a enteros o reales, encontrados tipos %s y lista de %s\n", num_linea, t_izq.c_str(), t_der.c_str());
	 			num_errores++;
			}

		} else {
			// tiene que ser entero o real y del mismo tipo
			if ( (izq.tipo != entero && izq.tipo != real) || (der.tipo != entero && der.tipo != real) ) {
				printf("Error semantico en la linea %d: Operador solo aplicable a enteros o reales, encontrados tipos %s y %s\n", num_linea, t_izq.c_str(), t_der.c_str());
	 			num_errores++;
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
	 		num_errores++;
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
	 	num_errores++;
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
	 	num_errores++;
	}
	return atrib.tipo;
}

dtipo comprobarOpUnarios( atributos exp ){

	entradaTS entrada;
	dtipo tipo_a_devolver;

	if ( !exp.es_constante ) {
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
	 	num_errores++;
	} else if ( !entrada_id.es_lista && exp.lista ){
		printf("Error semantico en la linea %d: Asignando lista a un tipo basico\n", num_linea);
	 	num_errores++;
	}

}


//
//
// FUNCIONES GENERACION CODIGO INTERMEDIO
//
//


void abrirFicherosTraduccion() {

	// abrimos la cabecera
	principal = fopen("salida/principal.c", "w");
	dec_fun = fopen("salida/dec_fun.c", "w");

	fichero_salida = principal;

	// incluimos las bibliotecas básicas que usaremos
	fputs("#include <stdio.h>\n", principal);
	fputs("#include <stdlib.h>\n", principal);
	fputs("#include <string.h>\n", principal);
	fputs("#include <stdbool.h>\n", principal);
	fputs("#include \"dec_data.c\"\n", principal);
	fputs("\n", principal);


	fputs("#ifndef FUNCIONES\n", dec_fun);
	fputs("#define FUNCIONES\n\n", dec_fun);


}

void cerrarFicherosTraduccion() {
	fputs("\n", principal);
	fputs("#endif\n", dec_fun);

	fclose(principal);
	fclose(dec_fun);
}

string tipoAtipoC( dtipo tipo ) {
	string resultado;

	if ( tipo == entero ) {
		resultado = "int ";
	} else if ( tipo == real ) {
		resultado = "float ";
	} else if ( tipo == booleano ) {
		resultado = "bool ";
	} else if ( tipo == caracter ) {
		resultado = "char ";
	} else if ( tipo == vacio ) {
		resultado = "void ";
	}

	return resultado;

}


string generarEtiqueta(){
	string resultado = "etiqueta" + to_string(num_etiqueta);
	num_etiqueta++;

	return resultado;
}

string generarVariableTemporal() {
	string resultado = "tmp" + to_string(num_var_temporal);
	num_var_temporal++;
	return resultado;
}


string generarCodigoVariable(atributos tipo, atributos identificador) {
	string resultado = "";


	if ( listaTmp ) {
		resultado += "Lista ";
	} else {
		resultado += tipoAtipoC(tipo.tipo);
	}


	resultado += identificador.lexema;

	resultado += " ; \n";

	return resultado;
}


string traducirDeclarSubprog(atributos tipo, atributos identificador){

	string resultado = "\n";


	resultado += tipoAtipoC(tipo.tipo);

	resultado += identificador.lexema;

	resultado += "( ";

	for ( int i = 0; i < TOPE_PARAMF; i++) {
		resultado += tipoAtipoC(TS_paramf[i].tipoDato);
		resultado += TS_paramf[i].nombre;
		if ( i < TOPE_PARAMF - 1 ){
			resultado += ", ";
		}
	}

	resultado += ") ";

	return resultado;

}


string generarCodigoOPBinarios(atributos * izq, atributos operador, atributos der) {
	string resultado = generarVariableTemporal();

	string tipo_resultado;

	if ( izq->lista || der.lista ) {

		izq->codigo = der.codigo;
		izq->codigo += "Lista " + resultado + "; \n";

		string operacion;

		if ( operador.atrib == 0 ){
			operacion = "sumaLista";
		} else if ( operador.atrib == 1 ) {
			operacion = "multiplicaLista";
		} else if (operador.atrib == 2) {
			operacion = "divideLista";
		} else {
			operacion = "restaLista";
		}


		if ( izq->lista ) {
			izq->codigo += resultado + " = " + operacion + "(&" + izq->lexema + ", &" + der.lexema + ") ; \n";
		} else {
			izq->codigo += resultado + " = " + operacion + "(&" + der.lexema + ", &" + izq->lexema + ") ; \n";

		}


	} else {
		if ( (operador.atrib >= 0 && operador.atrib <= 2) || operador.lexema == "-" ) {
			tipo_resultado = tipoAtipoC(izq->tipo);
		} else if( operador.atrib >= 3 && operador.atrib <= 11  ) {
			tipo_resultado = "bool ";
		}

		izq->codigo = der.codigo;
		izq->codigo += tipo_resultado + " " + resultado + "; \n";
		izq->codigo += resultado + " = " + izq->lexema + " " + operador.lexema + " " + der.lexema + " ; \n";


	}



	return resultado;

}

string generarCodigoOPUnarios( atributos operador, atributos * der) {

	string resultado = generarVariableTemporal();
	string tipo_resultado;

	if( operador.atrib == 0  ) {
		tipo_resultado = "bool ";
		der->codigo = tipo_resultado + " " + resultado + ";\n";
		der->codigo += resultado + " = " + operador.lexema + " " + der->lexema + " ; \n";
	} else if ( operador.atrib == 1 ) {
		tipo_resultado = "int ";
		der->codigo = tipo_resultado + " " + resultado + ";\n";
		der->codigo += resultado +  " = " + "longitudLista(&" + der->lexema + ");\n";

	} else if ( operador.atrib == 2 ) {
		tipo_resultado = tipoAtipoC(der->tipo);
		der->codigo = tipo_resultado + " " + resultado + ";\n";
		der->codigo += resultado + " = elementoActual(&" + der->lexema + ");\n";
	}


	return resultado;

}

string generarCodigoIf(atributos expresion, atributos sentencia) {

	descriptorInstruccionesControl nueva_entrada;

	nueva_entrada.etiquetaSalida = generarEtiqueta();

	string resultado;

	resultado += expresion.codigo;

	resultado += "if (!" + expresion.lexema + " ) goto " + nueva_entrada.etiquetaSalida + " ;\n";

	resultado += sentencia.codigo;

	resultado += "\n" + nueva_entrada.etiquetaSalida + ": \n;\n";

	return resultado;

}

string generarCodigoIfElse(atributos expresion, atributos sentencia, atributos sentencia_sino) {

	descriptorInstruccionesControl nueva_entrada;

	nueva_entrada.etiquetaSalida = generarEtiqueta();
	nueva_entrada.etiquetaElse = generarEtiqueta();

	string resultado;

	resultado += expresion.codigo;

	resultado += "if (!" + expresion.lexema + " ) goto " + nueva_entrada.etiquetaElse + " ;\n";

	resultado += sentencia.codigo;

	resultado += "\n goto "+  nueva_entrada.etiquetaSalida + ";\n";

	resultado += "\n" + nueva_entrada.etiquetaElse + ": \n;\n";

	resultado += sentencia_sino.codigo;

	resultado += "\n" + nueva_entrada.etiquetaSalida + ": \n;\n";

	return resultado;

}


string tipoAprintf(dtipo tipo) {
	string resultado;

	if ( tipo == entero ) {
		resultado = "%d";
	} else if ( tipo == real ) {
		resultado = "%f";
	} else if ( tipo == booleano ) {
		resultado = "%d";
	} else if ( tipo == caracter ) {
		resultado = "%c";
	}

	return resultado;

}

string generarCodigoMientrasRepetir(atributos expresion, atributos sentencias) {

	descriptorInstruccionesControl nueva_entrada;

	nueva_entrada.etiquetaEntrada = generarEtiqueta();
	nueva_entrada.etiquetaSalida = generarEtiqueta();

	string resultado;

	resultado += nueva_entrada.etiquetaEntrada + ": \n;\n";

	resultado += expresion.codigo;

	resultado += "if (!" + expresion.lexema + " ) goto " + nueva_entrada.etiquetaSalida + " ;\n";

	resultado += sentencias.codigo;


	resultado += "goto " + nueva_entrada.etiquetaEntrada + "; \n";

	resultado += "\n" + nueva_entrada.etiquetaSalida + ": \n;\n";

	return resultado;

}


string generarCodigoRepetirMientras(atributos sentencias, atributos expresion) {

	descriptorInstruccionesControl nueva_entrada;

	nueva_entrada.etiquetaEntrada = generarEtiqueta();
	nueva_entrada.etiquetaSalida = generarEtiqueta();

	string resultado;

	resultado += nueva_entrada.etiquetaEntrada + ": \n;\n";

	resultado += sentencias.codigo;

	resultado += expresion.codigo;

	resultado += "if (!" + expresion.lexema + " ) goto " + nueva_entrada.etiquetaSalida + " ;\n";

	resultado += "goto " + nueva_entrada.etiquetaEntrada + "; \n";

	resultado += "\n" + nueva_entrada.etiquetaSalida + ": \n;\n";

	return resultado;

}


