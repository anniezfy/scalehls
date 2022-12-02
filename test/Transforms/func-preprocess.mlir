// RUN: scalehls-opt -scalehls-func-preprocess="top-func=forward" %s | FileCheck %s

// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<1x64x56x56xi8>, %arg1: memref<1000x64xi8>, %arg2: memref<64x64x1x1xi8>, %arg3: memref<64x64x3x3xi8>, %arg4: memref<64x64x3x3xi8>, %arg5: memref<1x1000xi8>) attributes {top_func} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     hls.dataflow.dispatch {
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 1 {
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             affine.for %arg8 = 0 to 56 {
// CHECK:               affine.for %arg9 = 0 to 56 {
// CHECK:                 %4 = affine.load %arg0[0, %arg7, %arg8, %arg9] : memref<1x64x56x56xi8>
// CHECK:                 %5 = arith.cmpi ugt, %4, %c-24_i8 : i8
// CHECK:                 %6 = arith.select %5, %4, %c-24_i8 : i8
// CHECK:                 affine.store %6, %arg0[%arg6, %arg7, %arg8, %arg9] : memref<1x64x56x56xi8>
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x58x58xi8>
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 56 {
// CHECK:             affine.for %arg8 = 0 to 56 {
// CHECK:               %5 = affine.load %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8>
// CHECK:               affine.store %5, %4[0, %arg6, %arg7 + 1, %arg8 + 1] : memref<1x64x58x58xi8>
// CHECK:             } {parallel, point}
// CHECK:           } {parallel, point}
// CHECK:         } {parallel, point}
// CHECK:         affine.for %arg6 = 0 to 1 {
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               affine.for %arg9 = 0 to 28 {
// CHECK:                 affine.for %arg10 = 0 to 64 {
// CHECK:                   affine.for %arg11 = 0 to 3 {
// CHECK:                     affine.for %arg12 = 0 to 3 {
// CHECK:                       %5 = affine.load %4[%arg6, %arg10, %arg8 * 2 + %arg11, %arg9 * 2 + %arg12] : memref<1x64x58x58xi8>
// CHECK:                       %6 = affine.load %arg4[%arg7, %arg10, %arg11, %arg12] : memref<64x64x3x3xi8>
// CHECK:                       %7 = affine.load %0[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:                       %8 = arith.muli %5, %6 : i8
// CHECK:                       %9 = arith.addi %7, %8 : i8
// CHECK:                       affine.store %9, %0[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:                     }
// CHECK:                   }
// CHECK:                 }
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:         affine.for %arg6 = 0 to 1 {
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               affine.for %arg9 = 0 to 28 {
// CHECK:                 %5 = affine.load %0[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:                 %6 = arith.cmpi ugt, %5, %c-24_i8 : i8
// CHECK:                 %7 = arith.select %6, %5, %c-24_i8 : i8
// CHECK:                 affine.store %7, %0[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x30x30xi8>
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 28 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               %5 = affine.load %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               affine.store %5, %4[0, %arg6, %arg7 + 1, %arg8 + 1] : memref<1x64x30x30xi8>
// CHECK:             } {parallel, point}
// CHECK:           } {parallel, point}
// CHECK:         } {parallel, point}
// CHECK:         affine.for %arg6 = 0 to 1 {
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               affine.for %arg9 = 0 to 28 {
// CHECK:                 affine.for %arg10 = 0 to 64 {
// CHECK:                   affine.for %arg11 = 0 to 3 {
// CHECK:                     affine.for %arg12 = 0 to 3 {
// CHECK:                       %5 = affine.load %4[%arg6, %arg10, %arg8 + %arg11, %arg9 + %arg12] : memref<1x64x30x30xi8>
// CHECK:                       %6 = affine.load %arg3[%arg7, %arg10, %arg11, %arg12] : memref<64x64x3x3xi8>
// CHECK:                       %7 = affine.load %1[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:                       %8 = arith.muli %5, %6 : i8
// CHECK:                       %9 = arith.addi %7, %8 : i8
// CHECK:                       affine.store %9, %1[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:                     }
// CHECK:                   }
// CHECK:                 }
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:         affine.for %arg6 = 0 to 1 {
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               affine.for %arg9 = 0 to 28 {
// CHECK:                 affine.for %arg10 = 0 to 64 {
// CHECK:                   affine.for %arg11 = 0 to 1 {
// CHECK:                     affine.for %arg12 = 0 to 1 {
// CHECK:                       %5 = affine.load %arg0[%arg6, %arg10, %arg8 * 2 + %arg11, %arg9 * 2 + %arg12] : memref<1x64x56x56xi8>
// CHECK:                       %6 = affine.load %arg2[%arg7, %arg10, %arg11, %arg12] : memref<64x64x1x1xi8>
// CHECK:                       %7 = affine.load %4[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:                       %8 = arith.muli %5, %6 : i8
// CHECK:                       %9 = arith.addi %7, %8 : i8
// CHECK:                       affine.store %9, %4[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 }
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:         affine.for %arg6 = 0 to 1 {
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               affine.for %arg9 = 0 to 28 {
// CHECK:                 %5 = affine.load %1[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:                 %6 = affine.load %4[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:                 %7 = arith.addi %5, %6 : i8
// CHECK:                 %8 = arith.cmpi ugt, %7, %c-24_i8 : i8
// CHECK:                 %9 = arith.select %8, %7, %c-24_i8 : i8
// CHECK:                 affine.store %9, %2[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 1 {
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             affine.for %arg8 = 0 to 1 {
// CHECK:               affine.for %arg9 = 0 to 1 {
// CHECK:                 affine.for %arg10 = 0 to 28 {
// CHECK:                   affine.for %arg11 = 0 to 28 {
// CHECK:                     %4 = affine.load %2[%arg6, %arg7, %arg8 + %arg10, %arg9 + %arg11] : memref<1x64x28x28xi8>
// CHECK:                     %5 = affine.load %3[%arg6, %arg7, %arg8, %arg9] : memref<1x64x1x1xi8>
// CHECK:                     %6 = arith.addi %5, %4 : i8
// CHECK:                     affine.store %6, %3[%arg6, %arg7, %arg8, %arg9] : memref<1x64x1x1xi8>
// CHECK:                   }
// CHECK:                 }
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:         affine.for %arg6 = 0 to 1 {
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             affine.for %arg8 = 0 to 1 {
// CHECK:               affine.for %arg9 = 0 to 1 {
// CHECK:                 %4 = affine.load %3[%arg6, %arg7, %arg8, %arg9] : memref<1x64x1x1xi8>
// CHECK:                 %5 = arith.divui %4, %c-24_i8 : i8
// CHECK:                 affine.store %5, %3[%arg6, %arg7, %arg8, %arg9] : memref<1x64x1x1xi8>
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x1000xi8>
// CHECK:         affine.for %arg6 = 0 to 1000 {
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             %5 = affine.load %arg1[%arg6, %arg7] : memref<1000x64xi8>
// CHECK:             affine.store %5, %4[%arg7, %arg6] : memref<64x1000xi8>
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:         affine.for %arg6 = 0 to 1000 {
// CHECK:           affine.store %c-24_i8, %arg5[0, %arg6] : memref<1x1000xi8>
// CHECK:         } {parallel, point}
// CHECK:         affine.for %arg6 = 0 to 1 {
// CHECK:           affine.for %arg7 = 0 to 1000 {
// CHECK:             affine.for %arg8 = 0 to 64 {
// CHECK:               %5 = affine.load %3[%arg6, %arg8, 0, 0] : memref<1x64x1x1xi8>
// CHECK:               %6 = affine.load %4[%arg8, %arg7] : memref<64x1000xi8>
// CHECK:               %7 = affine.load %arg5[%arg6, %arg7] : memref<1x1000xi8>
// CHECK:               %8 = arith.muli %5, %6 : i8
// CHECK:               %9 = arith.addi %7, %8 : i8
// CHECK:               affine.store %9, %arg5[%arg6, %arg7] : memref<1x1000xi8>
// CHECK:             }
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:     }
// CHECK:     return
// CHECK:   }
// CHECK: }

module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: memref<1x64x56x56xi8>, %arg1: memref<1000x64xi8>, %arg2: memref<64x64x1x1xi8>, %arg3: memref<64x64x3x3xi8>, %arg4: memref<64x64x3x3xi8>, %arg5: memref<1x1000xi8>) {
    %c-24_i8 = arith.constant -24 : i8
    hls.dataflow.dispatch {
      hls.dataflow.task {
        affine.for %arg6 = 0 to 1 {
          affine.for %arg7 = 0 to 64 {
            affine.for %arg8 = 0 to 56 {
              affine.for %arg9 = 0 to 56 {
                %4 = affine.load %arg0[0, %arg7, %arg8, %arg9] : memref<1x64x56x56xi8>
                %5 = arith.cmpi ugt, %4, %c-24_i8 : i8
                %6 = arith.select %5, %4, %c-24_i8 : i8
                affine.store %6, %arg0[%arg6, %arg7, %arg8, %arg9] : memref<1x64x56x56xi8>
              }
            }
          }
        }
      }
      %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x58x58xi8>
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 56 {
            affine.for %arg8 = 0 to 56 {
              %5 = affine.load %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8>
              affine.store %5, %4[0, %arg6, %arg7 + 1, %arg8 + 1] : memref<1x64x58x58xi8>
            } {parallel, point}
          } {parallel, point}
        } {parallel, point}
        affine.for %arg6 = 0 to 1 {
          affine.for %arg7 = 0 to 64 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 28 {
                affine.for %arg10 = 0 to 64 {
                  affine.for %arg11 = 0 to 3 {
                    affine.for %arg12 = 0 to 3 {
                      %5 = affine.load %4[%arg6, %arg10, %arg8 * 2 + %arg11, %arg9 * 2 + %arg12] : memref<1x64x58x58xi8>
                      %6 = affine.load %arg4[%arg7, %arg10, %arg11, %arg12] : memref<64x64x3x3xi8>
                      %7 = affine.load %0[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
                      %8 = arith.muli %5, %6 : i8
                      %9 = arith.addi %7, %8 : i8
                      affine.store %9, %0[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
                    }
                  }
                }
              }
            }
          }
        }
        affine.for %arg6 = 0 to 1 {
          affine.for %arg7 = 0 to 64 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 28 {
                %5 = affine.load %0[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
                %6 = arith.cmpi ugt, %5, %c-24_i8 : i8
                %7 = arith.select %6, %5, %c-24_i8 : i8
                affine.store %7, %0[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
              }
            }
          }
        }
      }
      %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x30x30xi8>
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 28 {
            affine.for %arg8 = 0 to 28 {
              %5 = affine.load %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              affine.store %5, %4[0, %arg6, %arg7 + 1, %arg8 + 1] : memref<1x64x30x30xi8>
            } {parallel, point}
          } {parallel, point}
        } {parallel, point}
        affine.for %arg6 = 0 to 1 {
          affine.for %arg7 = 0 to 64 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 28 {
                affine.for %arg10 = 0 to 64 {
                  affine.for %arg11 = 0 to 3 {
                    affine.for %arg12 = 0 to 3 {
                      %5 = affine.load %4[%arg6, %arg10, %arg8 + %arg11, %arg9 + %arg12] : memref<1x64x30x30xi8>
                      %6 = affine.load %arg3[%arg7, %arg10, %arg11, %arg12] : memref<64x64x3x3xi8>
                      %7 = affine.load %1[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
                      %8 = arith.muli %5, %6 : i8
                      %9 = arith.addi %7, %8 : i8
                      affine.store %9, %1[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
                    }
                  }
                }
              }
            }
          }
        }
      }
      %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
        affine.for %arg6 = 0 to 1 {
          affine.for %arg7 = 0 to 64 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 28 {
                affine.for %arg10 = 0 to 64 {
                  affine.for %arg11 = 0 to 1 {
                    affine.for %arg12 = 0 to 1 {
                      %5 = affine.load %arg0[%arg6, %arg10, %arg8 * 2 + %arg11, %arg9 * 2 + %arg12] : memref<1x64x56x56xi8>
                      %6 = affine.load %arg2[%arg7, %arg10, %arg11, %arg12] : memref<64x64x1x1xi8>
                      %7 = affine.load %4[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
                      %8 = arith.muli %5, %6 : i8
                      %9 = arith.addi %7, %8 : i8
                      affine.store %9, %4[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
                    }
                  }
                }
              }
            }
          }
        }
        affine.for %arg6 = 0 to 1 {
          affine.for %arg7 = 0 to 64 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 28 {
                %5 = affine.load %1[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
                %6 = affine.load %4[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
                %7 = arith.addi %5, %6 : i8
                %8 = arith.cmpi ugt, %7, %c-24_i8 : i8
                %9 = arith.select %8, %7, %c-24_i8 : i8
                affine.store %9, %2[%arg6, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8>
              }
            }
          }
        }
      }
      %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 1 {
          affine.for %arg7 = 0 to 64 {
            affine.for %arg8 = 0 to 1 {
              affine.for %arg9 = 0 to 1 {
                affine.for %arg10 = 0 to 28 {
                  affine.for %arg11 = 0 to 28 {
                    %4 = affine.load %2[%arg6, %arg7, %arg8 + %arg10, %arg9 + %arg11] : memref<1x64x28x28xi8>
                    %5 = affine.load %3[%arg6, %arg7, %arg8, %arg9] : memref<1x64x1x1xi8>
                    %6 = arith.addi %5, %4 : i8
                    affine.store %6, %3[%arg6, %arg7, %arg8, %arg9] : memref<1x64x1x1xi8>
                  }
                }
              }
            }
          }
        }
        affine.for %arg6 = 0 to 1 {
          affine.for %arg7 = 0 to 64 {
            affine.for %arg8 = 0 to 1 {
              affine.for %arg9 = 0 to 1 {
                %4 = affine.load %3[%arg6, %arg7, %arg8, %arg9] : memref<1x64x1x1xi8>
                %5 = arith.divui %4, %c-24_i8 : i8
                affine.store %5, %3[%arg6, %arg7, %arg8, %arg9] : memref<1x64x1x1xi8>
              }
            }
          }
        }
      }
      hls.dataflow.task {
        %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x1000xi8>
        affine.for %arg6 = 0 to 1000 {
          affine.for %arg7 = 0 to 64 {
            %5 = affine.load %arg1[%arg6, %arg7] : memref<1000x64xi8>
            affine.store %5, %4[%arg7, %arg6] : memref<64x1000xi8>
          }
        }
        affine.for %arg6 = 0 to 1000 {
          affine.store %c-24_i8, %arg5[0, %arg6] : memref<1x1000xi8>
        } {parallel, point}
        affine.for %arg6 = 0 to 1 {
          affine.for %arg7 = 0 to 1000 {
            affine.for %arg8 = 0 to 64 {
              %5 = affine.load %3[%arg6, %arg8, 0, 0] : memref<1x64x1x1xi8>
              %6 = affine.load %4[%arg8, %arg7] : memref<64x1000xi8>
              %7 = affine.load %arg5[%arg6, %arg7] : memref<1x1000xi8>
              %8 = arith.muli %5, %6 : i8
              %9 = arith.addi %7, %8 : i8
              affine.store %9, %arg5[%arg6, %arg7] : memref<1x1000xi8>
            }
          }
        }
      }
    }
    return
  }
}

