//
//  HelloMetalViewController.m
//  MetalSimpleExample
//
//  Created by trs on 2020/8/20.
//  Copyright © 2020 ctair. All rights reserved.
//

#import "HelloMetalViewController.h"
#import "HelloRender.h"
#import <Masonry/Masonry.h>
@import MetalKit;

@interface HelloMetalViewController ()
@property (nonatomic, strong) MTKView * mtkView;
@property (nonatomic, strong) HelloRender * render;
@end

@implementation HelloMetalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)prepareForData{
    self.navigationItem.title = @"Hello Metal";
}
- (void)prepareForView{
    _mtkView = [[MTKView alloc] init];
    [self.view addSubview:self.mtkView];
    [_mtkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self.view);
    }];
    
    //为mtkViw设置device
    //一个MTLDevice 对象就代表这着一个GPU,通常我们可以调用方法MTLCreateSystemDefaultDevice()来获取代表默认的GPU单个对象.
    _mtkView.device = MTLCreateSystemDefaultDevice();
    
    if (!_mtkView.device) {
        NSLog(@"Metal is not supported on this device");
        return;
    }
    
    //创建helloRender
    //在我们开发Metal 程序时,将渲染循环分为自己创建的类,是非常有用的一种方式,使用单独的类,我们可以更好管理初始化Metal,以及Metal视图委托.
    _render = [[HelloRender alloc] initWithMetalKitView:_mtkView];
    
    if (!_render) {
        NSLog(@"Renderer failed initialization");
        return;
    }
    //设置MTKView 的代理(由CCRender来实现MTKView 的代理方法)
    _mtkView.delegate = _render;
 
    //视图可以根据视图属性上设置帧速率(指定时间来调用drawInMTKView方法--视图需要渲染时调用)
    _mtkView.preferredFramesPerSecond = 60;
}
- (void)prepareForAction{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
