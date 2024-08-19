This project aims to see the performance differences between some basic machine learning algorithms written in Assmebly x86-64, C and Rust.

Each algorithm is called as an external function from C. They should be statically linked at compile time.

Measurements are done using the "RDTSCP" instruction. This instruction reads the current processor count. 
