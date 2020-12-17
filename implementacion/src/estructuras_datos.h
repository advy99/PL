#ifndef ESTRUCTURAS_DATOS
#define ESTRUCTURAS_DATOS

#include <string>

using namespace std;

typedef enum {
	// marca comienzo de bloque
	marca,
	// subprograma
	funcion,
	// si es variable
	variable,
	// si es un parametro formal
	parametro_formal,
	// fin funcion
	fin_bloque
} tipoEntrada;


typedef enum {
	entero,
	real,
	caracter,
	booleano,
	vacio,
	desconocido,
	no_asignado
} dtipo;

typedef struct {
	tipoEntrada entrada;
	string nombre = "";
	string valor = "";
	dtipo tipoDato = no_asignado;
	bool es_lista = false;
	unsigned int parametros;
	int tamDimen;
} entradaTS ;

typedef struct {
	string etiquetaEntrada = "";
	string etiquetaSalida = "";
	string etiquetaElse = "";
	string nombreVarControl = "";
} descriptorInstruccionesControl;

#endif



