#include <cuda.h>

#include <vector>
#include <cstdio>
#include <cstdlib>

__global__ void kernel(int* x, int* y, int n) {
  size_t tid = threadIdx.x + blockIdx.x*blockDim.x;

  if (tid < n) {
    x[tid] += y[tid];
  }
}

int main(int argc, char** argv) {

  size_t n = 1000;

  std::vector<int> x(n, 1);
  std::vector<int> y(n, 1);

  int* d_x;
  cudaMalloc(&d_x, sizeof(int)*n);

  int* d_y;
  cudaMalloc(&d_y, sizeof(int)*n);

  cudaMemcpy(d_x, x.data(), sizeof(int)*n, cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, y.data(), sizeof(int)*n, cudaMemcpyHostToDevice);

  cudaDeviceSynchronize();

  size_t block_size = 256;

  // ceil(grid_size / block_size)
  dim3 grid((n + block_size - 1) / block_size);
  dim3 block(block_size);

  kernel<<<grid, block>>>(d_x, d_y, n);

  cudaMemcpy(x.data(), d_x, sizeof(int)*n, cudaMemcpyDeviceToHost);

  cudaDeviceSynchronize();

  bool all_twos = true;
  for (size_t i = 0; i < x.size(); i++) {
    if (x[i] != 2) {
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
