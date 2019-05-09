//
//  AVBezier.h
//

#import "AVBezierElement.h"
#import "AVGeometry.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVBezier : NSObject

@property(strong, nonatomic) NSMutableArray<AVBezierElement *> *elements;
@property(nonatomic) BOOL showControls;
@property(nonatomic) BOOL showPoint;

- (UIBezierPath *)createPath;
- (AVBezier *)fitCurve:(CGFloat)errorThreshold;
- (NSInteger)curveCount;

@end

NS_ASSUME_NONNULL_END
