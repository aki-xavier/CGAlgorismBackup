@@ -1,218 +0,0 @@
//
//  AVMatrix.m
//

#import "AVMatrix.h"

@implementation AVMatrix

- (NSMutableArray<NSNumber *> *)elements {
    if (_elements == nil) {
        _elements = [@[@(1), @(0), @(0), @(0), @(1), @(0), @(0), @(0), @(1)] mutableCopy];
    }
    return _elements;
}

- (AVMatrix *)identity {
    self.elements = [@[@(1), @(0), @(0), @(0), @(1), @(0), @(0), @(0), @(1)] mutableCopy];
    return self;
}

- (AVMatrix *)clone {
    AVMatrix *matrix = [[AVMatrix alloc] init];
    for (NSNumber *number in self.elements) {
        [matrix.elements addObject:@([number floatValue])];
    }
    return matrix;
}

- (AVMatrix *)copy:(AVMatrix *)m {
    for (int i = 0; i <= 8; i++) {
        self.elements[i] = @([m.elements[i] floatValue]);
    }
    return self;
}

- (AVMatrix *)multiplyMatrices:(AVMatrix *)a and:(AVMatrix *)b {
    CGFloat a11 = [a getNumber:0];
    CGFloat a12 = [a getNumber:3];
    CGFloat a13 = [a getNumber:6];
    CGFloat a21 = [a getNumber:1];
    CGFloat a22 = [a getNumber:4];
    CGFloat a23 = [a getNumber:7];
    CGFloat a31 = [a getNumber:2];
    CGFloat a32 = [a getNumber:5];
    CGFloat a33 = [a getNumber:8];
    
    CGFloat b11 = [b getNumber:0];
    CGFloat b12 = [b getNumber:3];
    CGFloat b13 = [b getNumber:6];
    CGFloat b21 = [b getNumber:1];
    CGFloat b22 = [b getNumber:4];
    CGFloat b23 = [b getNumber:7];
    CGFloat b31 = [b getNumber:2];
    CGFloat b32 = [b getNumber:5];
    CGFloat b33 = [b getNumber:8];
    
    [self setNumber:a11 * b11 + a12 * b21 + a13 * b31 at:0];
    [self setNumber:a21 * b11 + a22 * b21 + a23 * b31 at:1];
    [self setNumber:a31 * b11 + a32 * b21 + a33 * b31 at:2];
    [self setNumber:a11 * b12 + a12 * b22 + a13 * b32 at:3];
    [self setNumber:a21 * b12 + a22 * b22 + a23 * b32 at:4];
    [self setNumber:a31 * b12 + a32 * b22 + a33 * b32 at:5];
    [self setNumber:a11 * b13 + a12 * b23 + a13 * b33 at:6];
    [self setNumber:a21 * b13 + a22 * b23 + a23 * b33 at:7];
    [self setNumber:a31 * b13 + a32 * b23 + a33 * b33 at:8];
    
    return self;
}

- (void)setNumber:(CGFloat)number at:(NSInteger)index {
    self.elements[index] = @(number);
}

- (CGFloat)getNumber:(NSInteger)index {
    return [self.elements[index] floatValue];
}

- (AVMatrix *)multiply:(AVMatrix *)m {
    return [self multiplyMatrices:self and:m];
}

- (AVMatrix *)premultiply:(AVMatrix *)m {
    return [self multiplyMatrices:m and:self];
}

- (AVMatrix *)multiplyScalar:(CGFloat)s {
    for (int i = 0; i < 9; i++) {
        [self multipleBy:s at:i];
    }
    return self;
}

- (CGFloat)determinant {
    CGFloat a = [self getNumber:0];
    CGFloat b = [self getNumber:1];
    CGFloat c = [self getNumber:2];
    CGFloat d = [self getNumber:3];
    CGFloat e = [self getNumber:4];
    CGFloat f = [self getNumber:5];
    CGFloat g = [self getNumber:6];
    CGFloat h = [self getNumber:7];
    CGFloat i = [self getNumber:8];
    return a * e * i - a * f * h - b * d * i + b * f * g + c * d * h - c * e * g;
}

- (AVMatrix *)getInverse:(AVMatrix *)matrix {
    CGFloat n11 = [matrix getNumber:0];
    CGFloat n21 = [matrix getNumber:1];
    CGFloat n31 = [matrix getNumber:2];
    CGFloat n12 = [matrix getNumber:3];
    CGFloat n22 = [matrix getNumber:4];
    CGFloat n32 = [matrix getNumber:5];
    CGFloat n13 = [matrix getNumber:6];
    CGFloat n23 = [matrix getNumber:7];
    CGFloat n33 = [matrix getNumber:8];
    CGFloat t11 = n33 * n22 - n32 * n23;
    CGFloat t12 = n32 * n13 - n33 * n12;
    CGFloat t13 = n23 * n12 - n22 * n13;
    CGFloat det = n11 * t11 + n21 * t12 + n31 * t13;
    if (det == 0) {
        return [self identity];
    }
    
    CGFloat detInv = 1 / det;
    [self setNumber:t11 * detInv at:0];
    [self setNumber:(n31 * n23 - n33 * n21) * detInv at:1];
    [self setNumber:(n32 * n21 - n31 * n22) * detInv at:2];
    [self setNumber:t12 * detInv at:3];
    [self setNumber:(n33 * n11 - n31 * n13) * detInv at:4];
    [self setNumber:(n31 * n12 - n32 * n11) * detInv at:5];
    [self setNumber:t13 * detInv at:6];
    [self setNumber:(n21 * n13 - n23 * n11) * detInv at:7];
    [self setNumber:(n22 * n11 - n21 * n12) * detInv at:8];
    return self;
}

- (AVMatrix *)transpose {
    CGFloat tmp = 0;
    tmp = [self getNumber:1];
    [self setNumber:[self getNumber:3] at:1];
    [self setNumber:tmp at:3];
    tmp = [self getNumber:2];
    [self setNumber:[self getNumber:6] at:2];
    [self setNumber:tmp at:6];
    tmp = [self getNumber:5];
    [self setNumber:[self getNumber:7] at:5];
    [self setNumber:tmp at:7];
    return self;
}

- (AVMatrix *)setUvTransform:(CGFloat)tx ty:(CGFloat)ty sx:(CGFloat)sx sy:(CGFloat)sy rotation:(CGFloat)rotation cx:(CGFloat)cx cy:(CGFloat)cy {
    CGFloat c = cosl(rotation);
    CGFloat s = sinl(rotation);
    self.elements = [@[@(sx * c), @(sx * s), @(- sx * (c * cx + s * cy) + cx + tx), @(-sy * s), @(sy * c), @(- sy * (-s * cx + c * cy) + cy + ty), @(0), @(0), @(1)] mutableCopy];
    return self;
}

- (AVMatrix *)scaleWithSx:(CGFloat)sx andSy:(CGFloat)sy {
    [self multipleBy:sx at:0];
    [self multipleBy:sx at:3];
    [self multipleBy:sx at:6];
    [self multipleBy:sy at:1];
    [self multipleBy:sy at:4];
    [self multipleBy:sy at:7];
    return self;
}

- (AVMatrix *)rotate:(CGFloat)theta {
    CGFloat c = cosl(theta);
    CGFloat s = sinl(theta);
    CGFloat a11 = [self getNumber:0];
    CGFloat a12 = [self getNumber:3];
    CGFloat a13 = [self getNumber:6];
    CGFloat a21 = [self getNumber:1];
    CGFloat a22 = [self getNumber:4];
    CGFloat a23 = [self getNumber:7];
    
    [self setNumber:c * a11 + s * a21 at:0];
    [self setNumber:c * a12 + s * a22 at:3];
    [self setNumber:c * a13 + s * a23 at:6];
    [self setNumber:- s * a11 + c * a21 at:1];
    [self setNumber:- s * a12 + c * a22 at:4];
    [self setNumber:- s * a13 + c * a23 at:7];
    return self;
}

- (void)addBy:(CGFloat)s at:(NSInteger)index {
    [self setNumber:[self getNumber:index] + s at:index];
}

- (void)multipleBy:(CGFloat)s at:(NSInteger)index {
    [self setNumber:[self getNumber:index] * s at:index];
}

- (AVMatrix *)translate:(CGFloat)tx ty:(CGFloat)ty {
    [self addBy:tx * [self getNumber:2] at:0];
    [self addBy:tx * [self getNumber:5] at:3];
    [self addBy:tx * [self getNumber:8] at:6];
    [self addBy:ty * [self getNumber:2] at:1];
    [self addBy:ty * [self getNumber:5] at:4];
    [self addBy:ty * [self getNumber:8] at:7];
    return self;
}

- (BOOL)equals:(AVMatrix *)matrix {
    for (int i = 0; i < 9; i++) {
        if ([self getNumber:i] != [matrix getNumber:i]) {
            return NO;
        }
    }
    return YES;
}

@end