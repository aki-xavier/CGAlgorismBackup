@@ -1,202 +0,0 @@
//
//  AVSimilar.m
//

#import "AVSimilar.h"

@implementation AVSimilar

+ (CGFloat)curveLength:(NSMutableArray<AVVector *> *)vectors {
    CGFloat sum = 0;
    for (int i = 1; i < vectors.count; i++) {
        sum += [vectors[i] distanceTo:vectors[i-1]];
    }
    return sum;
}

+ (AVVector *)extendPointOnLine:(AVVector *)v1 and:(AVVector *)v2 withDist:(CGFloat)dist {
    AVVector *vect = [[v2 clone] sub:v1];
    CGFloat norm = dist / [vect length];
    return [AVVector vectorWithX:v2.x + norm * vect.x Y:v2.y + norm * vect.y Z:v2.z + norm * vect.z];
}

+ (CGFloat)findProcrustesRotationAngle:(NSMutableArray<AVVector *> *)vectors relativeCurve:(NSMutableArray<AVVector *> *)relativeVectors {
    if (vectors.count != relativeVectors.count) {
        return -1;
    }
    
    CGFloat numerator = 0;
    CGFloat denominator = 0;
    for (int i = 0; i < vectors.count; i++) {
        numerator += vectors[i].y * relativeVectors[i].x - vectors[i].x * relativeVectors[i].y;
        denominator += vectors[i].x * relativeVectors[i].x + vectors[i].y * relativeVectors[i].y;
    }
    
    return atan2(numerator, denominator);
}

+ (NSMutableArray<AVVector *> *)procrustesNormalizeCurve:(NSMutableArray<AVVector *> *)vectors rebalance:(BOOL)rebalance estimationPoints:(NSInteger)estimationPoints {
    // default estimationPoints is 50
    // rebalance defaults to YES
    NSMutableArray<AVVector *> *balancedCurve = rebalance ? [self rebalanceCurve:vectors estimationPoints:estimationPoints] : vectors;
    CGFloat sumX = 0, sumY = 0, sumZ = 0;
    for (int i = 0; i < balancedCurve.count; i++) {
        sumX += balancedCurve[i].x;
        sumY += balancedCurve[i].y;
        sumZ += balancedCurve[i].z;
    }
    AVVector *mean = [AVVector vectorWithX:sumX / (CGFloat)balancedCurve.count Y:sumY / (CGFloat)balancedCurve.count Z:sumZ / (CGFloat)balancedCurve.count];
    NSMutableArray<AVVector *> *translatedCurve = [[NSMutableArray alloc] init];
    for (int i = 0; i < balancedCurve.count; i++) {
        [translatedCurve addObject:[[balancedCurve[i] clone] sub:mean]];
    }
    CGFloat sum = 0;
    for (int i = 0; i < translatedCurve.count; i++) {
        sum += translatedCurve[i].x * translatedCurve[i].x + translatedCurve[i].y * translatedCurve[i].y + translatedCurve[i].z * translatedCurve[i].z;
    }
    CGFloat scale = sqrt(sum / (CGFloat)translatedCurve.count);
    for (int i = 0; i < translatedCurve.count; i++) {
        translatedCurve[i].x /= scale;
        translatedCurve[i].y /= scale;
        translatedCurve[i].z /= scale;
    }
    return translatedCurve;
}

+ (NSMutableArray<AVVector *> *)procrustesNormalizeRotation:(NSMutableArray<AVVector *> *)vectors relativeCurve:(NSMutableArray<AVVector *> *)relativeVectors {
    CGFloat angle = [self findProcrustesRotationAngle:vectors relativeCurve:relativeVectors];
    return [self rotateCurve:vectors theta:angle];
}

+ (NSMutableArray<AVVector *> *)rebalanceCurve:(NSMutableArray<AVVector *> *)vectors estimationPoints:(NSInteger)estimationPoints {
    CGFloat curveLen = [self curveLength:vectors];
    CGFloat segmentLen = curveLen / (CGFloat)(estimationPoints - 1);
    NSMutableArray<AVVector *> *outlinePoints = [@[vectors[0]] mutableCopy];
    AVVector *endPoint = vectors[vectors.count - 1];
    NSMutableArray<AVVector *> *remainingCurvePoints = [[vectors subarrayWithRange:NSMakeRange(1, vectors.count - 1)] mutableCopy];
    for (int i = 0; i < estimationPoints - 2; i++) {
        AVVector *lastPoint = outlinePoints[outlinePoints.count - 1];
        CGFloat remainingDist = segmentLen;
        BOOL outlinePointFound = NO;
        while (!outlinePointFound) {
            CGFloat nextPointDist = [lastPoint distanceTo:remainingCurvePoints[0]];
            if (nextPointDist < remainingDist) {
                lastPoint = remainingCurvePoints[0];
                [remainingCurvePoints removeObjectAtIndex:0];
            } else {
                AVVector *nextPoint = [self extendPointOnLine:lastPoint and:remainingCurvePoints[0] withDist:remainingDist - nextPointDist];
                [outlinePoints addObject:nextPoint];
                outlinePointFound = YES;
            }
        }
    }
    [outlinePoints addObject:endPoint];
    return outlinePoints;
}

+ (NSMutableArray<AVVector *> *)rotateCurve:(NSMutableArray<AVVector *> *)vectors theta:(CGFloat)theta {
    NSMutableArray<AVVector *> *vvectors = [[NSMutableArray alloc] init];
    for (int i = 0; i < vectors.count; i++) {
        [vvectors addObject:[AVVector vectorWithX:cos(-1 * theta) * vectors[i].x - sin(-1 * theta) * vectors[i].y Y:sin(-1 * theta) * vectors[i].x + cos(-1 * theta) * vectors[i].y Z:vectors[i].z]];
    }
    return vvectors;
}

+ (CGFloat)shapeSimilarity:(NSMutableArray<AVVector *> *)vectorsOne and:(NSMutableArray<AVVector *> *)vectorsTwo estimationPoints:(NSInteger)estimationPoints checkRotations:(BOOL)checkRotations rotations:(CGFloat)rotations restrictRotationAngle:(CGFloat)angle {
    // estimationPoints defaults to 50
    // checkRotations defaults to YES
    // rotations defaults to 10
    // angle defaults to M_PI
    if (ABS(angle) > M_PI) {
        return -1;
    }
    NSMutableArray<AVVector *> *normalizedCurve1 = [self procrustesNormalizeCurve:vectorsOne rebalance:NO estimationPoints:estimationPoints];
    NSMutableArray<AVVector *> *normalizedCurve2 = [self procrustesNormalizeCurve:vectorsTwo rebalance:NO estimationPoints:estimationPoints];
    CGFloat geoAvgCurveLen = sqrt([self curveLength:normalizedCurve1] * [self curveLength:normalizedCurve2]);
    
    NSMutableArray<NSNumber *> *thetasToCheck = [@[@(0)] mutableCopy];
    if (checkRotations) {
        CGFloat procrustesTheta = [self findProcrustesRotationAngle:normalizedCurve1 relativeCurve:normalizedCurve2];
        if (procrustesTheta > M_PI) {
            procrustesTheta = procrustesTheta - 2 * M_PI;
        }
        if (procrustesTheta != 0 && ABS(procrustesTheta) < angle) {
            [thetasToCheck addObject:@(procrustesTheta)];
        }
        for (int i = 0; i < rotations; i++) {
            CGFloat theta = -1 * angle + (2 * i * angle) / (rotations - 1);
            if (theta != 0 && theta != M_PI) {
                [thetasToCheck addObject:@(theta)];
            }
        }
    }
    
    CGFloat minFrechetDist = INFINITY;
    for (int i = 0; i < thetasToCheck.count; i++) {
        NSMutableArray<AVVector *> *rotatedCurve1 = [self rotateCurve:normalizedCurve1 theta:[thetasToCheck[i] floatValue]];
        CGFloat dist = [self frechetDist:rotatedCurve1 and:normalizedCurve2];
        if (dist < minFrechetDist) {
            minFrechetDist = dist;
        }
    }
    
    return MAX(1 - minFrechetDist / (geoAvgCurveLen / sqrt(2)), 0);
}

+ (NSMutableArray<AVVector *> *)subdivideCurve:(NSMutableArray<AVVector *> *)vectors maxLen:(CGFloat)maxLen {
    // default maxLen is 0.05
    NSMutableArray<AVVector *> *newCurve = [[NSMutableArray alloc] init];
    [newCurve addObject:vectors[0]];
    for (int i = 1; i < vectors.count; i++) {
        AVVector *prevPoint = newCurve[newCurve.count - 1];
        CGFloat segLen = [vectors[i] distanceTo:prevPoint];
        if (segLen > maxLen) {
            CGFloat numNewPoints = ceil(segLen/maxLen);
            CGFloat newSegLen = segLen / numNewPoints;
            for (int j = 0; j < numNewPoints; j++) {
                [newCurve addObject:[self extendPointOnLine:vectors[0] and:prevPoint withDist:-1 * newSegLen * (i + 1)]];
            }
        } else {
            [newCurve addObject:vectors[i]];
        }
    }
    return newCurve;
}

+ (CGFloat)frechetDist:(NSMutableArray<AVVector *> *)vectorsOne and:(NSMutableArray<AVVector *> *)vectorsTwo {
    NSMutableArray<NSMutableArray<NSNumber *> *> *results = [[NSMutableArray alloc] init];
    for (int i = 0; i < vectorsOne.count; i++) {
        [results addObject:[[NSMutableArray alloc] init]];
        for (int j = 0; j < vectorsTwo.count; j++) {
            [results[i] addObject:@(-1)];
        }
    }
    
    return [self ca:results i:vectorsOne.count - 1 j:vectorsTwo.count - 1 p:vectorsOne q:vectorsTwo];
}

+ (CGFloat)ca:(NSMutableArray<NSMutableArray<NSNumber *> *> *)results i:(NSInteger)i j:(NSInteger)j p:(NSMutableArray<AVVector *> *)p q:(NSMutableArray<AVVector *> *)q {
    if ([results[i][j] floatValue] > -1) {
        return [results[i][j] floatValue];
    } else if (i == 0 && j == 0) {
        results[i][j] = @([p[0] distanceTo:q[0]]);
    } else if (i > 0 && j == 0) {
        results[i][j] = @(MAX([self ca:results i:i-1 j:0 p:p q:q], [p[i] distanceTo:q[0]]));
    } else if (i == 0 && j > 0) {
        results[i][j] = @(MAX([self ca:results i:0 j:j-1 p:p q:q], [p[0] distanceTo:q[j]]));
    } else if (i > 0 && j > 0) {
        CGFloat min = MIN([self ca:results i:i-1 j:j p:p q:q], [self ca:results i:i-1 j:j-1 p:p q:q]);
        min = MIN(min, [self ca:results i:i j:j-1 p:p q:q]);
        results[i][j] = @(MAX(min, [p[i] distanceTo:q[j]]));
    } else {
        results[i][j] = @(INFINITY);
    }
    
    return [results[i][j] floatValue];
}

@end