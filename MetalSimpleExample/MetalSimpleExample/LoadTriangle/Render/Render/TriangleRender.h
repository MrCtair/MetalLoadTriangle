//
//  TriangleRender.h
//  MetalSimpleExample
//
//  Created by trs on 2020/8/21.
//  Copyright © 2020 ctair. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MetalKit;
NS_ASSUME_NONNULL_BEGIN

@interface TriangleRender : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalkView:(MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
