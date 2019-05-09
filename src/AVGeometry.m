//
//  AVGeometry.m
//

#import "AVGeometry.h"

CGFloat FBDistanceBetweenPoints(CGPoint point1, CGPoint point2) {
    CGFloat xDelta = point2.x - point1.x;
    CGFloat yDelta = point2.y - point1.y;
    return sqrtf(xDelta * xDelta + yDelta * yDelta);
}

CGFloat FBDistancePointToLine(CGPoint point, CGPoint lineStartPoint, CGPoint lineEndPoint) {
    CGFloat lineLength = FBDistanceBetweenPoints(lineStartPoint, lineEndPoint);
    if (lineLength == 0) {
        return 0;
    }
    CGFloat u = ((point.x - lineStartPoint.x) * (lineEndPoint.x - lineStartPoint.x) + (point.y - lineStartPoint.y) * (lineEndPoint.y - lineStartPoint.y)) / (lineLength * lineLength);
    CGPoint intersectionPoint = CGPointMake(lineStartPoint.x + u * (lineEndPoint.x - lineStartPoint.x), lineStartPoint.y + u * (lineEndPoint.y - lineStartPoint.y));
    return FBDistanceBetweenPoints(point, intersectionPoint);
}

CGPoint FBAddPoint(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

CGPoint FBUnitScalePoint(CGPoint point, CGFloat scale) {
    CGPoint result = point;
    CGFloat length = FBPointLength(point);
    if (length != 0.0) {
        result.x *= scale/length;
        result.y *= scale/length;
    }
    return result;
}

CGPoint FBScalePoint(CGPoint point, CGFloat scale) {
    return CGPointMake(point.x * scale, point.y * scale);
}

CGFloat FBDotMultiplyPoint(CGPoint point1, CGPoint point2) {
    return point1.x * point2.x + point1.y * point2.y;
}

CGPoint FBSubtractPoint(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

CGFloat FBPointLength(CGPoint point) {
    return sqrtf((point.x * point.x) + (point.y * point.y));
}

CGFloat FBPointSquaredLength(CGPoint point) {
    return (point.x * point.x) + (point.y * point.y);
}

CGPoint FBNormalizePoint(CGPoint point) {
    CGPoint result = point;
    CGFloat length = FBPointLength(point);
    if (length != 0.0) {
        result.x /= length;
        result.y /= length;
    }
    return result;
}

CGPoint FBNegatePoint(CGPoint point) {
    return CGPointMake(-point.x, -point.y);
}
