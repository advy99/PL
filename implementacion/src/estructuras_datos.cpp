#include <stdio.h>
#include <string.h>
#include "estructuras_datos.h"

void TS_InsertaIDENT(char * identificador){
	printf("Identificador %d", identificador);

	entradaTS nueva_entrada;

	nueva_entrada.entrada = tipoEntrada::funcion;

	strcpy(nueva_entrada.nombre, identificador );

	nueva_entrada.parametros = 0;

	nueva_entrada.tipoDato = tipoTmp;

	TS[TOPE] = nueva_entrada;

	incrementaTOPE();


}

void TS_InsertaMARCA(){

	entradaTS nueva_entrada;

	nueva_entrada.entrada = tipoEntrada::marca;

	// metemos cadena vacia siempre al meter algo, por si encontramos sin querer
	// por el tema de basura
	strcpy(nueva_entrada.nombre, "" );

	TS[TOPE] = nueva_entrada;

	incrementaTOPE();
}

void TS_VaciarENTRADAS(){

	// lo mismo habria que comprobar si ha llegado a encontrar
	// la marca, por el tema de error semantico si tenemos un cierra llave

	while ( TS[TOPE].entrada != tipoEntrada::marca && TOPE > 0 ){
		TOPE--;
	}

}

void TS_InsertaSUBPROG(char * subprograma){


	dtipo tipo_buscar = encontrarEntrada(subprograma);

	if ( tipo_buscar == dtipo::desconocido ){
		entradaTS nueva_entrada;

		nueva_entrada.entrada = tipoEntrada::funcion;

		strcpy(nueva_entrada.nombre, subprograma );

		nueva_entrada.parametros = 0;

		nueva_entrada.tipoDato = tipoTmp;

		TS[TOPE] = nueva_entrada;

		subprog = TOPE;

		incrementaTOPE();

	} else {
		printf("\nError semantico en la linea %d. Redefinición de '%s'\n", num_linea, subprograma);
	}



}

void TS_InsertaPARAMF(char * parametro){
	// aqui hay que utilizar TOPE	- 1 porque es sobre la funcion que hemos añadido antes

	entradaTS nueva_entrada;

	nueva_entrada.entrada = tipoEntrada::parametro_formal;

	strcpy(nueva_entrada.nombre, parametro );

	nueva_entrada.parametros = 0;

	nueva_entrada.tipoDato = tipoTmp;

	TS[TOPE] = nueva_entrada;

	TS[subprog].parametros++;

	incrementaTOPE();

}



dtipo encontrarEntrada(char * nombre) {
	// devuelve la posicion de una entrada con mismo nombre, -1 si no la encuentra

	int pos_actual = TOPE;
	dtipo tipo = dtipo::desconocido;

	while ( strcmp(TS[pos_actual].nombre, nombre ) != 0 ) {
		// son distintos, seguimos buscando
		pos_actual-- ;
	}

	if ( pos_actual != -1 ) {
		tipo = TS[pos_actual].tipoDato;
	} else {
		printf("\nError semantico en la linea %d. Identificador '%s' no declarado\n", num_linea, nombre);
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


