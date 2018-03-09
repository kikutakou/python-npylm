
ifeq ($(shell uname),Darwin)
PYTHON3_CONFIG = /usr/local/bin/python3-config
else
PYTHON3_CONFIG = python3-config
endif

CC = g++
BOOST = /usr/local/Cellar/boost/1.66.0
CXXFLAGS = $(shell $(PYTHON3_CONFIG) --includes) -std=c++14 -I$(BOOST)/include
LDFLAGS = $(shell $(PYTHON3_CONFIG) --ldflags) -lboost_serialization -lboost_python3 -L$(BOOST)/lib
SOFLAGS = -shared -fPIC -march=native
TESTFLAGS = -O0 -g -Wall
SOURCES = $(wildcard src/python.cpp src/python/*.cpp src/npylm/*.cpp src/npylm/lm/*.cpp)
OBJECTS = $(SOURCES:%.cpp=%.o)


install: $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) $(SOFLAGS) -o run/npylm.so -O3
	cp run/npylm.so run/semi-supervised/npylm.so
	cp run/npylm.so run/unsupervised/npylm.so
	rm -rf run/npylm.so

install_ubuntu: ## npylm.soを生成
	$(CC) -Wl,--no-as-needed -Wno-deprecated $(OBJECTS) $(LDFLAGS) $(SOFLAGS) -o run/npylm.so -O3
	cp run/npylm.so run/semi-supervised/npylm.so
	cp run/npylm.so run/unsupervised/npylm.so
	rm -rf run/npylm.so

check_includes:	## Python.hの場所を確認
	@echo $(INCLUDE)

check_ldflags:	## libpython3の場所を確認
	@echo $(LDFLAGS)

module_tests: ## 各モジュールのテスト.
	$(CC) test/module_tests/wordtype.cpp $(SOURCES) -o test/module_tests/wordtype $(INCLUDE) $(LDFLAGS) $(TESTFLAGS)
	./test/module_tests/wordtype
	$(CC) test/module_tests/npylm.cpp $(SOURCES) -o test/module_tests/npylm $(INCLUDE) $(LDFLAGS) $(TESTFLAGS)
	./test/module_tests/npylm
	$(CC) test/module_tests/vpylm.cpp $(SOURCES) -o test/module_tests/vpylm $(INCLUDE) $(LDFLAGS) $(TESTFLAGS)
	./test/module_tests/vpylm
	$(CC) test/module_tests/sentence.cpp $(SOURCES) -o test/module_tests/sentence $(INCLUDE) $(LDFLAGS) $(TESTFLAGS)
	./test/module_tests/sentence
	$(CC) test/module_tests/hash.cpp $(SOURCES) -o test/module_tests/hash $(INCLUDE) $(LDFLAGS) $(TESTFLAGS)
	./test/module_tests/hash
	$(CC) test/module_tests/lattice.cpp $(SOURCES) -o test/module_tests/lattice $(INCLUDE) $(LDFLAGS) $(TESTFLAGS)
	./test/module_tests/lattice

running_tests:	## 運用テスト
	$(CC) test/running_tests/train.cpp $(SOURCES) -o test/running_tests/train $(INCLUDE) $(LDFLAGS) -O0 -g
	$(CC) test/running_tests/save.cpp $(SOURCES) -o test/running_tests/save $(INCLUDE) $(LDFLAGS) $(TESTFLAGS)

.PHONY: clean
clean:
	rm -rf $(OBJECTS)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help