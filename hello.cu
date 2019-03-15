#include <cuda.h>

#include <cstdio>
#include <cstdlib>

__global__ void kernel(size_t n_to_print) {
  // TODO: fill this in with the formula to calculate thread ID
  // size_t tid = ...;

  // TODO: fill in the parameter for this *guard*
  /*
  if (...) {
    printf("Hello from thread %lu!\n", tid);
  }
  */
}

int main(int argc, char** argv) {

  size_t grid_size = 1000;
  size_t block_size = 256;

  // ceil(grid_size / block_size)
  dim3 grid((grid_size + block_size - 1)/ block_size);
  dim3 block(block_size);

  kernel<<<grid, block>>>(grid_size);

  cudaDeviceSynchronize();

  return 0;
}
