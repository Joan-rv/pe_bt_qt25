CXX:=g++
CXXFLAGS:=-Wall -Wextra

OBJ=main.o

recollir_dades: $(OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $^
