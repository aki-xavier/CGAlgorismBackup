//
//  AVBezierElement.m
//  avocado
//
//  Created by 黒田一真 on 2019/4/7.
//  Copyright © 2019 黒田一真. All rights reserved.
//

#import "AVBezierElement.h"

@implementation AVBezierElement

- (NSMutableArray<NSValue *> *)controlPoints {
    if (_controlPoints == nil) {
        _controlPoints = [[NSMutableArray alloc] init];
    }
    return _controlPoints;
}

@end
