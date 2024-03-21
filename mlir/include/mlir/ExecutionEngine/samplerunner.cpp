#include "CRunnerUtils.h"
#include <fstream>
#include <iostream>
#include <stdio.h>
#include <string>

extern "C" void fun() { printf("Hello there"); }

extern "C" void readCsvColumnFloat(char *filename, _Float32 *data, _Float32 *,
                                   int, int dsize, int, int colid) {
  printf("readCsvColumnInt: filename=%s, colid=%d\n", filename, colid);
}

extern "C" void readCsvColumnInt(char *filename, int8_t *data, int8_t *, int,
                                 int dsize, int, int colid) {
  printf("readCsvColumnInt: filename=%s, colid=%d\n", filename, colid);
  std::ifstream csvfileStream;
  csvfileStream.open(filename);
  std::string line;
    int l = 0;
  while (std::getline(csvfileStream, line) && l < dsize) {
    std::string delimiter = ",";

    size_t pos = 0;
    std::string token;
    int curid = 0;
    while ((pos = line.find(delimiter)) != std::string::npos) {
      token = line.substr(0, pos);
      line.erase(0, pos + delimiter.length());
      if (curid == colid && l > 0) {
        std::cout <<"colid<" << colid << "> " << token << std::endl;
        data[l] = stoi(token);
        break;
      }
      curid++;
    }
    l++;
  }
}

extern "C" void printSeries(char *filename) {
  printf("\nprintSeries: %s\n", filename);
}

extern "C" void
readCsvColumnString(std::string filename,
                    DynamicMemRefType<DynamicMemRefType<char>> dest) {}