//
//  AVVector.m
//

#import "AVVector.h"

@implementation AVVector

+ (AVVector *) vectorWithCGPoint:(CGPoint)point {
    AVVector *v = [[AVVector alloc] init];
    v.x = point.x;
    v.y = point.y;
    return v;
}

+ (AVVector *)vectorWithX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z {
    AVVector *p = [[AVVector alloc] init];
    p.x = x;
    p.y = y;
    p.z = z;
    return p;
}

- (AVVector *)setX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z {
    self.x = x;
    self.y = y;
    self.z = z;
    return self;
}

- (AVVector *)setScalar:(CGFloat)scalar {
    self.x = scalar;
    self.y = scalar;
    self.z = scalar;
    return self;
}

- (AVVector *)clone {
    AVVector *p = [AVVector vectorWithX:self.x Y:self.y Z:self.z];
    return p;
}

- (AVVector *)copy:(AVVector *)vector {
    self.x = vector.x;
    self.y = vector.y;
    self.z = vector.z;
    return self;
}

- (AVVector *)add:(AVVector *)vector {
    self.x += vector.x;
    self.y += vector.y;
    self.z += vector.z;
    return self;
}

- (AVVector *)addScalar:(CGFloat)scalar {
    self.x += scalar;
    self.y += scalar;
    self.z += scalar;
    return self;
}

- (AVVector *)sub:(AVVector *)vector {
    self.x -= vector.x;
    self.y -= vector.y;
    self.z -= vector.z;
    return self;
}

- (AVVector *)subScalar:(CGFloat)scalar {
    self.x -= scalar;
    self.y -= scalar;
    self.z -= scalar;
    return self;
}

- (AVVector *)multiply:(AVVector *)vector {
    self.x *= vector.x;
    self.y *= vector.y;
    self.z *= vector.z;
    return self;
}

- (AVVector *)multiplyScalar:(CGFloat)scalar {
    self.x *= scalar;
    self.y *= scalar;
    self.z *= scalar;
    return self;
}

- (AVVector *)divide:(AVVector *)vector {
    self.x /= vector.x;
    self.y /= vector.y;
    self.z /= vector.z;
    return self;
}

- (AVVector *)divideScalar:(CGFloat)scalar {
    return [self multiplyScalar:(1/scalar)];
}

- (AVVector *)cross:(AVVector *)vector {
    CGFloat ax = self.x;
    CGFloat ay = self.y;
    CGFloat az = self.z;
    CGFloat bx = vector.x;
    CGFloat by = vector.y;
    CGFloat bz = vector.z;
    self.x = ay * bz - az * by;
    self.y = az * bx - ax * bz;
    self.z = ax * by - ay * bx;
    return self;
}

- (AVVector *)min:(AVVector *)vector {
    self.x = self.x > vector.x ? vector.x : self.x;
    self.y = self.y > vector.y ? vector.y : self.y;
    self.z = self.z > vector.z ? vector.z : self.z;
    return self;
}

- (AVVector *)max:(AVVector *)vector {
    self.x = self.x < vector.x ? vector.x : self.x;
    self.y = self.y < vector.y ? vector.y : self.y;
    self.z = self.z < vector.z ? vector.z : self.z;
    return self;
}

- (AVVector *)floor {
    self.x = floorl(self.x);
    self.y = floorl(self.y);
    self.z = floorl(self.z);
    return self;
}

- (AVVector *)ceil {
    self.x = ceill(self.x);
    self.y = ceill(self.y);
    self.z = ceill(self.z);
    return self;
}

- (AVVector *)round {
    self.x = roundl(self.x);
    self.y = roundl(self.y);
    self.z = roundl(self.z);
    return self;
}

- (AVVector *)roundToZero {
    self.x = self.x < 0 ? ceill(self.x) : floorl(self.x);
    self.y = self.y < 0 ? ceill(self.y) : floorl(self.y);
    self.z = self.z < 0 ? ceill(self.z) : floorl(self.z);
    return self;
}

- (AVVector *)negate {
    self.x = - self.x;
    self.y = - self.y;
    self.z = - self.z;
    return self;
}

- (CGFloat)dot:(AVVector *)vector {
    return self.x * vector.x + self.y * vector.y + self.z * vector.z;
}

- (CGFloat)length {
    return sqrtl([self lengthSq]);
}

- (CGFloat)lengthSq {
    return self.x * self.x + self.y * self.y + self.z * self.z;
}

- (AVVector *)normalize {
    return [self divideScalar:[self length]];
}

- (AVVector *)setLength:(CGFloat)length {
    return [[self normalize] multiplyScalar:length];
}

- (CGFloat)distanceTo:(AVVector *)vector {
    return sqrtl([self distanceToSq:vector]);
}

- (CGFloat)distanceToSq:(AVVector *)vector {
    CGFloat dx = self.x - vector.x;
    CGFloat dy = self.y - vector.y;
    CGFloat dz = self.z - vector.z;
    return dx * dx + dy * dy + dz * dz;
}

- (BOOL)equals:(AVVector *)vector {
    return (self.x == vector.x) && (self.y == vector.y) && (self.z == vector.z);
}

- (BOOL)onSameDirection:(AVVector *)vector {
    return [[[self clone] normalize] equals:[[vector clone] normalize]];
}

- (BOOL)onOppositeDirection:(AVVector *)vector {
    return [[[self clone] normalize] equals:[[[vector clone] normalize] negate]];
}

- (CGPoint)getCGPoint {
    return CGPointMake(self.x, self.y);
}

- (AVVector *)projectOnVector:(AVVector *)vector {
    CGFloat scalar = [vector dot:self] / [vector lengthSq];
    return [[self copy:vector] multiplyScalar:scalar];
}

- (CGFloat)limitRotation:(CGFloat)rotation {
    while (rotation >= M_PI * 2) {
        rotation -= M_PI * 2;
    }
    
    while (rotation < 0) {
        rotation += M_PI * 2;
    }
    return rotation;
}

- (CGFloat)rotateX:(CGFloat)x andY:(CGFloat)y by:(CGFloat)rotation {
    if (x == 0 && y == 0) {
        return -1;
    }
    if (x == 0) {
        if (y > 0) {
            return [self limitRotation:rotation];
        }
        return [self limitRotation:rotation + M_PI];
    }
    if (y == 0) {
        if (x > 0) {
            return [self limitRotation:rotation + M_PI_2];
        }
        return [self limitRotation:rotation + 3 * M_PI_2];
    }
    CGFloat deltaX = fabsl(x);
    CGFloat deltaY = fabsl(y);
    if (x > 0 && y > 0) { // 第一象限
        return [self limitRotation:rotation + atan(deltaX / deltaY)];
    } else if (x > 0 && y < 0) { // 第二象限
        return [self limitRotation:rotation + atan(deltaY / deltaX) + M_PI_2];
    } else if (x < 0 && y < 0) { // 第三象限
        return [self limitRotation:rotation + atan(deltaX / deltaY) + M_PI];
    } else { // 第四象限
        return [self limitRotation:rotation + atan(deltaY / deltaX) + M_PI_2 * 3];
    }
    return 0;
}

- (AVVector *)rotateBy:(CGFloat)rotation {
    if (rotation == 0) {
        return self;
    }
    CGFloat finalRotation = [self rotateX:self.x andY:self.y by:rotation];
    if (finalRotation == -1) {
        return self;
    }
    CGFloat length = [self length];
    if (finalRotation == 0) {
        return [self setX:0 Y:-length Z:0];
    } else if (finalRotation == M_PI_2) {
        return [self setX:length Y:0 Z:0];
    } else if (finalRotation == M_PI) {
        return [self setX:0 Y:length Z:0];
    } else if (finalRotation == M_PI_2 * 3) {
        return [self setX:-length Y:0 Z:0];
    }
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat tanRotation = 0;
    if (finalRotation > 0 && finalRotation < M_PI_2) { // 第一象限
        tanRotation = fabsl(tan(finalRotation));
        y = length * sqrtl(1 / (tanRotation * tanRotation + 1));
        x = fabsl(tanRotation * y);
    } else if (finalRotation > M_PI_2 && finalRotation < M_PI) { // 第二象限
        tanRotation = fabsl(tan([self limitRotation:finalRotation - M_PI_2]));
        x = length * sqrtl(1 / (tanRotation * tanRotation + 1));
        y = fabsl(tanRotation * x);
        y = -y;
    } else if (finalRotation > M_PI && finalRotation < M_PI_2 * 3) { // 第三象限
        tanRotation = fabsl(tan([self limitRotation:finalRotation - M_PI]));
        y = length * sqrtl(1 / (tanRotation * tanRotation + 1));
        x = - fabsl(tanRotation * y);
        y = -y;
    } else { // 第四象限
        tanRotation = fabsl(tan([self limitRotation:finalRotation - M_PI_2 * 3]));
        x = length * sqrtl(1 / (tanRotation * tanRotation + 1));
        y = fabsl(tanRotation * x);
        x = -x;
    }
    return [self setX:x Y:y Z:0];
}

- (NSString *)toString {
    return [NSString stringWithFormat:@"x: %f, y: %f, z: %f", self.x, self.y, self.z];
}

@end
