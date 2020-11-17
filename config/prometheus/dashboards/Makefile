
SRC_FILES := $(wildcard src/*.jsonnet)
LIB_FILES := $(wildcard src/*.libsonnet)
DASHBOARDS := $(patsubst src/%.jsonnet,result/%.json,$(SRC_FILES))

.PHONY: generate format

src/grafonnet-lib/.git:
	git submodule update --init src/grafonnet-lib

result/%.json: src/%.jsonnet src/grafonnet-lib/.git $(LIB_FILES)
	jsonnet -o $@ $<

generate: $(DASHBOARDS)

format:
	jsonnetfmt --in-place -- $(SRC_FILES) $(LIB_FILES)
