# ScaleHLS Project (scalehls)

This project aims to create a framework that ultimately converts an algorithm written in a high level language into an efficient hardware implementation. With multiple levels of intermediate representations (IRs), MLIR appears to be the ideal tool for exploring ways to optimize the eventual design at various levels of abstraction (e.g. various levels of parallelism). Our framework will be based on MLIR, it will incorporate a backend for high level synthesis (HLS) C/C++ code. However, the key contribution will be our parametrization and optimization of a tremendously large design space.

## Quick Start
### 1. Install LLVM and MLIR
**IMPORTANT** This step assumes that you have cloned LLVM from (https://github.com/circt/llvm) to `$LLVM_DIR`. To build LLVM and MLIR, run
```sh
$ mkdir $LLVM_DIR/build
$ cd $LLVM_DIR/build
$ cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="mlir" \
    -DLLVM_TARGETS_TO_BUILD="X86;RISCV" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=DEBUG
$ ninja
$ ninja check-mlir
```

### 2. Install ScaleHLS
This step assumes this repository is cloned to `$SCALEHLS_DIR`. To build and launch the tests, run
```sh
$ mkdir $SCALEHLS_DIR/build
$ cd $SCALEHLS_DIR/build
$ cmake -G Ninja .. \
    -DMLIR_DIR=$LLVM_DIR/build/lib/cmake/mlir \
    -DLLVM_DIR=$LLVM_DIR/build/lib/cmake/llvm \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=DEBUG
$ ninja check-scalehls
```

### 3. Try ScaleHLS
After the installation and test successfully completed, you should be able to play with
```sh
$ export PATH=$SCALEHLS_DIR/build/bin:$PATH
$ cd $SCALEHLS_DIR

$ # Benchmark generation, dataflow-level optimization, and bufferization.
$ benchmark-gen -type "cnn" -config "config/cnn-config.ini" -number 1 \
    | scalehls-opt -legalize-dataflow -split-function \
    -hlskernel-bufferize -hlskernel-to-affine -func-bufferize -canonicalize

$ # HLSKernel lowering, loop-level and pragma-level optimizations, and performance estimation.
$ scalehls-opt test/Conversion/HLSKernelToAffine/test_gemm.mlir -hlskernel-to-affine \
    -affine-loop-perfection -remove-var-loop-bound -partial-affine-loop-tile="tile-level=1 tile-size=4" \
    -convert-to-hlscpp="top-function=test_gemm" -loop-pipelining="pipeline-level=1" \
    -store-op-forward -simplify-memref-access -array-partition -cse -canonicalize \
    -qor-estimation="target-spec=config/target-spec.ini"

$ # HLS C++ code generation.
$ scalehls-opt test/Conversion/HLSKernelToAffine/test_gemm.mlir -hlskernel-to-affine \
    | scalehls-translate -emit-hlscpp
```
You can go through `benchmark-gen`, `scalehls-opt`, and `scalehls-translate` to try the whole flow. We also provide some computation kernel level test cases located at `test/Conversion/HLSKernelToAffine/` for experimenting the ScaleHLS passes and tools.

## Ablation study
If Vivado HLS (2019.1 tested) is installed on your machine, running the following script will report the HLS results for some benchmarks (around 8 hours on AMD Ryzen7 3800X for all 33 tests).

For the `ablation_test_run.sh` script, `-n` determines the number of tests to be processed, the maximum supported value of which is 33; `-c` determines from which test to begin to rerun the C++ synthesis. The generated C++ source code will be written to `sample/cpp_src`; the Vivado HLS project will be established in `sample/hls_proj`; the collected report will be written to `sample/test_results`; the test summary will be generated to `sample`.
```sh
$ cd $SCALEHLS_DIR/sample
$ ./ablation_test_run.sh -n 33 -c 0
```

## References
1. [MLIR documents](https://mlir.llvm.org)
2. [mlir-npcomp github](https://github.com/llvm/mlir-npcomp)
3. [onnx-mlir github](https://github.com/onnx/onnx-mlir)
4. [circt github](https://github.com/llvm/circt)
5. [comba github](https://github.com/zjru/COMBA)
6. [dahlia github](https://github.com/cucapra/dahlia)
