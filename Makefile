OUT_DIR := build
SRC_DIR := src

ifeq ($(VERBOSE),1)
  BISONFLAGS = -v
endif

all: $(OUT_DIR)/think

# CREATE OUTPUT DIR
$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# GCC
$(OUT_DIR)/think: $(OUT_DIR)/lex.yy.c $(OUT_DIR)/grammar.tab.c $(SRC_DIR)/*/*.c
	gcc $^ -o $(OUT_DIR)/think

# LEX
$(OUT_DIR)/lex.yy.c: $(OUT_DIR)/grammar.tab.c $(SRC_DIR)/lexxer.l | $(OUT_DIR) 
	flex -o $(OUT_DIR)/lex.yy.c $(SRC_DIR)/lexxer.l

# BISON
$(OUT_DIR)/grammar.tab.c: $(SRC_DIR)/grammar.y | $(OUT_DIR)
	bison -d $(BISONFLAGS) -o $(OUT_DIR)/grammar.tab.c $(SRC_DIR)/grammar.y

# CLEAN
clean: 
	rm $(OUT_DIR)/*
