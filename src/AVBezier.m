//
//  AVBezier.m
//

#import "AVBezier.h"

static const NSUInteger FitCurveMaximumReparameterizes = 4;

static CGFloat Determinant(CGFloat matrix1[2], CGFloat matrix2[2]) {
    return matrix1[0] * matrix2[1] - matrix1[1] * matrix2[0];
}

static CGFloat Bernstein0(CGFloat input) {
    return powf(1.0 - input, 3);
}

static CGFloat Bernstein1(CGFloat input) {
    return 3 * input * powf(1.0 - input, 2);
}

static CGFloat Bernstein2(CGFloat input) {
    return 3 * powf(input, 2) * (1.0 - input);
}

static CGFloat Bernstein3(CGFloat input) {
    return powf(input, 3);
}

static CGPoint BezierWithPoints(NSUInteger degree, NSMutableArray<NSValue *> *bezierPoints, CGFloat parameter) {
    NSMutableArray<NSValue *> *points = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i <= degree; i++)
        points[i] = bezierPoints[i];
    
    for (NSUInteger k = 1; k <= degree; k++) {
        for (NSUInteger i = 0; i <= (degree - k); i++) {
            CGPoint point = [points[i] CGPointValue];
            CGPoint nextPoint = [points[i+1] CGPointValue];
            point.x = (1.0 - parameter) * point.x + parameter * nextPoint.x;
            point.y = (1.0 - parameter) * point.y + parameter * nextPoint.y;
            [points replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:point]];
        }
    }
    return [points[0] CGPointValue]; // we'll end up with just one point, which is handy, 'cause that's what we want
}

static CGPoint Bezier(NSUInteger degree, AVBezier *bezier, CGFloat parameter) {
    AVBezierElement *element1 = bezier.elements[0];
    AVBezierElement *element2 = bezier.elements[1];
    NSMutableArray<NSValue *> *bezierPoints = [[NSMutableArray alloc] init];
    [bezierPoints addObject:[NSValue valueWithCGPoint:element1.point]];
    [bezierPoints addObject:[NSValue valueWithCGPoint:[element2.controlPoints[0] CGPointValue]]];
    [bezierPoints addObject:[NSValue valueWithCGPoint:[element2.controlPoints[1] CGPointValue]]];
    [bezierPoints addObject:[NSValue valueWithCGPoint:element2.point]];
    return BezierWithPoints(degree, bezierPoints, parameter);
}

static CGFloat NewtonsMethod(AVBezier *bezier, CGPoint point, CGFloat parameter) {
    AVBezierElement *element1 = bezier.elements[0];
    AVBezierElement *element2 = bezier.elements[1];
    NSMutableArray<NSValue *> *bezierPoints = [[NSMutableArray alloc] init];
    [bezierPoints addObject:[NSValue valueWithCGPoint:element1.point]];
    [bezierPoints addObject:[NSValue valueWithCGPoint:[element2.controlPoints[0] CGPointValue]]];
    [bezierPoints addObject:[NSValue valueWithCGPoint:[element2.controlPoints[1] CGPointValue]]];
    [bezierPoints addObject:[NSValue valueWithCGPoint:element2.point]];
    
    // Compute Q(parameter)
    CGPoint qAtParameter = BezierWithPoints(3, bezierPoints, parameter);
    
    // Compute Q'(parameter)
    NSMutableArray<NSValue *> *qPrimePoints = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 3; i++) {
        CGFloat x = ([bezierPoints[i + 1] CGPointValue].x - [bezierPoints[i] CGPointValue].x) * 3.0;
        CGFloat y = ([bezierPoints[i + 1] CGPointValue].y - [bezierPoints[i] CGPointValue].y) * 3.0;
        CGPoint point = CGPointMake(x, y);
        [qPrimePoints addObject:[NSValue valueWithCGPoint:point]];
    }
    CGPoint qPrimeAtParameter = BezierWithPoints(2, qPrimePoints, parameter);
    
    // Compute Q''(parameter)
    NSMutableArray<NSValue *> *qPrimePrimePoints = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 2; i++) {
        CGFloat x = ([qPrimePoints[i + 1] CGPointValue].x - [qPrimePoints[i] CGPointValue].x) * 2.0;
        CGFloat y = ([qPrimePoints[i + 1] CGPointValue].y - [qPrimePoints[i] CGPointValue].y) * 2.0;
        CGPoint point = CGPointMake(x, y);
        [qPrimePrimePoints addObject:[NSValue valueWithCGPoint:point]];
    }
    CGPoint qPrimePrimeAtParameter = BezierWithPoints(1, qPrimePrimePoints, parameter);
    
    // Compute f(parameter) and f'(parameter)
    CGPoint qMinusPoint = FBSubtractPoint(qAtParameter, point);
    CGFloat fAtParameter = FBDotMultiplyPoint(qMinusPoint, qPrimeAtParameter);
    CGFloat fPrimeAtParameter = FBDotMultiplyPoint(qMinusPoint, qPrimePrimeAtParameter) + FBDotMultiplyPoint(qPrimeAtParameter, qPrimeAtParameter);
    
    // Newton's method!
    return parameter - (fAtParameter / fPrimeAtParameter);
}

@implementation AVBezier

- (NSMutableArray<AVBezierElement *> *)elements {
    if (!_elements) {
        _elements = [[NSMutableArray alloc] init];
    }
    return _elements;
}

- (UIBezierPath *)createPath {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    for (int i = 0; i < self.elements.count; i++) {
        AVBezierElement *element = self.elements[i];
        switch (element.kind) {
            case 0:
                [path moveToPoint:element.point];
                break;
            case 1:
                [path addLineToPoint:element.point];
                break;
            case 2:
                [path addCurveToPoint:element.point controlPoint1:[element.controlPoints[0] CGPointValue] controlPoint2:[element.controlPoints[1] CGPointValue]];
                break;
            case 3:
                [path closePath];
                break;
        }
    }
    if (self.showControls) {
        for (int i = 0; i < self.elements.count; i++) {
            AVBezierElement *element = self.elements[i];
            for (int k = 0; k < element.controlPoints.count; k++) {
                UIBezierPath *controlPath = [[UIBezierPath alloc] init];
                [controlPath addArcWithCenter:[element.controlPoints[k] CGPointValue] radius:2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
                [path appendPath:controlPath];
            }
        }
    }
    if (self.showPoint) {
        for (int i = 0; i < self.elements.count; i++) {
            AVBezierElement *element = self.elements[i];
            UIBezierPath *controlPath = [[UIBezierPath alloc] init];
            [controlPath addArcWithCenter:element.point radius:2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
            [path appendPath:controlPath];
        }
    }
    return path;
}

- (AVBezier *)fitCurve:(CGFloat)errorThreshold {
    if (self.elements.count < 2) {
        return self;
    }
    
    CGPoint leftTangentVector = [self fb_computeLeftTangentAtIndex:0];
    CGPoint rightTangentVector = [self fb_computeRightTangentAtIndex:self.elements.count - 1];
    AVBezier *bezier = [self fb_fitCubicToRange:NSMakeRange(0, self.elements.count) leftTangent:leftTangentVector rightTangent:rightTangentVector errorThreshold:errorThreshold];
    bezier.showControls = self.showControls;
    bezier.showPoint = self.showPoint;
    return bezier;
}

- (AVBezier *) fb_fitCubicToRange:(NSRange)range leftTangent:(CGPoint)leftTangent rightTangent:(CGPoint)rightTangent errorThreshold:(CGFloat)errorThreshold {
    // Handle the special case where we only have two points
    if (range.length == 2) {
        return [self fb_fitBezierUsingNaiveMethodInRange:range leftTangent:leftTangent rightTangent:rightTangent];
    }
    
    // First thing, just try to fit one bezier curve to all our points in range
    NSArray *parameters = [self fb_estimateParametersUsingChordLengthMethodInRange:range];
    AVBezier *bezier = [self fb_fitBezierInRange:range withParameters:parameters leftTangent:leftTangent rightTangent:rightTangent];
    
    // See how well our bezier fit our points. If it's within the allowed error, we're done
    NSUInteger maximumIndex = NSNotFound;
    CGFloat error = [self fb_findMaximumErrorForBezier:bezier inRange:range parameters:parameters maximumIndex:&maximumIndex];
    if ( error < errorThreshold ) {
        return bezier;
    }
    
    // Huh. That wasn't good enough. Well, our estimated parameters probably sucked, so see if it makes sense to try
    //  to refine them. If error is huge, it probably means that probably won't help, so in that case just skip it.
    if ( error < (errorThreshold * errorThreshold) ) {
        for (NSUInteger i = 0; i < FitCurveMaximumReparameterizes; i++) {
            parameters = [self fb_refineParameters:parameters forRange:range bezier:bezier];
            // OK, try again with the new parameters
            bezier = [self fb_fitBezierInRange:range withParameters:parameters leftTangent:leftTangent rightTangent:rightTangent];
            error = [self fb_findMaximumErrorForBezier:bezier inRange:range parameters:parameters maximumIndex:&maximumIndex];
            if ( error < errorThreshold ) {
                return bezier; // sweet, it worked!
            }
        }
    }
    
    // Alright, we couldn't fit a single bezier curve to all these points no matter how much we refined the parameters.
    //  Instead, split the points into two parts based on where the biggest error is. Build two separate curves which
    //  we'll combine into one single NSBezierPath.
    CGPoint centerTangent = [self fb_computeCenterTangentAtIndex:maximumIndex];
    AVBezier *leftBezier = [self fb_fitCubicToRange:NSMakeRange(range.location, maximumIndex - range.location + 1) leftTangent:leftTangent rightTangent:centerTangent errorThreshold:errorThreshold];
    AVBezier *rightBezier = [self fb_fitCubicToRange:NSMakeRange(maximumIndex, (range.location + range.length) - maximumIndex) leftTangent:FBNegatePoint(centerTangent) rightTangent:rightTangent errorThreshold:errorThreshold];
    [leftBezier fb_appendPath:rightBezier];
    return leftBezier;
}

- (void) fb_appendPath:(AVBezier *)path {
    AVBezierElement *previousElement = self.elements[self.elements.count - 1];
    for (NSUInteger i = 0; i < path.elements.count; i++) {
        AVBezierElement *element = path.elements[i];
        // If the first element is a move to where we left off, skip it
        if ( element.kind == 0 ) {
            if ( CGPointEqualToPoint(element.point, previousElement.point)) {
                continue;
            } else {
                element.kind = 1;
            }
        }
        
        [self.elements addObject:element];
        previousElement = element;
    }
}
- (NSArray *) fb_refineParameters:(NSArray *)parameters forRange:(NSRange)range bezier:(AVBezier *)bezier {
    // Use Newton's Method to refine our parameters.
    NSMutableArray *refinedParameters = [NSMutableArray arrayWithCapacity:range.length];
    for (NSUInteger i = 0; i < range.length; i++) {
        [refinedParameters addObject:[NSNumber numberWithFloat:NewtonsMethod(bezier, [self fb_pointAtIndex:range.location + i], [[parameters objectAtIndex:i] floatValue])]];
    }
    return refinedParameters;
}
- (CGFloat) fb_findMaximumErrorForBezier:(AVBezier *)bezier inRange:(NSRange)range parameters:(NSArray *)parameters maximumIndex:(NSUInteger *)maximumIndex {
    // Here we calculate the squared errors, defined as:
    //
    //  S = SUM( (point[i] - Q(parameters[i])) ^ 2 )
    //
    //  Where point[i] is the point on this NSBezierPath at i, parameters[i] is the float in the parameters
    //  NSArray at index i. Q is the bezier curve represented by the variable bezier. This formula takes
    //  the difference (distance) between a point in this NSBezierPath we're trying to fit, and the corresponding
    //  point in the generated bezier curve, squares it, and adds all the differences up (i.e. squared errors).
    //  This tells us how far off our curve is from our points we're trying to fit.
    CGFloat maximumError = 0.0;
    for (NSUInteger i = 1; i < (range.length - 1); i++) {
        CGPoint pointOnQ = Bezier(3, bezier, [[parameters objectAtIndex:i] floatValue]); // Calculate Q(parameters[i])
        CGPoint point = [self fb_pointAtIndex:range.location + i];
        CGFloat distance = FBPointSquaredLength(FBSubtractPoint(pointOnQ, point));
        if ( distance >= maximumError ) {
            maximumError = distance;
            *maximumIndex = range.location + i;
        }
    }
    return maximumError;
}

- (AVBezier *) fb_fitBezierUsingNaiveMethodInRange:(NSRange)range leftTangent:(CGPoint)leftTangent rightTangent:(CGPoint)rightTangent {
    // This is a fallback method for when our normal bezier curve fitting method fails, either due to too few points
    //  or other anomalies. As with the normal curve fitting, we have the two end points and the direction of the two control
    //  points, meaning we only lack the distance of the control points from their end points. However, instead of getting
    //  all fancy pants in calculating those distances we just throw up our hands and guess that it's a third of the distance between
    //  the two end points. It's a heuristic, and not a good one.
    
    AVBezier *result = [[AVBezier alloc] init];
    
    
    CGFloat thirdOfDistance = FBDistanceBetweenPoints([self fb_pointAtIndex:range.location + 1], [self fb_pointAtIndex:range.location]) / 3.0;
    
    [result moveToPoint:[self fb_pointAtIndex:range.location]];
    [result curveToPoint:[self fb_pointAtIndex:range.location + 1] controlPoint1:FBAddPoint([self fb_pointAtIndex:range.location], FBUnitScalePoint(leftTangent, thirdOfDistance)) controlPoint2:FBAddPoint([self fb_pointAtIndex:range.location + 1], FBUnitScalePoint(rightTangent, thirdOfDistance))];
    
    return result;
}

- (void)moveToPoint:(CGPoint)point {
    AVBezierElement *element = [[AVBezierElement alloc] init];
    element.kind = 0;
    element.point = point;
    [self.elements addObject:element];
}

- (void)curveToPoint:(CGPoint)point controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2 {
    AVBezierElement *element = [[AVBezierElement alloc] init];
    element.kind = 2;
    element.point = point;
    [element.controlPoints addObject:[NSValue valueWithCGPoint:controlPoint1]];
    [element.controlPoints addObject:[NSValue valueWithCGPoint:controlPoint2]];
    [self.elements addObject:element];
}

- (CGPoint)fb_pointAtIndex:(NSInteger)index {
    return self.elements[index].point;
}

- (CGPoint) fb_computeLeftTangentAtIndex:(NSUInteger)index {
    return FBNormalizePoint( FBSubtractPoint([self fb_pointAtIndex:index + 1], [self fb_pointAtIndex:index]) );
}

- (CGPoint) fb_computeRightTangentAtIndex:(NSUInteger)index {
    return FBNormalizePoint( FBSubtractPoint([self fb_pointAtIndex:index - 1], [self fb_pointAtIndex:index]) );
}

- (CGPoint) fb_computeCenterTangentAtIndex:(NSUInteger)index {
    // Compute the tangent unit vector with index as the center. We'll calculate the vectors on both sides
    //  of index and then average them together.
    CGPoint vector1 = FBSubtractPoint([self fb_pointAtIndex:index - 1], [self fb_pointAtIndex:index]);
    CGPoint vector2 = FBSubtractPoint([self fb_pointAtIndex:index], [self fb_pointAtIndex:index + 1]);
    return FBNormalizePoint(CGPointMake((vector1.x + vector2.x) / 2.0, (vector1.y + vector2.y) / 2.0));
}

- (NSArray *) fb_estimateParametersUsingChordLengthMethodInRange:(NSRange)range {
    NSMutableArray *distances = [NSMutableArray arrayWithCapacity:range.length];
    [distances addObject:[NSNumber numberWithFloat:0.0]]; // First one is always 0 (see above)
    CGFloat totalDistance = 0.0;
    for (NSUInteger i = 1; i < range.length; i++) {
        // Calculate the total distance along the curve up to this point
        totalDistance += FBDistanceBetweenPoints([self fb_pointAtIndex:range.location + i], [self fb_pointAtIndex:range.location + i - 1]);
        [distances addObject:[NSNumber numberWithFloat:totalDistance]];
    }
    
    // Now go through and normalize the distances to in the range [0..1]
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:range.length];
    for (NSNumber *distance in distances)
        [parameters addObject:[NSNumber numberWithFloat:[distance floatValue] / totalDistance]];
    
    return parameters;
}

- (AVBezier *) fb_fitBezierInRange:(NSRange)range withParameters:(NSArray *)parameters leftTangent:(CGPoint)leftTangent rightTangent:(CGPoint)rightTangent {
    NSMutableArray<NSValue *> *a1 = [[NSMutableArray alloc] init];
    NSMutableArray<NSValue *> *a2 = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < range.length; i++) {
        a1[i] = [NSValue valueWithCGPoint:FBUnitScalePoint(leftTangent, Bernstein1([[parameters objectAtIndex:i] floatValue]))];
        a2[i] = [NSValue valueWithCGPoint:FBUnitScalePoint(rightTangent, Bernstein2([[parameters objectAtIndex:i] floatValue]))];
    }
    
    // Create the C1, C2, and X matrices
    CGFloat c1[2] = {};
    CGFloat c2[2] = {};
    CGFloat x[2] = {};
    CGPoint partOfX = CGPointZero;
    CGPoint leftEndPoint = [self fb_pointAtIndex:range.location];
    CGPoint rightEndPoint = [self fb_pointAtIndex:range.location + range.length - 1];
    for (NSUInteger i = 0; i < range.length; i++) {
        c1[0] += FBDotMultiplyPoint([a1[i] CGPointValue], [a1[i] CGPointValue]);
        c1[1] += FBDotMultiplyPoint([a1[i] CGPointValue], [a2[i] CGPointValue]);
        c2[0] += FBDotMultiplyPoint([a1[i] CGPointValue], [a2[i] CGPointValue]);
        c2[1] += FBDotMultiplyPoint([a2[i] CGPointValue], [a2[i] CGPointValue]);
        
        partOfX = FBSubtractPoint([self fb_pointAtIndex:range.location + i],
                                  FBAddPoint(FBScalePoint(leftEndPoint, Bernstein0([[parameters objectAtIndex:i] floatValue])),
                                             FBAddPoint(FBScalePoint(leftEndPoint, Bernstein1([[parameters objectAtIndex:i] floatValue])),
                                                        FBAddPoint(FBScalePoint(rightEndPoint, Bernstein2([[parameters objectAtIndex:i] floatValue])),
                                                                   FBScalePoint(rightEndPoint, Bernstein3([[parameters objectAtIndex:i] floatValue]))))));
        
        x[0] += FBDotMultiplyPoint(partOfX, [a1[i] CGPointValue]);
        x[1] += FBDotMultiplyPoint(partOfX, [a2[i] CGPointValue]);
    }
    
    [a1 removeAllObjects];
    [a2 removeAllObjects];
    
    // Calculate left and right alpha
    CGFloat c1AndC2 = Determinant(c1, c2);
    CGFloat xAndC2 = Determinant(x, c2);
    CGFloat c1AndX = Determinant(c1, x);
    CGFloat leftAlpha = 0.0;
    CGFloat rightAlpha = 0.0;
    if ( c1AndC2 != 0 ) {
        leftAlpha = xAndC2 / c1AndC2;
        rightAlpha = c1AndX / c1AndC2;
    }
    
    // If the alpha values are too small or negative, things aren't going to work out well. Fall back
    //  to the simple heuristic
    CGFloat verySmallValue = 1.0e-6 * FBDistanceBetweenPoints(leftEndPoint, rightEndPoint);
    if ( leftAlpha < verySmallValue || rightAlpha < verySmallValue )
        return [self fb_fitBezierUsingNaiveMethodInRange:range leftTangent:leftTangent rightTangent:rightTangent];
    
    // We already have the end points, so we just need the control points. Use alpha values
    //  to calculate those
    CGPoint leftControlPoint = FBAddPoint(FBUnitScalePoint(leftTangent, leftAlpha), leftEndPoint);
    CGPoint rightControlPoint = FBAddPoint(FBUnitScalePoint(rightTangent, rightAlpha), rightEndPoint);
    
    // Create the bezier path based on the end and control points we calculated
    AVBezier *path = [[AVBezier alloc] init];
    [path moveToPoint:leftEndPoint];
    [path curveToPoint:rightEndPoint controlPoint1:leftControlPoint controlPoint2:rightControlPoint];
    return path;
}

- (NSInteger)curveCount {
    NSInteger count = 0;
    for (int i = 0; i < self.elements.count; i++) {
        if (self.elements[i].kind == 2) {
            count++;
        }
    }
    return count;
}

@end
