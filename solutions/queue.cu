#include <cuda.h>

#include <vector>
#include <cstdio>
#include <cstdlib>

template <typename T, std::size_t capacity>
struct queue {
  int size = 0;
  T data[capacity];

  __device__ bool insert(const T& value) {
    int result = atomicAdd(&size, 1);
    if (result >= capacity) {
      // Queue is overflowing.  Do nothing.
      return false;
    } else {
      data[result] = value;
      return true;
    }
  }
};

constexpr size_t queue_size = 1000;

__global__ void kernel(queue<int, queue_size>* queues, int n) {
  size_t tid = threadIdx.x + blockIdx.x*blockDim.x;

  if (tid < n) {
    for (size_t i = 0; i < n; i++) {
      queues[i].insert(tid);
    }
  }
}

int main(int argc, char** argv) {

  constexpr size_t n = queue_size;

  std::vector<queue<int, n>> queues(n);

  queue<int, n>* d_queues;
  cudaMalloc(&d_queues, sizeof(queue<int, n>)*n);

  cudaMemcpy(d_queues, queues.data(), sizeof(queue<int, n>)*n, cudaMemcpyHostToDevice);

  cudaDeviceSynchronize();

  size_t block_size = 256;

  // ceil(grid_size / block_size)
  dim3 grid((n + block_size - 1) / block_size);
  dim3 block(block_size);

  kernel<<<grid, block>>>(d_queues, n);

  cudaMemcpy(queues.data(), d_queues, sizeof(queue<int, n>)*n, cudaMemcpyDeviceToHost);

  bool success = true;

  for (size_t i = 0; i < n; i++) {
    queue<int, n>& queue = queues[i];

    if (queue.size != n) {
      success = false;
      break;
    }
    std::vector<size_t> histogram(n, 0);

    for (size_t i = 0; i < n; i++) {
      if (queue.data[i] < 0 && queue.data[i] >= n) {
        success = false;
        break;
      }
      histogram[queue.data[i]] += 1;
      if (histogram[queue.data[i]] != 1) {
        success = false;
        break;
      }
    }
  }

  if (success) {
    printf("OK!\n");
  } else {
    printf("FAILED.\n");
  }

  cudaDeviceSynchronize();

  cudaFree(d_queues);

  return 0;
}
