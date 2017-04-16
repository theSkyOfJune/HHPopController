//
//  HHPopController.h
//  HHKangarooManager
//
//  Created by HHIOS on 2017/4/16.
//  Copyright © 2017年 LiYang. All rights reserved.
//  仿微信QQ带箭头弹窗控制器


#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSString *const HHPopControllerWillPopNotification;
FOUNDATION_EXTERN NSString *const HHPopControllerDidPopNotification;
FOUNDATION_EXTERN NSString *const HHPopControllerWillHidenNotification;
FOUNDATION_EXTERN NSString *const HHPopControllerDidHidenNotification;

/// 箭头方式
typedef NS_ENUM(NSInteger, HHArrowStyle) {
    HHArrowStyleVerticalDefault = 0, ///< up or down based on source view location in window
    HHArrowStyleHorizontalDefault, ///< left or right based on source view location in window
    HHArrowStyleUp,///< up force
    HHArrowStyleDown,/// < down force
    HHArrowStyleLeft,///< left force
    HHArrowStyleRight///< right force
};

/// 弹出视图数据模型
@interface HHPopItem : NSObject
+ (instancetype)itemWithTitle:(NSString *)title;
+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title;
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, strong)NSString *title;
- (void)setHandler:(void (^)(NSInteger idx, HHPopItem *item))handler;
@end


/// 弹出视图的追加视图模型 (header and footer)
@interface HHPopSupplementaryStyle : NSObject

/// 标题
@property (nonatomic, copy)NSString *title;
/// 标题高度
@property (nonatomic, assign)CGFloat height;
/// 标题文字对齐方式
@property (nonatomic, assign)NSTextAlignment titleAligment;
/// 标题文字颜色
@property (nonatomic, strong)UIColor *titleColor;
/// 标题背景颜色
@property (nonatomic, assign)UIColor *bgColor;
/// 标题文字字体
@property (nonatomic, strong)UIFont *titleFont;
/// 自定义头部视图
@property (nonatomic, strong)UIView *customView;

+ (instancetype)defaultStyle;

@end

/// 弹出视图样式模型
@interface HHPopStyle : NSObject

/// 弹出视图的宽度
@property (nonatomic, assign)CGFloat popWidth;

/// 边框颜色
@property (nonatomic, strong)UIColor *borderColor;
/// 边框宽度
@property (nonatomic, assign)CGFloat borderWidth;


/// 行高
@property (nonatomic, assign)CGFloat rowHeight;
/// 圆角尺寸
@property (nonatomic, assign)CGFloat cornerRadius;
/// 蒙版颜色
@property (nonatomic, strong)UIColor *dimColor;
/// 箭头方向
@property (nonatomic, assign)HHArrowStyle arrowStyle;
/// 箭头离矩形边框的距离大小
@property (nonatomic, assign)CGFloat arrowDistanceFromTargetRectBorder;
/// 箭头尺寸, 对应三角形的宽高 default {15, 8}
@property (nonatomic, assign)CGSize arrowSize;
/// 弹框显现的区域限制
@property (nonatomic, assign)UIEdgeInsets popAreaEdgeLimits;
/// 出现的动画时间 default 0.25
@property (nonatomic, assign)CGFloat animationIn;
/// 小时的动画时间 default 0.25
@property (nonatomic, assign)CGFloat animationOut;
/// 是否能滚动 当弹框范围能够容纳的下为NO, 否则为YES
@property (nonatomic, assign)BOOL bounces;

/// 分割线颜色
@property (nonatomic, strong)UIColor *separatorColor;
/// 分割线内边距
@property (nonatomic, assign)UIEdgeInsets separatorInset;

/// 选项的背景颜色
@property (nonatomic, strong)UIColor *itemBgColor;
/// 选项的图片内容模式
@property (nonatomic, assign)UIViewContentMode itemImageContentMode;
/// 选项文字对齐方式
@property (nonatomic, assign)NSTextAlignment itemTextAligment;
/// 选项文字字体
@property (nonatomic, strong)UIFont *itemTextFont;
/// 选项文字颜色
@property (nonatomic, strong)UIColor *itemTextColor;

/// 头部样式
@property (nonatomic, strong)HHPopSupplementaryStyle *header;

/// 尾部样式
@property (nonatomic, strong)HHPopSupplementaryStyle *footer;

+ (instancetype)defaultStyle;

@end

/// 弹出视图控制器
@interface HHPopController : NSObject

+ (void)applyReturnPopStyle:(HHPopStyle *(^)(HHPopStyle *style))maker;

+ (void)applyPopStyle:(void (^)(HHPopStyle *style))maker;

+ (void)popSourceView:(UIView *)view popItems:(NSArray<HHPopItem *> *)items selectionHandler:(void (^)(NSInteger idx, HHPopItem *item))handler;

+ (void)popTargetRect:(CGRect)rect soureceView:(UIView *)view popItems:(NSArray<HHPopItem *> *)items selectionHandler:(void (^)(NSInteger idx, HHPopItem *item))handler;

+ (BOOL)isPopVisible;

+ (void)dismiss;

@end
