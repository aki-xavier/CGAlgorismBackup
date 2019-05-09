@ @-1, 28 + 0, 0 @ @
//
//  AVSimilar.h
//

#import "AVStroke.h"

                   NS_ASSUME_NONNULL_BEGIN

                   @interface AVSimilar : NSObject

                                          +
                                          (CGFloat)curveLength : (NSMutableArray<AVVector *> *)vectors;
+ (AVVector *)extendPointOnLine:(AVVector *)v1 and:(AVVector *)v2 withDist:(CGFloat)dist;
+ (CGFloat)findProcrustesRotationAngle:(NSMutableArray<AVVector *> *)stroke relativeCurve:(NSMutableArray<AVVector *> *)relativeCurve;
+ (NSMutableArray<AVVector *> *)procrustesNormalizeCurve:(NSMutableArray<AVVector *> *)vectors rebalance:(BOOL)rebalance estimationPoints:(NSInteger)estimationPoints;
+ (NSMutableArray<AVVector *> *)procrustesNormalizeRotation:(NSMutableArray<AVVector *> *)vectors relativeCurve:(NSMutableArray<AVVector *> *)relativeVectors;
+ (NSMutableArray<AVVector *> *)rebalanceCurve:(NSMutableArray<AVVector *> *)vectors estimationPoints:(NSInteger)estimationPoints;
+ (NSMutableArray<AVVector *> *)rotateCurve:(NSMutableArray<AVVector *> *)vectors theta:(CGFloat)theta;
+ (CGFloat)shapeSimilarity:(NSMutableArray<AVVector *> *)vectorsOne and:(NSMutableArray<AVVector *> *)vectorsTwo estimationPoints:(NSInteger)estimationPoints checkRotations:(BOOL)checkRotations rotations:(CGFloat)rotations restrictRotationAngle:(CGFloat)angle;
+ (NSMutableArray<AVVector *> *)subdivideCurve:(NSMutableArray<AVVector *> *)vectors maxLen:(CGFloat)maxLen;
+ (CGFloat)frechetDist:(NSMutableArray<AVVector *> *)vectorsOne and:(NSMutableArray<AVVector *> *)vectorsTwo;

@end

    NS_ASSUME_NONNULL_END