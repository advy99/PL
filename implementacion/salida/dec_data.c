#include <stdlib.h>
#include <stdio.h>

struct nodo {
	struct nodo * siguiente;
	struct nodo * anterior;
	float elemento;
} nodo = {NULL, NULL, 0} ;

struct lista_h {
	struct nodo * elementos;
	unsigned int longitud;
	unsigned int posicion_actual;
} lista_h = {NULL, 0, 0};

typedef struct lista_h Lista;
typedef struct nodo Nodo;


void irAPosicion(Lista * lista, unsigned int posicion) {

	while (lista->elementos->anterior != NULL) {
		lista->elementos = lista->elementos->anterior;
	}

	for ( unsigned int i = 0; i < posicion; i++ ){
		lista->elementos = lista->elementos->siguiente;
	}

	lista->posicion_actual = posicion;

}

float elementoPosicion(Lista * lista, unsigned int posicion) {

	unsigned int pos_actual = lista->posicion_actual;
	float resultado;

	while (lista->elementos->anterior != NULL) {
		lista->elementos = lista->elementos->anterior;

	}

	for ( unsigned int i = 0; i < posicion; i++ ){
		lista->elementos = lista->elementos->siguiente;
	}

	resultado = lista->elementos->elemento;

	irAPosicion(lista, pos_actual);

	return resultado;

}

void insertarElemento(Lista * lista, float elemento, unsigned int posicion) {

	unsigned int pos_actual = lista->posicion_actual;
	irAPosicion(lista, posicion);

	// reservamos memoria para el nuevo nodo
	Nodo * nuevo_nodo = (Nodo *) malloc(sizeof(Nodo));

	nuevo_nodo->anterior = NULL;
	nuevo_nodo->siguiente = NULL;
	nuevo_nodo->elemento = elemento;

	// es el primero que insertamos
	if ( lista->elementos == NULL ){
		lista->elementos = nuevo_nodo;
	} else {
		Nodo * anterior = lista->elementos->anterior;
		anterior->siguiente = nuevo_nodo;
		nuevo_nodo->anterior = anterior;

		Nodo * siguiente = lista->elementos->siguiente;

		// si no lo insertamos al final
		if ( siguiente != NULL ) {
			nuevo_nodo->siguiente = siguiente;
			siguiente->anterior = nuevo_nodo;
		}

	}

	lista->longitud++;

	irAPosicion(lista, pos_actual);


}

Lista sumaLista(Lista * lista, float valor) {
	Lista resultado;

	for ( unsigned int i = 0; i < lista->longitud; i++ ){
		insertarElemento(&resultado, elementoPosicion(lista, i) + valor, i);
	}

	return resultado;
}

Lista restaLista(Lista * lista, float valor) {
	Lista resultado;

	for ( unsigned int i = 0; i < lista->longitud; i++ ){
		insertarElemento(&resultado, elementoPosicion(lista, i) - valor, i);
	}

	return resultado;
}


Lista multiplicaLista(Lista * lista, float valor) {
	Lista resultado;

	for ( unsigned int i = 0; i < lista->longitud; i++ ){
		insertarElemento(&resultado, elementoPosicion(lista, i) * valor, i);
	}

	return resultado;
}

Lista divideLista(Lista * lista, float valor) {
	Lista resultado;

	for ( unsigned int i = 0; i < lista->longitud; i++ ){
		insertarElemento(&resultado, elementoPosicion(lista, i) / valor, i);
	}

	return resultado;
}

Lista eliminarElemento(Lista * lista, unsigned int posicion) {

	Lista resultado;

	for ( unsigned int i = 0; i < posicion; i++ ){
		insertarElemento(&resultado, elementoPosicion(lista, i), i);
	}

	for ( unsigned int i = posicion + 1; i < lista->longitud; i++){
		insertarElemento(&resultado, elementoPosicion(lista, i), i);
	}

	return resultado;

}


Lista concatenaListas(Lista * l1, Lista * l2) {
	Lista resultado;

	for ( unsigned int i = 0; i < l1->longitud; i++ ) {
		insertarElemento(&resultado, elementoPosicion(l1, i), resultado.longitud);
	}

	for ( unsigned int i = 0; i < l2->longitud; i++ ) {
		insertarElemento(&resultado, elementoPosicion(l2, i), resultado.longitud);
	}

	resultado.longitud = l1->longitud + l2->longitud;

	irAPosicion(&resultado, 0);
	irAPosicion(l1, l1->posicion_actual);
	irAPosicion(l2, l2->posicion_actual);

	return resultado;
}

Lista sublista(Lista * lista, unsigned int posicion){
	Lista resultado;

	for ( unsigned int i = 0; i < posicion; i++ ) {
		insertarElemento(&resultado, elementoPosicion(lista, i), resultado.longitud);
	}

	return resultado;

}

void liberarMemoria(Lista * l1, unsigned int posicion) {

	irAPosicion(l1, posicion);

	while ( l1->elementos->siguiente != NULL ){
		Nodo * actual = l1->elementos;
		l1->elementos = l1->elementos->siguiente;
		free(actual);
	}

	// si liberamos toda la lista
	if ( posicion == 0 ){
		free(l1->elementos);
	}

}

void avanzarLista(Lista * lista) {
	lista->elementos = lista->elementos->siguiente;
}

void retrocederLista(Lista * lista) {
	lista->elementos = lista->elementos->anterior;
}

unsigned int longitudLista(Lista * l){
	return l->longitud;
}

float elementoActual(Lista * l ){
	return elementoPosicion(l, l->posicion_actual);
}

