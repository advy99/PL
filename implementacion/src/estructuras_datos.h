#ifndef ESTRUCTURAS_DATOS
#define ESTRUCTURAS_DATOS


typedef enum {
	// marca comienzo de bloque
	marca,
	// subprograma
	funcion,
	// si es variable
	variable,
	// si es un parametro formal
	parametro_formal
} tipoEntrada;


typedef enum {
	entero,
	real,
	caracter,
	booleano,
	vacio,
	lista,
	desconocido,
	no_asignado
} dtipo;

typedef struct {
	tipoEntrada entrada;
	char * nombre;
	dtipo tipoDato;
	unsigned int parametros;
	int tamDimen;
} entradaTS ;


#define MAX_TS 500

unsigned int TOPE = 0;
unsigned int subprog;
dtipo tipoTmp;


entradaTS TS[MAX_TS];

typedef struct {
	int atrib;
	char * lexema;
	dtipo tipo;
} atributos;

#define YYSTYPE atributos

// falta funciones:
// insertar
// modificar
// consultar

void TS_InsertaIDENT(char * indentificador);

void TS_InsertaMarca();

void TS_VaciarENTRADAS();

void TS_InsertaSUBPROG(char * subprograma);

void TS_InsertaPARAMF(char * parametro);

dtipo encontrarEntrada(char * nombre);

#endif



