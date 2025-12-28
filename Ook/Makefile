# Variables
CC = gcc
LEX = flex
YACC = bison
YFLAGS = -d
CFLAGS = -std=c89 -Wall -Wextra -Wno-unused-function -Wno-unneeded-internal-declaration 
# CFLAGS += -DTRACE

# Executable name
TARGET = ook

# Source files
LEX_SRC = ook.l
YACC_SRC = ook.y
GEN_C = y.tab.c lex.yy.c
GEN_H = y.tab.h

# Default target
all: $(TARGET)

# Link the executable
$(TARGET): $(GEN_C)
	$(CC) $(CFLAGS) $(GEN_C) -o $(TARGET)

# Generate Parser (y.tab.c and y.tab.h)
y.tab.c y.tab.h: $(YACC_SRC)
	$(YACC) $(YFLAGS) $(YACC_SRC) -o y.tab.c

# Generate Lexer (lex.yy.c)
lex.yy.c: $(LEX_SRC) y.tab.h
	$(LEX) $(LEX_SRC)

# Clean up generated files
clean:
	rm -f $(TARGET) $(GEN_C) $(GEN_H)

# Test with Hello World
test: $(TARGET)
	./$(TARGET) < hellow.ook

.PHONY: all clean test
