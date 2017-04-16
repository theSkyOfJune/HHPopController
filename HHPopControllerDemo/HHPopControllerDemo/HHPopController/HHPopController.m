//
//  HHPopController.m
//  HHKangarooManager
//
//  Created by HHIOS on 2017/4/16.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import "HHPopController.h"

#ifndef    weakify
#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")
#endif

#ifndef    strongify
#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")
#endif


NSString *const HHPopControllerWillPopNotification = @"HHPopControllerWillPopNotification";
NSString *const HHPopControllerDidPopNotification = @"HHPopControllerDidPopNotification";
NSString *const HHPopControllerWillHidenNotification = @"HHPopControllerWillHidenNotification";
NSString *const HHPopControllerDidHidenNotification = @"HHPopControllerDidHidenNotification";

static NSString *const HHMediumFont = @"PingFangSC-Medium";
static NSString *const HHRegularFont = @"PingFangSC-Regular";
static inline NSNotificationCenter *HHNotificationCenter() { return [NSNotificationCenter defaultCenter]; }
static inline UIFont *HHFont(CGFloat size) {
    return [UIFont fontWithName:HHRegularFont size:size];
}
static inline UIWindow *HHKeyWindow() {
    return [UIApplication sharedApplication].keyWindow;
}
static inline UIEdgeInsets HHEdgeInsetsInset(UIEdgeInsets edge, UIEdgeInsets delta) {
    return (UIEdgeInsets){edge.top+delta.top, edge.left+delta.left, edge.bottom+delta.bottom, edge.right+delta.right};
}
static inline CGRect HHRectReduceEdgeInsets(CGRect rect, UIEdgeInsets insets) {
    return (CGRect){rect.origin.x + insets.left, rect.origin.y + insets.top,
        rect.size.width - insets.left - insets.right,
        rect.size.height - insets.top - insets.bottom};
}
/// 屏幕宽度
static inline CGFloat HHScreenW() { return [UIScreen mainScreen].bounds.size.width; }
/// 屏幕高度
static inline CGFloat HHScreenH() { return [UIScreen mainScreen].bounds.size.height; }

/// 矩形是否有效
static inline BOOL HHRectIsVaild(CGRect rect) {
    return (!CGRectIsEmpty(rect) && !CGRectEqualToRect(rect, CGRectZero));
}

typedef NS_ENUM(NSUInteger, _HHArrowDirection) {
    Up = 0, Down, Left, Right
};


@interface NSString (__HHAdd)
- (CGFloat)widthForFont:(UIFont *)font;
@end
@implementation NSString (__HHAdd)

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont fontWithName:HHRegularFont size:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
            style.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = style;
        }
        CGRect rect = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}
- (CGFloat)widthForFont:(UIFont *)font {
    return [self sizeForFont:font size:(CGSize){HUGE, HUGE} mode:NSLineBreakByWordWrapping].width;
}

@end


@interface UIView (__HHAdd)

@property (nonatomic, assign) CGFloat left;

@property (nonatomic, assign) CGFloat top;

@property (nonatomic, assign) CGFloat right;

@property (nonatomic, assign) CGFloat bottom;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

- (void)masklayerWithRadio:(CGFloat)radio;
@end
@implementation UIView (__HHAdd)
- (CGFloat)left {
    return self.frame.origin.x;
}
- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}
- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.left + self.width;
}
- (void)setRight:(CGFloat)right {
    if(right == self.right){
        return;
    }
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.top + self.height;
}
- (void)setBottom:(CGFloat)bottom {
    if(bottom == self.bottom){
        return;
    }
    
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


- (CGFloat)width {
    return self.frame.size.width;
}
- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}


- (CGFloat)height {
    return self.frame.size.height;
}
- (void)setHeight:(CGFloat)height {
    if(height == self.height){
        return;
    }
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}
- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}
- (CGFloat)centerY {
    return self.center.y;
}
- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}
- (void)masklayerWithRadio:(CGFloat)radio {
    CGSize radios = CGSizeMake(radio, radio);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:radios];
    CAShapeLayer *masklayer = [[CAShapeLayer alloc]init];
    masklayer.frame = self.bounds;
    masklayer.path = path.CGPath;
    self.layer.mask = masklayer;
}

@end


@interface UITableView (__HHAdd)
- (__kindof UITableViewCell *)dequeueReusableCell:(Class)cls;
- (__kindof UITableViewHeaderFooterView *)dequeueResuseHeaderFooterView:(Class)cls;
@end
@implementation UITableView (__HHAdd)
- (__kindof UITableViewCell *)dequeueReusableCell:(Class)cls {
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:NSStringFromClass([cls class])];
    if (!cell) {
        cell = [[cls alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([cls class])];
    }
    return cell;
}
- (__kindof UITableViewHeaderFooterView *)dequeueResuseHeaderFooterView:(Class)cls {
    if (!cls) cls = [UITableViewHeaderFooterView class];
    UITableViewHeaderFooterView *reuse = [self dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([cls class])];
    if (!reuse) {
        reuse = [[cls alloc]initWithReuseIdentifier:NSStringFromClass([cls class])];
    }
    return reuse;
}
- (UIView *)reuseViewWith:(HHPopSupplementaryStyle *)style {
    UITableViewHeaderFooterView *header = [self dequeueResuseHeaderFooterView:NULL];
    header.textLabel.text = style.title;
    header.textLabel.font = style.titleFont;
    header.textLabel.textColor = style.titleColor;
    header.textLabel.textAlignment = style.titleAligment;
    header.contentView.backgroundColor = style.bgColor;
    if (style.customView) {
        [header.contentView addSubview:style.customView];
        style.customView.centerY = style.height * 0.5;
    }
    return header;
}

@end


typedef void (^SelectionHandler)(NSInteger, HHPopItem *);
@interface HHPopItem ()
@property (nonatomic, copy)SelectionHandler handler;
@property (nonatomic, assign, readonly)CGFloat width;
@end

#pragma mark - HHPopSupplementaryStyle

@interface HHPopSupplementaryStyle ()
@end
@implementation HHPopSupplementaryStyle
+ (instancetype)defaultStyle {
    return [[self alloc]init];
}
- (instancetype)init {
    if (self = [super init]) {
        self.height = 45;
        self.titleColor = [UIColor blueColor];
        self.titleFont = [UIFont fontWithName:HHMediumFont size:18];
        self.bgColor = [UIColor groupTableViewBackgroundColor];
    }
    return self;
}
@end

#pragma mark - HHPopStyle
@interface HHPopStyle ()
@end
@implementation HHPopStyle
+ (instancetype)defaultStyle {
    return [[self alloc]init];
}
- (instancetype)init {
    if (self = [super init]) {
        self.rowHeight = 40;
        self.cornerRadius = 10;
        self.dimColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        self.arrowStyle = 0;
        self.arrowSize = (CGSize){15, 8};
        self.popAreaEdgeLimits = (UIEdgeInsets){20, 5, 5, 5};
        self.animationIn = 0.25;
        self.animationOut = 0.25;
        
        self.itemBgColor = [UIColor whiteColor];
        self.separatorColor = [UIColor groupTableViewBackgroundColor];
        self.separatorInset = (UIEdgeInsets){0, 10, 0, 10};
        self.itemImageContentMode = UIViewContentModeScaleAspectFill;
        self.itemTextFont = HHFont(16);
        self.itemTextColor = [UIColor blackColor];
        
        self.arrowDistanceFromTargetRectBorder = 3;
    }
    return self;
}

@end


@interface _HHPopCell : UITableViewCell
@property (nonatomic, strong)HHPopItem *item;
/// 是否应该绘制分割线
@property (nonatomic, assign, getter=shouldDrawSeperator)BOOL drawSeperator;
@end
@interface _HHOverlayView : UIView
@end
@interface _HHCoverView : UIView
- (void)setTouchHandler:(void (^)())touchHandler;
@end

#pragma mark - HHPopController

#define HHGlobalPop [HHPopController sharedPopController]
@interface HHPopController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)HHPopStyle *style;
@property (nonatomic, weak)UIView *sourceView;
@property (nonatomic, strong)NSArray<HHPopItem *> *popItems;
@property (nonatomic, copy)SelectionHandler handler;
@property (nonatomic, assign, getter=isPopVisible)BOOL popVisible;
@property (nonatomic, weak)_HHCoverView *contenView;
@property (nonatomic, strong)_HHOverlayView *overlayView;
@property (nonatomic, weak)UITableView *tableView;
/// 箭头方向
@property (nonatomic, assign, readonly)_HHArrowDirection arrowDirection;
/// 箭头的坐标
@property (nonatomic, assign, readonly)CGPoint arrowPoint;
/// 背景的frame
@property (nonatomic, assign, readonly)CGRect overlayViewFrame;
/// tableView的frame
@property (nonatomic, assign, readonly)CGRect tableViewFrame;
/// 根据数据 tableView的理论尺寸
@property (nonatomic, assign, readonly)CGSize idealSize;
/// 背景层的锚点
@property (nonatomic, assign)CGPoint anchorPoint;
/// 初始的形变
@property (nonatomic, assign)CGAffineTransform oriTransform;
@end
@implementation HHPopController

+ (instancetype)sharedPopController {
    static HHPopController *pop;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pop = [[[self class] alloc] init];
    });
    return pop;
}
+ (void)applyPopStyle:(void (^)(HHPopStyle *))maker {
    !maker ?: maker(HHGlobalPop.style);
}
+ (void)applyReturnPopStyle:(HHPopStyle *(^)(HHPopStyle *))maker {
    if (maker) {
        HHGlobalPop.style = maker(HHGlobalPop.style);
    }
}
+ (void)popSourceView:(UIView *)view popItems:(NSArray<HHPopItem *> *)items selectionHandler:(SelectionHandler)handler {
    [self popTargetRect:view.bounds soureceView:view popItems:items selectionHandler:handler];
}
+ (void)popTargetRect:(CGRect)rect soureceView:(UIView *)view popItems:(NSArray<HHPopItem *> *)items selectionHandler:(SelectionHandler)handler {
    HHGlobalPop.popItems = items;
    HHGlobalPop.sourceView = view;
    [HHGlobalPop initFramesWithTargetRect:rect];
    if (!HHRectIsVaild(HHGlobalPop.overlayViewFrame)) return;
    HHGlobalPop.handler = handler;
    [HHGlobalPop show];
}
+ (BOOL)isPopVisible {
    return HHGlobalPop.isPopVisible;
}

+ (void)dismiss {
    [HHGlobalPop dismiss];
}

- (void)show {
    [self tableView];
    [self.contenView addSubview:self.overlayView];
    
    self.overlayView.transform = self.oriTransform;
    [HHNotificationCenter() postNotificationName:HHPopControllerWillPopNotification object:self userInfo:@{}];
    [UIView animateWithDuration:self.style.animationIn delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.popVisible = YES;
        self.overlayView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [HHNotificationCenter() postNotificationName:HHPopControllerDidPopNotification object:self userInfo:@{}];
    }];
}
- (void)dismiss {
    [HHNotificationCenter() postNotificationName:HHPopControllerWillHidenNotification object:self userInfo:@{}];
    [UIView animateWithDuration:self.style.animationOut delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.popVisible = NO;
        self.overlayView.transform = self.oriTransform;
    } completion:^(BOOL finished) {
        [self free];
        [HHNotificationCenter() postNotificationName:HHPopControllerDidHidenNotification object:self userInfo:@{}];
    }];
}

/// 释放资源
- (void)free {
    [self.overlayView removeFromSuperview];
    [self.contenView removeFromSuperview];
    self.overlayView = nil;
    self.popItems = nil;
    self.style = nil;
}

#pragma mark 核心计算
- (void)initFramesWithTargetRect:(CGRect)targetRect {
    CGSize s = targetRect.size;
    CGPoint center = CGPointMake(s.width * 0.5, s.height * 0.5);
    UIView *sourceView = self.sourceView;
    
    HHPopStyle *style = self.style;
    UIView *window = HHKeyWindow();
    
    /// 1.判断弹框区域是否有效
    CGPoint cp = [sourceView convertPoint:center toView:window];
    CGSize arrowS = style.arrowSize;
    CGFloat arrowHalfW = arrowS.width * 0.5, radius = self.style.cornerRadius;
    UIEdgeInsets edge = style.popAreaEdgeLimits, delta;
    switch (style.arrowStyle) {
        case HHArrowStyleVerticalDefault: case HHArrowStyleUp: case HHArrowStyleDown:
            delta = (UIEdgeInsets){0, radius+arrowHalfW, 0, radius+arrowHalfW};
            break;
        case HHArrowStyleHorizontalDefault: case HHArrowStyleLeft: case HHArrowStyleRight:
            delta = (UIEdgeInsets){radius+arrowHalfW, 0, radius+arrowHalfW, 0};
    }
    UIEdgeInsets olyEdge = HHEdgeInsetsInset(edge, delta);
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect rect = HHRectReduceEdgeInsets(bounds, olyEdge);
    /// 直接不显示了
    if (!CGRectContainsPoint(rect, cp)) return;
    
    /// 2.计算frame
    
    /// 2.1 声明变量
    __block CGFloat arrowX, arrowY, arrowH = arrowS.height;// 箭头
    __block CGFloat overlayX = 0.0, overlayY = 0.0, overlayW, overlayH;// 背景层
    __block CGFloat tableX, tableY, tableW, tableH;// 表
    __block CGFloat limitH, limitW;/// 限制
    __block CGPoint anchorP;// 锚点
    __block CGFloat space = style.arrowDistanceFromTargetRectBorder;// 距离
    __block CGFloat screenH = HHScreenH(), screenW = HHScreenW();// 屏幕宽高
    __block CGFloat contentW = self.idealSize.width, contentH = self.idealSize.height;// 内容
    __block _HHArrowDirection dir;// 箭头方向
    CGFloat borderW = style.borderWidth;// 边框宽度
    switch (style.arrowStyle) {
        case HHArrowStyleVerticalDefault: case HHArrowStyleUp: case HHArrowStyleDown:
            /// 竖直
        {
            CGPoint topCenter = CGPointMake(s.width * 0.5, 0);
            CGPoint bottomCenter = CGPointMake(s.width * 0.5, s.height);
            /// 顶部中心点
            CGPoint tcp = [sourceView convertPoint:topCenter toView:window];
            /// 底部中心点 bottomCenterPoint
            CGPoint bcp = [sourceView convertPoint:bottomCenter toView:window];
            
            void (^upAction)() = ^{
                dir = Up;
                anchorP = (CGPoint){0.5, 0.0};
                arrowY = bcp.y + space;
                limitH = screenH - arrowY - edge.bottom;
                
                overlayY = arrowY;
                overlayH = MIN(limitH, contentH + arrowH + 2 * borderW);
                
                tableY = arrowH + borderW;
            };
            
            void (^downAction)() = ^{
                dir = Down;
                anchorP = (CGPoint){0.5, 1.0};
                arrowY = tcp.y - space;
                limitH = arrowY - edge.top;
                
                overlayH = MIN(limitH, contentH + arrowH + 2 * borderW);
                overlayY = arrowY - overlayH;
                
                tableY = borderW;
            };
            
            if (style.arrowStyle == HHArrowStyleUp) {
                upAction();
            } else if (style.arrowStyle == HHArrowStyleDown) {
                downAction();
            } else {
                if (cp.y < screenH * 0.5) {/// 箭头朝上 向下布局
                    upAction();
                } else {// 箭头朝下 向上布局
                    downAction();
                }
            }
            
            arrowX = cp.x;
            overlayW = contentW + 2 * borderW;
            tableW = overlayW - 2 * borderW;
            tableX = borderW;
            tableH = overlayH - arrowH - 2 * borderW;
            style.bounces = limitH < contentH + arrowH + 2 * borderW;
        }
            break;
        case HHArrowStyleHorizontalDefault: case HHArrowStyleLeft: case HHArrowStyleRight:
            /// 水平
        {
            CGPoint leftCenter = CGPointMake(0, s.height * 0.5);
            CGPoint rightCenter = CGPointMake(s.width, s.height * 0.5);
            /// 左边中心点
            CGPoint lcp = [sourceView convertPoint:leftCenter toView:window];
            /// 右边中心点
            CGPoint rcp = [sourceView convertPoint:rightCenter toView:window];
            
            void (^leftAction)() = ^{
                dir = Left;
                anchorP = (CGPoint){0, 0.5};
                arrowX = rcp.x + space;
                limitW = screenW - arrowX - edge.right;
                
                overlayX = arrowX;
                overlayW = MIN(limitW, contentW + arrowH + 2 * borderW);
                
                tableX = arrowH + borderW;
            };
            void (^rightAction)() = ^{
                dir = Right;
                anchorP = (CGPoint){1.0, 0.5};
                arrowX = lcp.x - space;
                limitW = arrowX - edge.left;
                
                overlayW = MIN(limitW, contentW + arrowH + 2 * borderW);
                overlayX = arrowX - overlayW;
                
                tableX = borderW;
            };
            
            if (style.arrowStyle == HHArrowStyleLeft) {
                leftAction();
            } else if (style.arrowStyle == HHArrowStyleRight) {
                rightAction();
            } else {
                if (cp.x < screenW * 0.5) {// 箭头朝左, 向右布局
                    leftAction();
                } else {// 箭头朝右, 向右布局
                    rightAction();
                }
            }
            
            arrowY = cp.y;
            limitH = screenH - edge.top - edge.bottom;
            overlayH = MIN(limitH, contentH + 2 * borderW);
            tableH = overlayH - 2 * borderW;
            tableY = borderW;
            tableW = overlayW - arrowH - 2 * borderW;
            style.bounces = limitH < contentH + 2 * borderW;
        }
            break;
    }
    _anchorPoint = anchorP;
    
    _arrowPoint = (CGPoint){arrowX, arrowY};
    _arrowDirection = dir;
    
    
    switch (dir) {
        case Up: case Down:
        {
            if (cp.x > screenW - overlayW * 0.5 - edge.right) {
                overlayX = screenW - overlayW - edge.right;
            } else if (cp.x < overlayW * 0.5 + edge.left) {
                overlayX = edge.left;
            } else {
                overlayX = arrowX - overlayW * 0.5;
            }
            self.oriTransform = CGAffineTransformMakeScale(1.0, 0.00001);
        }
            break;
        case Left: case Right:
        {
            if (cp.y > screenH - overlayH * 0.5 - edge.bottom) {
                overlayY = screenH - overlayH - edge.bottom;
            } else if (cp.y < overlayH * 0.5 + edge.top) {
                overlayY = edge.top;
            } else {
                overlayY = arrowY - overlayH * 0.5;
            }
            self.oriTransform = CGAffineTransformMakeScale(0.00001, 1.0);
        }
            break;
    }
    
    CGPoint overlayP = (CGPoint){overlayX - (0.5 - anchorP.x) * overlayW,
                                 overlayY - (0.5 - anchorP.y) * overlayH};
    
    
    _overlayViewFrame = (CGRect){overlayP, overlayW, overlayH};
    _tableViewFrame = (CGRect){tableX, tableY, tableW, tableH};
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.popItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _HHPopCell *cell = [tableView dequeueReusableCell:[_HHPopCell class]];
    cell.item = self.popItems[indexPath.row];
    cell.drawSeperator = indexPath.row != self.popItems.count - 1;
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.style.header) return nil;
    HHPopStyle *style = self.style;
    return [tableView reuseViewWith:style.header];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (!self.style.footer) return nil;
    HHPopStyle *style = self.style;
    return [tableView reuseViewWith:style.footer];
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger idx = indexPath.row;
    HHPopItem *item = self.popItems[idx];
    !item.handler ?: item.handler(idx, item);
    !self.handler ?: self.handler(idx, item);
    [self dismiss];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.style.header ? self.style.header.height : 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.style.footer ? self.style.footer.height : 0;
}


#pragma mark Getter And Setter
- (void)setPopItems:(NSArray<HHPopItem *> *)popItems {
    _popItems = popItems;
    HHPopStyle *style = self.style;
    __block CGFloat maxLength = 0;
    for (NSInteger i = 0; i < popItems.count; i++) {
        CGFloat width = popItems[i].width;
        maxLength = maxLength < width ? width : maxLength;
    }
    CGFloat width = style.popWidth ? style.popWidth : MIN(maxLength, HHScreenW() * 0.8);
    CGFloat height = popItems.count * style.rowHeight + (style.header ? style.header.height : 0) + (style.footer ? style.footer.height : 0);
    _idealSize = (CGSize){width, height};
}
- (HHPopStyle *)style {
    if (!_style) {
        _style = [[HHPopStyle alloc] init];
    }
    return _style;
}
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:self.tableViewFrame style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        if (self.style.cornerRadius) {
            [tableView masklayerWithRadio:self.style.cornerRadius];
        }
        tableView.bounces = self.style.bounces;
        tableView.rowHeight = self.style.rowHeight;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.dataSource = self;
        tableView.delegate = self;
        _tableView = tableView;
        [self.overlayView addSubview:tableView];
    }
    return _tableView;
}
- (_HHCoverView *)contenView {
    if (!_contenView) {
        _HHCoverView *content = [[_HHCoverView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        content.backgroundColor = self.style.dimColor;
        _contenView = content;
        @weakify(self);
        [content setTouchHandler:^{
            @strongify(self);
            [self dismiss];
        }];
        [HHKeyWindow() addSubview:content];
    }
    return _contenView;
}
- (_HHOverlayView *)overlayView {
    if (!_overlayView) {
        _HHOverlayView *overlay = [[_HHOverlayView alloc] initWithFrame:self.overlayViewFrame];
        _overlayView = overlay;
    }
    return _overlayView;;
}
@end

#pragma mark - HHPopItem
@implementation HHPopItem
+ (instancetype)itemWithTitle:(NSString *)title {
    return [self itemWithImage:nil title:title];
}
+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title {
    HHPopItem *item = [[self alloc]init];
    item.image = image;
    item.title = title;
    return item;
}
- (CGFloat)width {
    HHPopStyle *style = HHGlobalPop.style;
    CGFloat titleW = [self.title widthForFont:style.itemTextFont];
    CGFloat imageW = _image ? _image.size.width + 45 : 30;
    return imageW + titleW;
}
@end

#pragma mark - _HHPopCell
@interface _HHPopCell ()
@property (nonatomic, weak)UIView *seperatorView;
@end
@implementation _HHPopCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    HHPopStyle *style = HHGlobalPop.style;
    self.backgroundColor = style.itemBgColor;
    
    self.imageView.contentMode = style.itemImageContentMode;
    self.textLabel.font = style.itemTextFont;
    self.textLabel.textAlignment = style.itemTextAligment;
    self.textLabel.textColor = style.itemTextColor;
}
- (void)setItem:(HHPopItem *)item {
    self.imageView.image = item.image;
    self.textLabel.text = item.title;
}
- (void)setDrawSeperator:(BOOL)drawSeperator {
    _drawSeperator = drawSeperator;
    if (!drawSeperator) return;
    [self.seperatorView removeFromSuperview];
    UIView *seperator = [[UIView alloc]initWithFrame:CGRectZero];
    seperator.backgroundColor = HHGlobalPop.style.separatorColor;
    _seperatorView = seperator;
    [self addSubview:seperator];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.shouldDrawSeperator) return;
    self.textLabel.height -= 2;
    self.textLabel.top += 1;
    UIEdgeInsets inset = HHGlobalPop.style.separatorInset;
    self.seperatorView.left = inset.left;
    self.seperatorView.width = self.width - inset.left - inset.right;
    self.seperatorView.height = 1;
    self.seperatorView.bottom = self.height;
}
@end


#pragma mark - _HHOverlayView
@interface _HHOverlayView ()
@end

@implementation _HHOverlayView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.anchorPoint = HHGlobalPop.anchorPoint;
        [self drawArrow];
    }
    return self;
}
#pragma mark 绘制箭头

- (void)drawArrow {
    HHPopStyle *style = HHGlobalPop.style;
    HHPopSupplementaryStyle *header = style.header;
    HHPopSupplementaryStyle *footer = style.footer;
    
    CGFloat headerH = header ? header.height : 0;
    CGFloat footerH = footer ? footer.height : 0;
    UIColor *headerBgColor = header ? header.bgColor : style.itemBgColor;
    UIColor *footerBgColor = footer ? footer.bgColor : style.itemBgColor;
    
    CGPoint arrowP = [HHKeyWindow() convertPoint:HHGlobalPop.arrowPoint toView:self];
    CGFloat arrowX = arrowP.x;
    CGFloat arrowY = arrowP.y;
    CGFloat arrowW = style.arrowSize.width;
    CGFloat arrowH = style.arrowSize.height;
    
    CGFloat overlayW = self.width;
    CGFloat overlayH = self.height;
    CGFloat overlayX = 0;
    CGFloat overlayY = 0;
    CGFloat radius = style.cornerRadius;
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    UIColor *bgColor;
    
    _HHArrowDirection dir = HHGlobalPop.arrowDirection;
    
    CGFloat top, left, bottom, right;
    
    if (dir == Up) {
        [arrowPath moveToPoint:(CGPoint){arrowX, 0}];
        
        top = arrowH + radius; right = overlayW - radius;
        bottom = overlayH - radius; left = radius;
        
        [arrowPath addLineToPoint:(CGPoint){arrowX + arrowW * 0.5, arrowH}];
        
        [arrowPath addLineToPoint:(CGPoint){right, arrowH}];
        [arrowPath addArcWithCenter:(CGPoint){right, top} radius:radius startAngle:3 * M_PI_2 endAngle:0 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){overlayW, bottom}];
        [arrowPath addArcWithCenter:(CGPoint){right, bottom} radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){left, overlayH}];
        [arrowPath addArcWithCenter:(CGPoint){left, bottom} radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){overlayX, top}];
        [arrowPath addArcWithCenter:(CGPoint){left, top} radius:radius startAngle:M_PI endAngle:3 * M_PI_2 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){arrowX - arrowW * 0.5, arrowH}];
        
        bgColor = headerBgColor;
        
    } else if (dir == Down) {
        [arrowPath moveToPoint:(CGPoint){arrowX, overlayH}];
        
        top = radius; left = radius; bottom = overlayH - arrowH - radius;
        right = overlayW - radius;
        
        CGFloat bottomLine = overlayH - arrowH;
        [arrowPath addLineToPoint:(CGPoint){arrowX - arrowW * 0.5, bottomLine}];
        [arrowPath addArcWithCenter:(CGPoint){left, bottom} radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){overlayX, top}];
        [arrowPath addArcWithCenter:(CGPoint){left, top} radius:radius startAngle:M_PI endAngle:3 * M_PI_2 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){right, overlayY}];
        [arrowPath addArcWithCenter:(CGPoint){right, top} radius:radius startAngle:3 * M_PI_2 endAngle:0 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){overlayW, bottom}];
        [arrowPath addArcWithCenter:(CGPoint){right, bottom} radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){arrowX + arrowW * 0.5, bottomLine}];
        
        bgColor = footerBgColor;
        
    } else if (dir == Left) {
        [arrowPath moveToPoint:(CGPoint){0, arrowY}];
        
        top = radius, left = radius + arrowH; bottom = overlayH - radius;
        right = overlayW - radius;
        
        [arrowPath addLineToPoint:(CGPoint){arrowH, arrowY - arrowW * 0.5}];
        [arrowPath addLineToPoint:(CGPoint){arrowH, top}];
        [arrowPath addArcWithCenter:(CGPoint){left, top} radius:radius startAngle:M_PI endAngle:3 * M_PI_2 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){right, overlayY}];
        [arrowPath addArcWithCenter:(CGPoint){right, top} radius:radius startAngle:3 * M_PI_2 endAngle:0 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){overlayW, bottom}];
        [arrowPath addArcWithCenter:(CGPoint){right, bottom} radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){left, overlayH}];
        [arrowPath addArcWithCenter:(CGPoint){left, bottom} radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){arrowH, arrowY + arrowW * 0.5}];
        
        CGFloat footerStartY = HHGlobalPop.tableViewFrame.size.height - footerH;
        if (arrowY < headerH) {
            bgColor = headerBgColor;
        } else if (arrowY > footerStartY) {
            bgColor = footerBgColor;
        } else {
            bgColor = style.itemBgColor;
        }
        
    } else if (dir == Right) {
        [arrowPath moveToPoint:(CGPoint){overlayW, arrowY}];
        
        top = radius; left = radius; bottom = overlayH - radius;
        right = overlayW - radius - arrowH;
        
        CGFloat rightLine = overlayW - arrowH;
        
        [arrowPath addLineToPoint:(CGPoint){rightLine, arrowY + arrowW * 0.5}];
        [arrowPath addLineToPoint:(CGPoint){rightLine, bottom}];
        [arrowPath addArcWithCenter:(CGPoint){right, bottom} radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){left, overlayH}];
        [arrowPath addArcWithCenter:(CGPoint){left, bottom} radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){overlayX, top}];
        [arrowPath addArcWithCenter:(CGPoint){left, top} radius:radius startAngle:M_PI endAngle:3 * M_PI_2 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){right, overlayY}];
        [arrowPath addArcWithCenter:(CGPoint){right, top} radius:radius startAngle:3 * M_PI_2 endAngle:0 clockwise:YES];
        [arrowPath addLineToPoint:(CGPoint){rightLine, arrowY - arrowW * 0.5}];
        
        CGFloat footerStartY = HHGlobalPop.tableViewFrame.size.height - footerH;
        if (arrowY < headerH) {
            bgColor = headerBgColor;
        } else if (arrowY > footerStartY) {
            bgColor = footerBgColor;
        } else {
            bgColor = style.itemBgColor;
        }
        
    }
    
    [arrowPath closePath];
    
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.path = arrowPath.CGPath;
    shape.lineWidth = style.borderWidth;
    shape.strokeColor = style.borderColor.CGColor;
    shape.fillColor = bgColor.CGColor;
    [self.layer addSublayer:shape];
    
}
@end

@interface _HHCoverView ()
@property (nonatomic, copy)void (^touchHandler)();
@end
@implementation _HHCoverView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    !self.touchHandler ?: self.touchHandler();
}

@end
