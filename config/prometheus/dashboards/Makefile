
SRC_FILES := $(wildcard src/*.jsonnet)
DASHBOARDS := $(patsubst src/%.jsonnet,result/%.json,$(SRC_FILES))

.PHONY: generate format

src/grafonnet-lib/.git:
	git submodule update --init src/grafonnet-lib

src/%.jsonnet: src/grafonnet-lib/.git

result/%.json: src/%.jsonnet
	jsonnet -o $@ $<

generate: $(DASHBOARDS)

format:
	jsonnetfmt --in-place -- $(SRC_FILES)
