
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define MAX_WORD_LENGTH 100
#define MAX_WORDS 7


cudaError_t histogram(int *histogram, char words);


__global__ void createHistogram(const char* words, int* histogram, int numWords) {
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;

	for (int i = tid; i < numWords; i += stride) {
		atomicAdd(&histogram[words[i]], 1);
	}
}

void print_array(int* a) {
	int i;
	printf("[-] histogram: ");
	for (i = 0; i < NUM_CLASSES; ++i) {
		printf("%d, ", a[i]);
	}
	printf("\b\b  \n");
}


int main()
{
	char words[MAX_WORDS][MAX_WORD_LENGTH] = { "alex","bruce","calvin","daniel","ethan",
		"ford","gale" };
	int numWords = 0;

	char* histogram = (char*)malloc(n * sizeof(char*));

	size_t maxWordLength = 0;
	for (int i = 0; i < numWords; i++) {
		size_t len = strlen(words[i]);
		if (len > maxWordLength) {
			maxWordLength = len;
		}

	histogram(histogram, words, n);

	print_array(histogram);

    return 0;
}


cudaError_t histogram(int *histogram, char words, int n)
{
	char* deviceWords;
	cudaMalloc((void**)&deviceWords, numWords * MAX_WORD_LENGTH * sizeof(char));
	cudaMemcpy(deviceWords, words, numWords * MAX_WORD_LENGTH * sizeof(char), cudaMemcpyHostToDevice);

	int* deviceHistogram;
	cudaMalloc((void**)&deviceHistogram, MAX_WORDS * sizeof(int));
	cudaMemset(deviceHistogram, 0, MAX_WORDS * sizeof(int));

	int blockSize = 256;
	int gridSize = (numWords + blockSize - 1) / blockSize;
	createHistogram << <gridSize, blockSize >> > (deviceWords, deviceHistogram, numWords);

	int* hostHistogram = new int[MAX_WORDS];
	cudaMemcpy(hostHistogram, deviceHistogram, MAX_WORDS * sizeof(int), cudaMemcpyDeviceToHost);

	for (int i = 0; i < numWords; i++) {
		if (hostHistogram[words[i]] > 0) {
			printf("%s: %d\n", words[i], hostHistogram[words[i]]);
		}
	}

	cudaFree(deviceWords);
	cudaFree(deviceHistogram);
	delete[] hostHistogram;

    
    return cudaStatus;
}
