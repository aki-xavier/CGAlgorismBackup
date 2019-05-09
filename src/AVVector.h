//
//  AVVector.h
//

#import <UIKit/UIKit.h>
#import "math.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVVector : NSObject

@property(nonatomic) CGFloat x;
@property(nonatomic) CGFloat y;
@property(nonatomic) CGFloat z;

+ (AVVector *)vectorWithCGPoint:(CGPoint)point;
+ (AVVector *)vectorWithX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z;
- (AVVector *)setX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z;
- (AVVector *)setScalar:(CGFloat)scalar;
- (AVVector *)clone;
- (AVVector *)copy:(AVVector *)vector;
- (AVVector *)add:(AVVector *)vector;
- (AVVector *)addScalar:(CGFloat)scalar;
- (AVVector *)sub:(AVVector *)vector;
- (AVVector *)subScalar:(CGFloat)scalar;
- (AVVector *)multiply:(AVVector *)vector;
- (AVVector *)multiplyScalar:(CGFloat)scalar;
- (AVVector *)divide:(AVVector *)vector;
- (AVVector *)divideScalar:(CGFloat)scalar;
- (AVVector *)cross:(AVVector *)vector;
- (AVVector *)min:(AVVector *)vector;
- (AVVector *)max:(AVVector *)vector;
- (AVVector *)floor;
- (AVVector *)ceil;
- (AVVector *)round;
- (AVVector *)roundToZero;
- (AVVector *)negate;
- (CGFloat)dot:(AVVector *)vector; // 两向量长度与夹角余弦的乘积
- (CGFloat)length;
- (CGFloat)lengthSq;
- (AVVector *)normalize;
- (AVVector *)setLength:(CGFloat)length;
- (CGFloat)distanceTo:(AVVector *)vector;
- (CGFloat)distanceToSq:(AVVector *)vector;
- (BOOL)equals:(AVVector *)vector;
- (BOOL)onSameDirection:(AVVector *)vector;
- (BOOL)onOppositeDirection:(AVVector *)vector;
- (CGPoint)getCGPoint;
- (AVVector *)projectOnVector:(AVVector *)vector;
- (AVVector *)rotateBy:(CGFloat)rotation;
- (NSString *)toString;

@end

NS_ASSUME_NONNULL_END
