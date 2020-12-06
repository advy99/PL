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


#endif



