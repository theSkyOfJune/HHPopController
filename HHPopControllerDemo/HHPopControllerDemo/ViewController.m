//
//  ViewController.m
//  HHPopControllerDemo
//
//  Created by HHIOS on 2017/4/16.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import "ViewController.h"

#import "HHPopController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willPop:) name:HHPopControllerWillPopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPop:) name:HHPopControllerDidPopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHide:) name:HHPopControllerWillHidenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHide:) name:HHPopControllerDidHidenNotification object:nil];
    
    [self.button addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
    
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint transP = [pan translationInView:self.button];
    self.button.transform = CGAffineTransformTranslate(self.button.transform, transP.x, transP.y);
    [pan setTranslation:CGPointZero inView:self.button];
}

- (void)willPop:(NSNotification *)notify {
    NSLog(@"will pop");
}
- (void)didPop:(NSNotification *)notify {
    NSLog(@"did pop");
}
- (void)willHide:(NSNotification *)notify {
    NSLog(@"will hide");
}
- (void)didHide:(NSNotification *)notify {
    NSLog(@"did hide");
}


- (IBAction)btnClick:(UIButton *)btn {
    
    HHPopItem *item1 = [HHPopItem itemWithImage:[UIImage imageNamed:@"ic_addvoucher_qrcode"] title:@"创建群聊"];
    HHPopItem *item2 = [HHPopItem itemWithImage:[UIImage imageNamed:@"ic_addvoucher_cinema"] title:@"加好友/群"];
    HHPopItem *item3 = [HHPopItem itemWithImage:[UIImage imageNamed:@"ic_addvoucher_input"] title:@"面对面快传"];
    [HHPopController applyPopStyle:^(HHPopStyle *style) {
        
        style.borderColor = [UIColor cyanColor];
        style.borderWidth = 1.0f;
        style.itemTextColor = [UIColor whiteColor];
        style.dimColor = [UIColor colorWithWhite:0.1 alpha:0.3];
        style.itemBgColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        
//        HHPopSupplementaryStyle *header = [HHPopSupplementaryStyle defaultStyle];
//        header.bgColor = style.itemBgColor;
//        header.title = @"header";
//        header.titleColor = [UIColor whiteColor];
//        style.header = header;
//        
//        HHPopSupplementaryStyle *footer = [HHPopSupplementaryStyle defaultStyle];
//        footer.bgColor = style.itemBgColor;
//        footer.title = @"footer";
//        footer.titleColor = [UIColor whiteColor];
//        style.footer = footer;
    }];
    [HHPopController popSourceView:btn popItems:@[item1, item2, item3] selectionHandler:^(NSInteger idx, HHPopItem *item) {
        NSLog(@"%@", item.title);
    }];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
