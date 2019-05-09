//
//  AVGeometry.h
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

CGFloat FBDistanceBetweenPoints(CGPoint point1, CGPoint point2);
CGFloat FBDistancePointToLine(CGPoint point, CGPoint lineStartPoint, CGPoint lineEndPoint);

CGPoint FBAddPoint(CGPoint point1, CGPoint point2);
CGPoint FBScalePoint(CGPoint point, CGFloat scale);
CGPoint FBUnitScalePoint(CGPoint point, CGFloat scale);
CGPoint FBSubtractPoint(CGPoint point1, CGPoint point2);
CGFloat FBDotMultiplyPoint(CGPoint point1, CGPoint point2);
CGFloat FBPointLength(CGPoint point);
CGFloat FBPointSquaredLength(CGPoint point);
CGPoint FBNormalizePoint(CGPoint point);
CGPoint FBNegatePoint(CGPoint point);

NS_ASSUME_NONNULL_END
