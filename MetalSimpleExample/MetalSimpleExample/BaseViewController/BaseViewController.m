//
//  BaseViewController.m
//  MetalSimpleExample
//
//  Created by trs on 2020/8/20.
//  Copyright © 2020 ctair. All rights reserved.
//

#import "BaseViewController.h"
#import <Masonry/Masonry.h>

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self prepareForData];
    [self prepareForView];
    [self prepareForAction];
}
- (void)prepareForData{
    
}
- (void)prepareForView{
    
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
