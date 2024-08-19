#include <stdio.h>
#include <math.h>
#include <stdint.h>

#define MAX_ENTRIES 570

extern int knn_asm(double points[][4], int n, int k, double p[]);


/* 
    points[i][0] = x
    points[i][1] = y
    points[i][2] = distance
    points[i][3] = group
 */

void insertionSort(double arr[][4], int n) {
    int i, j;
    double key[4];
    for (i = 1; i < n; i++) {
        key[0] = arr[i][0];
        key[1] = arr[i][1];
        key[2] = arr[i][2];
        key[3] = arr[i][3];

        j = i - 1;

        // Move elements greater than key to one position ahead
        while (j >= 0 && arr[j][2] > key[2]) {
            arr[j + 1][0] = arr[j][0];
            arr[j + 1][1] = arr[j][1];
            arr[j + 1][2] = arr[j][2];
            arr[j + 1][3] = arr[j][3]; 
            j = j - 1;
        }

        // Place the key at its correct position
        arr[j + 1][0] = key[0];
        arr[j + 1][1] = key[1];
        arr[j + 1][2] = key[2];
        arr[j + 1][3] = key[3]; 
    }
}



int knn(double points[][4], int n, int k, double p[]) {
    for (int i = 0; i < n; i++) {
        points[i][2] = sqrt((points[i][0] - p[0]) * (points[i][0] - p[0]) + (points[i][1] - p[1]) * (points[i][1] - p[1]));
    }

    //sort points array by points[][2]. implement the quicksort here
    insertionSort(points, n);

    int freq0 = 0;
    int freq1 = 0;

    for (int i = 0; i < k; i++) {
        if (points[i][3] == 0)
            freq0++;
        else if (points[i][3] == 1)
            freq1++;
    }

    if (freq0 > freq1)
        return 0;
    else
        return 1;
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

int readCSV(const char *filename, double points[][4]) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        fprintf(stderr, "Error opening file %s\n", filename);
        return -1; 
    }

    int row = 0;
    while (fscanf(file, "%lf,%lf,%lf,%*s\n", &points[row][0], &points[row][1], &points[row][3]) == 3) {
        points[row][2] = 0; 
        row++;
        if (row >= MAX_ENTRIES) {
            fprintf(stderr, "Exceeded maximum number of rows\n");
            break;
        }
    }

    fclose(file);
    return row; 
}

int main()
{
    const char filename[] = "points.csv";

    double arr[1000][4];

    readCSV(filename, arr);

    double p[4] = {17.99, 10.38, 0, 1};
    int k = 3;

    uint64_t start = 0, stop = 0;

    start = rdtscp();
    knn_asm(arr, MAX_ENTRIES, k, p);
    stop = rdtscp();

    printf("%lu", handleOverflow(start, stop));

    return 0;
}
