#include<stdio.h>
#include<stdlib.h>

extern FILE * yyin;

int yyparse(void);

FILE * abrir_entrada(int argc, char * argv[] ) {
	FILE * f= NULL;

	if( argc > 1 ) {
		f = fopen(argv[1],"r");
		if (f == NULL) {
			fprintf(stderr,"fichero’%s’noencontrado\n",argv[1]);
			exit(1);
		} else
			printf("leyendofichero’%s’.\n",argv[1]);
	} else
		printf("leyendoentradaestándar.\n");
	return f;
}

/************************************************************/
int main(int argc, char * argv[] ) {
	yyin = abrir_entrada(argc,argv) ;
	return yyparse();
}
