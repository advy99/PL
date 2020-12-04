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
	lista,
	desconocido,
	no_asignado
} dtipo;

typedef struct {
	tipoEntrada entrada;
	char * nombre;
	dtipo tipoDato;
	unsigned int parametros;
	unsigned int dimensiones;
	int tamDimen1;
	int tamDimen2;
} entradaTS ;


#define MAX_TS 500

unsigned int TOPE = 0;
unsigned int subprog;

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

#endif
