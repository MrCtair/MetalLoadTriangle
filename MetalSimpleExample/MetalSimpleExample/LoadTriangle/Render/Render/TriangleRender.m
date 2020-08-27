//
//  TriangleRender.m
//  MetalSimpleExample
//
//  Created by trs on 2020/8/21.
//  Copyright © 2020 ctair. All rights reserved.
//

#import "TriangleRender.h"
#import "TriangleTypes.h"

@implementation TriangleRender{
    
    //我们用来渲染的设备(又名GPU)
    id <MTLDevice> _device;
    
    //渲染管道的顶点和片元着色器位于.metal文件中
    id <MTLRenderPipelineState> _pipelineState;
    
    //命令队列
    id <MTLCommandQueue> _commandQueue;
    
    //当前视图大小
    vector_uint2 _viewportSize;
}
- (instancetype)initWithMetalkView:(MTKView *)mtkView{
    self = [super init];
    if (self) {
        NSError * error = NULL;
        
        // 获取GPU
        _device = mtkView.device;

        /// 在项目中加载所有的着色器文件
        //从bundle中获取.metal文件
        id <MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        //从库中加载顶点函数
        id <MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        //从库中加载片元函数
        id <MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        //配置用于创建管道状态的管道
        MTLRenderPipelineDescriptor * pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        //管道名称
        pipelineDescriptor.label = @"simple pipeline";
        //可编程函数,用于处理渲染过程中的各个顶点
        pipelineDescriptor.vertexFunction = vertexFunction;
        //可编程函数,用于处理渲染过程中的各个片元/片段
        pipelineDescriptor.fragmentFunction = fragmentFunction;
        //存储颜色数据的组件
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        // 同步创建，并返回渲染管线状态
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
        //判断是否返回了管线状态
        if (!_pipelineState) {
            //如果我们没有正确设置管道描述符，则管道状态创建可能失败
            NSLog(@"Failed to created pipeline state, error %@", error);
            return nil;
        }
        
        //创建命令队列
        _commandQueue = [_device newCommandQueue];
    }
    return self;
}


#pragma mark -- MTKViewDelegate
- (void)drawInMTKView:(nonnull MTKView *)view {
    //设置背景色
    view.clearColor = MTLClearColorMake(1, 1, 1, 1);
   // 顶点、颜色数据
    static const TriangleVertex triangleVertices[] =
    {
        {{ 0.5, -0.25, 0.0, 1.0}, {1.0, 0.0, 0.0, 1.0}},
        {{-0.5, -0.25, 0.0, 1.0}, {0.0, 1.0, 0.0, 1.0}},
        {{-0.0,  0.25, 0.0, 1.0}, {0.0, 0.0, 1.0, 1.0}},
    };
    
    //为当前渲染的每个每个渲染传递创建一个新的命令缓冲区
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    //指定缓冲区名字
    commandBuffer.label = @"commandBuffer";
    
    //MTLRenderPassDescriptor:一组渲染目标，用作渲染通道生成的像素的输出目标（描述信息）
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        //创建渲染命令编码器,这样我们才可以渲染到something
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        //命名
        renderEncoder.label = @"My RenderEncoder";
        
        //设置绘制区域
        /*
        typedef struct {
            double originX, originY, width, height, znear, zfar;
        } MTLViewport;
         */
        //视口指定Metal渲染内容的drawable区域。 视口是具有x和y偏移，宽度和高度以及近和远平面的3D区域
        //为管道分配自定义视口需要通过调用setViewport：方法将MTLViewport结构编码为渲染命令编码器。 如果未指定视口，Metal会设置一个默认视口，其大小与用于创建渲染命令编码器的drawable相同。
        MTLViewport viewPort = {
            0.0 , 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0
        };
        [renderEncoder setViewport:viewPort];
        
        //设置当前渲染管道状态对象
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        // 从应用中发送数据到metal顶点着色器函数
        //顶点数据+颜色数据
        //   1) 指向要传递给着色器的内存的指针
        //   2) 我们想要传递的数据的内存大小
        //   3)一个整数索引，它对应于我们的“vertexShader”函数中的缓冲区属性限定符的索引。
        [renderEncoder setVertexBytes:triangleVertices
                               length:sizeof(triangleVertices)
                              atIndex:TriangleVertexInputIndexVertices];
        
        //viewPortSize 数据
        //1) 发送到顶点着色函数中,视图大小
        //2) 视图大小内存空间大小
        //3) 对应的索引
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:TriangleVertexInputIndexViewpostSize];
        
        //画出三角形的三个顶点
        // @method drawPrimitives:vertexStart:vertexCount:
        //@brief 在不使用索引列表的情况下,绘制图元
        //@param 绘制图形组装的基元类型
        //@param 从哪个位置数据开始绘制,一般为0
        //@param 每个图元的顶点个数,绘制的图型顶点数量
        /*
         MTLPrimitiveTypePoint = 0, 点
         MTLPrimitiveTypeLine = 1, 线段
         MTLPrimitiveTypeLineStrip = 2, 线环
         MTLPrimitiveTypeTriangle = 3,  三角形
         MTLPrimitiveTypeTriangleStrip = 4, 三角型扇
         */
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:3];
        
        //表示已该编码器生成的命令都已完成,并且从MTLCommandBuffer中分离
        [renderEncoder endEncoding];
        
        //
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
     // 保存可绘制的大小，因为当我们绘制时，我们将把这些值传递给顶点着色器
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

@end
