//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_MULTIPLELEVELDSE_H
#define SCALEHLS_TRANSFORMS_MULTIPLELEVELDSE_H

#include "scalehls/Analysis/QoREstimation.h"
#include "scalehls/Transforms/Utils.h"

namespace mlir {
namespace scalehls {

using TileConfig = unsigned;

//===----------------------------------------------------------------------===//
// LoopDesignSpace Class Declaration
//===----------------------------------------------------------------------===//

struct LoopDesignPoint {
  explicit LoopDesignPoint(int64_t latency, int64_t dspNum,
                           TileConfig tileConfig, unsigned targetII)
      : latency(latency), dspNum(dspNum), tileConfig(tileConfig),
        targetII(targetII) {}

  int64_t latency;
  int64_t dspNum;

  TileConfig tileConfig;
  unsigned targetII;

  bool isActive = true;
};

class LoopDesignSpace {
public:
  explicit LoopDesignSpace(FuncOp func, AffineLoopBand &band,
                           ScaleHLSEstimator &estimator, unsigned maxDspNum);

  /// Return the actual tile vector given a tile config.
  TileList getTileList(TileConfig config);

  /// Calculate the Euclid distance of config a and config b.
  float getTileConfigDistance(TileConfig configA, TileConfig configB);

  /// Evaluate all design points under the given tile config.
  bool evaluateTileConfig(TileConfig config);

  /// Initialize the design space.
  void initializeLoopDesignSpace(unsigned maxInitParallel);

  /// Dump pareto and non-pareto points which have been evaluated in the design
  /// space to a csv output file.
  void dumpLoopDesignSpace(raw_ostream &os);

  /// Get a random tile config which is one of the closest neighbors of "point".
  Optional<TileConfig> getRandomClosestNeighbor(LoopDesignPoint point,
                                                float maxDistance);

  void exploreLoopDesignSpace(unsigned maxIterNum, float maxDistance);

  /// Stores current pareto frontiers and all evaluated design points. The
  /// "allPoints" is mainly used for design space dumping, which is actually not
  /// used in the DSE procedure.
  SmallVector<LoopDesignPoint, 16> paretoPoints;
  SmallVector<LoopDesignPoint, 16> allPoints;

  /// Associated function, loop band, and estimator.
  FuncOp func;
  AffineLoopBand &band;
  ScaleHLSEstimator &estimator;
  unsigned maxDspNum;

  /// Records the trip count of each loop level.
  SmallVector<unsigned, 8> tripCountList;

  /// The dimension of this list is same to the number of loops in the loop
  /// band. The n-th element of this list stores all valid tile sizes of the
  /// n-th loop in the loop band.
  std::vector<SmallVector<unsigned, 8>> validTileSizesList;

  /// Holds the total number of valid tile size combinations.
  unsigned validTileConfigNum;

  /// Holds all tile configs that have not been estimated.
  std::set<TileConfig> unestimatedTileConfigs;
};

//===----------------------------------------------------------------------===//
// FuncDesignSpace Class Declaration
//===----------------------------------------------------------------------===//

/// Each function design point contains multiple loop design point.
struct FuncDesignPoint {
  explicit FuncDesignPoint(int64_t latency, int64_t dspNum)
      : latency(latency), dspNum(dspNum) {}

  explicit FuncDesignPoint(int64_t latency, int64_t dspNum,
                           LoopDesignPoint point)
      : latency(latency), dspNum(dspNum) {
    loopDesignPoints.push_back(point);
  }

  explicit FuncDesignPoint(int64_t latency, int64_t dspNum,
                           SmallVector<LoopDesignPoint, 4> &points)
      : latency(latency), dspNum(dspNum) {
    loopDesignPoints = points;
  }

  int64_t latency;
  int64_t dspNum;

  SmallVector<LoopDesignPoint, 4> loopDesignPoints;
};

class FuncDesignSpace {
public:
  explicit FuncDesignSpace(FuncOp func,
                           SmallVector<LoopDesignSpace, 4> &loopDesignSpaces,
                           ScaleHLSEstimator &estimator, unsigned maxDspNum)
      : func(func), loopDesignSpaces(loopDesignSpaces), estimator(estimator),
        maxDspNum(maxDspNum) {
    AffineLoopBands targetBands;
    getLoopBands(func.front(), targetBands);

    for (auto &band : targetBands) {
      targetLoops.push_back(band.front());
      estimator.setAttrValue(band.front(), "no_touch", true);
    }
  }

  void combLoopDesignSpaces();

  void dumpFuncDesignSpace(raw_ostream &os);

  SmallVector<FuncDesignPoint, 16> paretoPoints;

  /// Associated function, loop design spaces, and estimator.
  FuncOp func;
  SmallVector<LoopDesignSpace, 4> &loopDesignSpaces;
  ScaleHLSEstimator &estimator;
  unsigned maxDspNum;

  SmallVector<AffineForOp, 4> targetLoops;
};

//===----------------------------------------------------------------------===//
// ScaleHLSOptimizer Class Declaration
//===----------------------------------------------------------------------===//

class ScaleHLSOptimizer : public ScaleHLSAnalysisBase {
public:
  explicit ScaleHLSOptimizer(Builder &builder, ScaleHLSEstimator &estimator,
                             unsigned maxDspNum, unsigned maxInitParallel,
                             unsigned maxIterNum, float maxDistance)
      : ScaleHLSAnalysisBase(builder), estimator(estimator),
        maxDspNum(maxDspNum), maxInitParallel(maxInitParallel),
        maxIterNum(maxIterNum), maxDistance(maxDistance) {}

  bool emitQoRDebugInfo(FuncOp func, std::string message);

  bool simplifyLoopNests(FuncOp func);
  bool optimizeLoopBands(FuncOp func);
  bool exploreDesignSpace(FuncOp func, raw_ostream &os);

  void applyMultipleLevelDSE(FuncOp func, raw_ostream &os);

  ScaleHLSEstimator &estimator;
  unsigned maxDspNum;

  unsigned maxInitParallel;
  unsigned maxIterNum;
  float maxDistance;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_MULTIPLELEVELDSE_H
