HOME = .
INCLUDE = $(HOME)/include
SRC = $(HOME)/src
BIN = $(HOME)/bin
OBJ = $(HOME)/obj

.PHONY: all clean crear_carpetas

all: crear_carpetas $(BIN)/prueba

crear_carpetas:
	-@mkdir -p $(BIN)


$(BIN)/prueba: $(OBJ)/main.o $(OBJ)/y.tab.o
	gcc -o $@ $^

$(OBJ)/main.o: $(SRC)/main.c
	gcc -c -o $(OBJ)/main.o $(SRC)/main.c -I$(SRC)

$(BIN)/lexico: $(SRC)/lex.yy.c
	lex $^ -o $@ -I$(INCLUDE) -lfl

$(OBJ)/y.tab.o: $(SRC)/y.tab.c
	gcc -c -o $@ $(SRC)/y.tab.c -lfl -I$(SRC)

$(SRC)/y.tab.c: $(SRC)/lexico.l $(SRC)/lex.yy.c
	bison -v -d -o $@ $(SRC)/sintactico.y

$(SRC)/lex.yy.c: $(SRC)/lexico.l
	lex -o $@ $(SRC)/lexico.l

#$(INCLUDE)/y.tab.h: $(SRC)/sintactico.y
#	yacc -d $^ -o $@

clean:
	-rm $(BIN)/*
	-rm $(OBJ)/*.o
	-rm $(SRC)/y.tab.c
	-rm $(SRC)/lex.yy.c
	-rm $(INCLUDE)/y.tab.h

