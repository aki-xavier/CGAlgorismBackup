@ @-1, 38 + 0, 0 @ @
//
//  AVMatrix.h
//

#import <UIKit/UIKit.h>

    NS_ASSUME_NONNULL_BEGIN

    @interface AVMatrix : NSObject

                          @property(strong, nonatomic) NSMutableArray<NSNumber *> *elements;

- (CGFloat)getNumber:(NSInteger)index;
- (AVMatrix *)identity;
- (AVMatrix *)clone;
- (AVMatrix *)copy:(AVMatrix *)m;
- (AVMatrix *)multiplyMatrices:(AVMatrix *)a and:(AVMatrix *)b;
- (AVMatrix *)multiply:(AVMatrix *)m;
- (AVMatrix *)premultiply:(AVMatrix *)m;
- (AVMatrix *)multiplyScalar:(CGFloat)s;
- (CGFloat)determinant;
- (AVMatrix *)getInverse:(AVMatrix *)matrix;
- (AVMatrix *)transpose;
- (AVMatrix *)setUvTransform:(CGFloat)tx ty:(CGFloat)ty sx:(CGFloat)sx sy:(CGFloat)sy rotation:(CGFloat)rotation cx:(CGFloat)cx cy:(CGFloat)cy;
- (AVMatrix *)scaleWithSx:(CGFloat)sx andSy:(CGFloat)sy;
- (AVMatrix *)rotate:(CGFloat)theta;
- (void)addBy:(CGFloat)s at:(NSInteger)index;
- (void)multipleBy:(CGFloat)s at:(NSInteger)index;
- (AVMatrix *)translate:(CGFloat)tx ty:(CGFloat)ty;
- (BOOL)equals:(AVMatrix *)matrix;

@end

    NS_ASSUME_NONNULL_END