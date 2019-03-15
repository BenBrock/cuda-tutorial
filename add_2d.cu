#include <cuda.h>

#include <vector>
#include <cstdio>
#include <cstdlib>

__global__ void kernel(int* x, int* y, int m, int n) {
  // TODO: add formulas for TID in the x and y dimensions.
  // size_t tidx = ...;
  // size_t tidy = ...;

  // TODO: you'll need a guard in two dimensions.
  /*
  if (...) {
    // TODO: Set each element (tidx, tidy) x[tidx,tidy] += y[tidx,tidy]
    x[tidx*n + tidy] += y[tidx*n + tidy];
  }
  */
}

int main(int argc, char** argv) {

  size_t m = 1000;
  size_t n = 1000;

  std::vector<int> x(m*n, 1);
  std::vector<int> y(m*n, 1);

  int* d_x;
  cudaMalloc(&d_x, sizeof(int)*m*n);

  int* d_y;
  cudaMalloc(&d_y, sizeof(int)*m*n);

  cudaMemcpy(d_x, x.data(), sizeof(int)*m*n, cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, y.data(), sizeof(int)*m*n, cudaMemcpyHostToDevice);

  cudaDeviceSynchronize();

  size_t block_size = 16;

  // ceil(grid_size / block_size)
  dim3 grid((m + block_size - 1) / block_size,
            (n + block_size - 1) / block_size);
  dim3 block(block_size, block_size);

  kernel<<<grid, block>>>(d_x, d_y, m, n);

  cudaMemcpy(x.data(), d_x, sizeof(int)*m*n, cudaMemcpyDeviceToHost);

  cudaDeviceSynchronize();

  bool all_twos = true;
  for (size_t i = 0; i < x.size(); i++) {
    if (x[i] != 2) {
      printf("Breaking with %lu == %d\n", i, x[i]);
      all_twos = false;
      break;
    }
  }

  if (all_twos) {
    printf("OK!\n");
  } else {
    printf("FAILED.\n");
  }

  cudaFree(d_x);
  cudaFree(d_y);

  return 0;
}
