CXX=nvcc

CXXFLAGS = -std=c++14 -O3

SOURCES += $(wildcard *.cu)
TARGETS := $(patsubst %.cu, %, $(SOURCES))

all: $(TARGETS)

%: %.cu
	$(CXX) -o $@ $^ $(CXXFLAGS)

clean:
	rm -fv $(TARGETS)

