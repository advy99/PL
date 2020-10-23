HOME = .
INCLUDE = $(HOME)/include
SRC = $(HOME)/src
BIN = $(HOME)/bin

.PHONY: all clean crear_carpetas

all: crear_carpetas $(BIN)/lexico

crear_carpetas:
	-@mkdir -p $(BIN)

$(BIN)/lexico: $(SRC)/lex.yy.c
	gcc $^ -o $@ -I$(INCLUDE) -lfl

$(SRC)/lex.yy.c: $(SRC)/lexico_printf.l
	lex -o $@ $^


clean:
	-rm $(BIN)/lexico

