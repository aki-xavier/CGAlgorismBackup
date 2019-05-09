//
//  AVBezierElement.h
//  avocado
//
//  Created by 黒田一真 on 2019/4/7.
//  Copyright © 2019 黒田一真. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVBezierElement : NSObject

@property (nonatomic) CGPoint point;
@property (strong, nonatomic) NSMutableArray<NSValue *> *controlPoints;
@property (nonatomic) NSInteger kind; // 0: moveTo, 1: lineTo, 2: curveTo, 3: close

@end

NS_ASSUME_NONNULL_END
