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


void irAPosicion(Lista * lista, int posicion) {

	if ( lista->elementos != NULL ){
		while (lista->elementos->anterior != NULL) {
			lista->elementos = lista->elementos->anterior;
		}

		for (  int i = 0; i < posicion; i++ ){
			lista->elementos = lista->elementos->siguiente;
		}

		lista->posicion_actual = posicion;

	}

}

float elementoPosicion(Lista * lista, unsigned int posicion) {

	unsigned int pos_actual = lista->posicion_actual;
	float resultado = 0;

	if ( lista->elementos != NULL ){
		while (lista->elementos->anterior != NULL) {
			lista->elementos = lista->elementos->anterior;

		}
		for ( unsigned int i = 0; i < posicion; i++ ){
			lista->elementos = lista->elementos->siguiente;
		}

		resultado = lista->elementos->elemento;


	}


	irAPosicion(lista, pos_actual);

	return resultado;

}

void insertarElemento(Lista * lista, float elemento, unsigned int posicion) {

	unsigned int pos_actual = lista->posicion_actual;
	irAPosicion(lista, posicion - 1);

	// reservamos memoria para el nuevo nodo
	Nodo * nuevo_nodo = (Nodo *) malloc(sizeof(Nodo));

	nuevo_nodo->anterior = NULL;
	nuevo_nodo->siguiente = NULL;
	nuevo_nodo->elemento = elemento;

	// es el primero que insertamos
	if ( lista->elementos == NULL ){
		lista->elementos = nuevo_nodo;
	} else {
		Nodo * siguiente = lista->elementos->siguiente;

		if ( siguiente != NULL ) {
			siguiente->anterior = nuevo_nodo;
			nuevo_nodo->siguiente = siguiente;
		}

		nuevo_nodo->anterior = lista->elementos;
		lista->elementos->siguiente = nuevo_nodo;

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

void liberarMemoria(Lista * l1) {

	irAPosicion(l1, 0);

	while ( l1->elementos != NULL ){
		Nodo * actual = l1->elementos;
		l1->elementos = l1->elementos->siguiente;
		free(actual);

	}

	l1->elementos = NULL;
	l1->longitud = 0;
	l1->posicion_actual = 0;



}

void avanzarLista(Lista * lista) {
	lista->elementos = lista->elementos->siguiente;
	lista->posicion_actual++;
}

void retrocederLista(Lista * lista) {
	lista->elementos = lista->elementos->anterior;
	lista->posicion_actual--;
}

unsigned int longitudLista(Lista * l){
	return l->longitud;
}

float elementoActual(Lista * l ){
	return elementoPosicion(l, l->posicion_actual);
}

void copiarLista(Lista * origen, Lista * destino){
	liberarMemoria(destino);

	for ( unsigned int i = 0; i < origen->longitud; i++ ){
		insertarElemento(destino, elementoPosicion(origen, i), i);
	}

}

Lista inserta(Lista * lista, float elemento, unsigned int posicion){
	Lista resultado = {NULL, 0, 0};

	copiarLista(lista, &resultado);

	insertarElemento(&resultado, elemento, posicion);

	return resultado;

}




