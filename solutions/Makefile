CXX=nvcc

CXXFLAGS = -std=c++14 -O3 -arch=sm_35

SOURCES += $(wildcard *.cu)
TARGETS := $(patsubst %.cu, %, $(SOURCES))

all: $(TARGETS)

%: %.cu
	$(CXX) -o $@ $^ $(CXXFLAGS)

clean:
	rm -fv $(TARGETS)

