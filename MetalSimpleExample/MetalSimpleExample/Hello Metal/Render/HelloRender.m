//
//  HelloRender.m
//  MetalSimpleExample
//
//  Created by trs on 2020/8/20.
//  Copyright © 2020 ctair. All rights reserved.
//

#import "HelloRender.h"

@implementation HelloRender{
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
}
// 颜色结构体
typedef struct{
    float red, green, blue, alph;
}Color;

- (id)initWithMetalKitView:(MTKView *)mtkView{
    self = [super init];
    if (self) {
        _device = mtkView.device;
        
        //所有应用程序需要与GPU交互的第一个对象是一个MTLCommandQueue对象
        //你使用MTLCommandQueue去创建对象,并且加入MTLCommandBuffer对象中.确保它们能够按照正确顺序发送到GPU.对于每一帧,一个新的MTLCommandBuffer 对象创建并且填满了由GPU执行的命令.
        _commandQueue = [_device newCommandQueue];
    }
    
    return self;
}

- (Color)getDisplayColor{
    //增加/减少颜色的标记
    static BOOL growing = YES;
    //颜色通道值
    static NSUInteger primaryChannel = 0;
    //颜色通道数组
    static float colorChannels[] = {1.0, 0.0, 0.0, 1.0};
    //颜色调整步长
    const float dynamicColorRite = 0.020;
    
    //判断
    if (growing) {
        //动态通道索引（1，2，3，0）通道间切换
        NSUInteger dynamicChannelIndex = (primaryChannel + 1) % 3;
        
        colorChannels[dynamicChannelIndex] += dynamicColorRite;
        
        if (colorChannels[dynamicChannelIndex] >= 1.0) {
            
            //不再增长
            growing = NO;
            
            //将颜色通道修改为动态颜色通道
            primaryChannel = dynamicChannelIndex;
        }
    }else{
        //动态通道索引（1，2，3，0）通道间切换
        NSUInteger dynamicChannelIndex = (primaryChannel + 1) % 3;
        
        //将当前颜色的值 减去0.015
        colorChannels[dynamicChannelIndex] -= dynamicColorRite;
        
        //当颜色值小于等于0.0
        if(colorChannels[dynamicChannelIndex] <= 0.0) {
            //又调整为颜色增加
            growing = YES;
        }
    }
    
    Color color;
    color.red = colorChannels[0];
    color.green = colorChannels[1];
    color.blue = colorChannels[2];
    color.alph = colorChannels[3];
    
    return color;
}


#pragma mark -- MKTViewDelegate
//每当视图需要渲染时调用
- (void)drawInMTKView:(nonnull MTKView *)view {
    // 获取颜色值
    Color color = [self getDisplayColor];
    
    //设置view的color
    view.clearColor = MTLClearColorMake(color.red, color.green, color.blue, color.alph);
    
    //Create a new command buffer for each render pass to the current drawable
    //使用MTLCommandQueue 创建对象并且加入到MTCommandBuffer对象中去.
    //为当前渲染的每个渲染传递创建一个新的命令缓冲区
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"My Command";
    
    //从视图绘制中获得渲染描述符
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil) {
        //通过渲染描述符renderPassDescriptor创建MTLRenderCommandEncoder 对象
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"My RenderEncoder";
        
        //我们可以使用MTLRenderCommandEncoder 来绘制对象,但是这个demo我们仅仅创建编码器就可以了,我们并没有让Metal去执行我们绘制的东西,这个时候表示我们的任务已经完成.
        //即可结束MTLRenderCommandEncoder 工作
        [renderEncoder endEncoding];
        
        /*
         当编码器结束之后,命令缓存区就会接受到2个命令.
         1) present
         2) commit
         因为GPU是不会直接绘制到屏幕上,因此你不给出去指令.是不会有任何内容渲染到屏幕上.
        */
        //添加一个最后的命令来显示清除的可绘制的屏幕
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    //在这里完成渲染并将命令缓冲区提交给GPU
    [commandBuffer commit];
}

//当MTKView视图发生大小改变时调用
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

@end
