CXX:=g++
CXXFLAGS:=-Wall -Wextra -O3

OBJ:=main.o
BIN:=recollir_dades

$(BIN): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $^

.PHONY: clean

clean:
	rm -f $(OBJ) $(BIN)
