
SRC_FILES := $(wildcard src/*.jsonnet)
DASHBOARDS := $(patsubst src/%.jsonnet,result/%.json,$(SRC_FILES))

.PHONY: generate format

src/grafonnet-lib/.git:
	git submodule update --init src/grafonnet-lib

result/%.json: src/%.jsonnet src/grafonnet-lib/.git
	jsonnet -o $@ $<

generate: $(DASHBOARDS)

format:
	jsonnetfmt --in-place -- $(SRC_FILES)
