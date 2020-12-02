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
	gcc -c -o $(OBJ)/main.o $(SRC)/main.c -I$(INCLUDE)

$(BIN)/lexico: $(SRC)/lex.yy.c
	gcc $^ -o $@ -I$(INCLUDE) -lfl -I$(INCLUDE)

$(OBJ)/y.tab.o: $(SRC)/y.tab.c
	gcc -c -o $@ $(SRC)/y.tab.c -I$(INCLUDE)

$(SRC)/y.tab.c: $(SRC)/lexico.l $(SRC)/lex.yy.c
	bison -o $@ $(SRC)/sintactico.y

$(SRC)/lex.yy.c: $(SRC)/lexico.l
	lex -o $@ $^

$(INCLUDE)/y.tab.h: $(SRC)/sintactico.y
	bison -d $^ -o $@

clean:
	-rm $(BIN)/*
	-rm $(OBJ)/*.o
	-rm $(SRC)/y.tab.c
	-rm $(SRC)/lex.yy.c
	-rm $(INCLUDE)/y.tab.h

