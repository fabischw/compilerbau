OUT_DIR := build

ifeq ($(VERBOSE),1)
  BISONFLAGS = -v
endif

all: $(OUT_DIR)/think

# CREATE OUTPUT DIR
$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# GCC
$(OUT_DIR)/think: $(OUT_DIR)/lex.yy.c
	gcc $(OUT_DIR)/lex.yy.c $(OUT_DIR)/grammar.tab.c -o $(OUT_DIR)/think

# LEX
$(OUT_DIR)/lex.yy.c: $(OUT_DIR)/grammar.tab.c lexxer.l | $(OUT_DIR) 
	flex -o $(OUT_DIR)/lex.yy.c lexxer.l

# BISON
$(OUT_DIR)/grammar.tab.c: | $(OUT_DIR)
	bison -d $(BISONFLAGS) -o $(OUT_DIR)/grammar.tab.c grammar.y

# CLEAN
clean: 
	rm $(OUT_DIR)/*
