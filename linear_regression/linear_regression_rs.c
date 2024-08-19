#include <stdio.h>
#include <stdint.h>

#define MAX_ENTRIES 1339

extern void linear_regression_rs(float x[], float y[], int n, float *slope, float *intercept);

void linear_regression_c(float x[], float y[], int n, float *slope, float *intercept) {
    float sum_xy = 0, sum_x = 0, sum_y = 0, sum_x_squared = 0;

    for (int i = 0; i < n; i++) {
        sum_xy += x[i] * y[i];
        sum_x += x[i];
        sum_y += y[i];
        sum_x_squared += x[i] * x[i];
    }

    *slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x_squared - sum_x * sum_x);
    *intercept = (sum_y - *slope * sum_x) / n;
}

static inline uint64_t rdtscp(){
    uint64_t lo, hi;

    asm volatile ("rdtscp" : "=a"(lo), "=d"(hi));     // read the current processor clock count
    return ((uint64_t)hi << 32) | lo;
}

uint64_t handleOverflow(uint64_t start, uint64_t stop){
    uint64_t elapsed;
    if (stop < start) {
        stop += UINT64_MAX - start;
	return stop;
    }
    else
        return stop - start;
}

int readCSV(const char *filename, float x[], float y[]) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        fprintf(stderr, "Error opening file %s\n", filename);
        return -1; // Error opening file
    }

    int row = 0;
    while (fscanf(file, "%f,%f\n", &x[row], &y[row]) == 2) {
        row++;
        if (row >= MAX_ENTRIES) {
            fprintf(stderr, "Exceeded maximum number of rows\n");
            break;
        }
    }

    fclose(file);
    return row; // Return number of rows read
}

int main() {
    const char filename[] = "insurance.csv";

    float x[MAX_ENTRIES], y[MAX_ENTRIES];
    
    uint64_t start = 0, stop = 0;

    float slope, intercept;

    readCSV(filename, x, y);
    start = rdtscp();     
    linear_regression_rs(x, y, MAX_ENTRIES, &slope, &intercept);
    
    stop = rdtscp();

    printf("Linear Regression Equation: y = %.2fx + %.2f\n", slope, intercept);
    printf("%lu", handleOverflow(start, stop));

    return 0;
}

