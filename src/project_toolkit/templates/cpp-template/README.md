# template

## Build Instructions (Cross-Compilation)

### Build with MinGW toolchain

```bash
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/mingw-toolchain.cmake ..
make
```

### Build natively (Windows)

```bash
cd build
cmake -S . -B build
cmake --build build --config Release
```

### Run

```bash
./bin/template.exe
```
