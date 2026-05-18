CC      ?= clang
CSTD    ?= -std=c11
WARN    := -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wstrict-prototypes -Werror
OPT     ?= -O2 -g
CFLAGS  := $(CSTD) $(WARN) $(OPT) -Iinclude

BUILD   := build
SRC     := $(wildcard src/*.c)
OBJ     := $(SRC:src/%.c=$(BUILD)/%.o)
DEP     := $(OBJ:.o=.d)
BIN     := $(BUILD)/engine

.PHONY: all clean test asan ubsan

all: $(BIN)

$(BIN): $(OBJ)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -o $@ $^

$(BUILD)/%.o: src/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -MMD -MP -c -o $@ $<

-include $(DEP)

asan: CFLAGS += -fsanitize=address,undefined -fno-omit-frame-pointer -O1
asan: clean all

ubsan: CFLAGS += -fsanitize=undefined -fno-omit-frame-pointer -O1
ubsan: clean all

test:
	@echo "engine: no tests yet"

clean:
	rm -rf $(BUILD)
