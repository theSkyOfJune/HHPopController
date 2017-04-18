简介
==============
更好用的仿微信、QQ弹框控件。<br/>


Demo Project
==============
查看并运行 `HHPopControllerDemo/HHPopControllerDemo.xcodeproj`

<img src="https://github.com/theSkyOfJune/HHPopController/blob/master/gif/Untitled.gif" width="375"><br/>


特性
==============
- **无侵入性**
- **轻量**
- **易用易扩展**
- **可定制性高**


使用方法
==============

    HHPopItem *item1 = [HHPopItem itemWithImage:[UIImage imageNamed:@"ic_addvoucher_qrcode"] title:@"创建群聊"];
    HHPopItem *item2 = [HHPopItem itemWithImage:[UIImage imageNamed:@"ic_addvoucher_cinema"] title:@"加好友/群"];
    HHPopItem *item3 = [HHPopItem itemWithImage:[UIImage imageNamed:@"ic_addvoucher_input"] title:@"面对面快传"];
    [HHPopController applyPopStyle:^(HHPopStyle *style) {

        style.borderColor = [UIColor cyanColor];
        style.borderWidth = 1.0f;
        style.itemTextColor = [UIColor whiteColor];
        style.dimColor = [UIColor colorWithWhite:0.1 alpha:0.3];
        style.itemBgColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        ...
    }];
    [HHPopController popSourceView:btn popItems:@[item1, item2, item3] selectionHandler:^(NSInteger idx, HHPopItem *item) {
        NSLog(@"%@", item.title);
    }];


关键类定义
==============

###可定制样式模型HHPopStyle

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

可以通过header和footer属性定制头部视图和尾部视图, 如果不需要箭头, 设置arrowSize为CGSizeZero即可


###追加视图样式定义

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

如果通过customView属性自定义视图, 内部已做好上下居中约束, 您只需在创建自定义视图时做好水平约束即可

Example:

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"清除历史记录" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:HHRegularFont size:14];
    [btn addTarget:self action:@selector(clearHistoryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    btn.right = self.width - 10;

    HHPopSupplementaryStyle *footer = [HHPopSupplementaryStyle defaultStyle];
    footer.customView = btn;
    footer.height = 30;
    style.footer = footer;


###弹窗控制器HHPopController

    @interface HHPopController : NSObject

    - (instancetype)init __attribute__((unavailable("单例类，请使用+ (instancetype)sharedPopController")));
    + (instancetype)new __attribute__((unavailable("单例类，请使用+ (instancetype)sharedPopController")));

    + (instancetype)sharedPopController;

    + (void)applyReturnedPopStyle:(HHPopStyle *(^)(HHPopStyle *style))maker;

    + (void)applyPopStyle:(void (^)(HHPopStyle *style))maker;

    + (void)popSourceView:(UIView *)view popItems:(NSArray<HHPopItem *> *)items selectionHandler:(void (^)(NSInteger idx, HHPopItem *item))handler;

    + (void)popTargetRect:(CGRect)rect soureceView:(UIView *)view popItems:(NSArray<HHPopItem *> *)items selectionHandler:(void (^)(NSInteger idx, HHPopItem *item))handler;

    + (BOOL)isPopVisible;

    + (void)dismiss;

    @end

相信您已经知道怎么使用了, 希望在开发中能帮助到您, 欢迎isssues me, 乐意为您解答出现的相关问题! 


安装
==============

### CocoaPods

1. 在 Podfile 中添加 `pod 'HHPopController'`。
2. 执行 `pod install` 或 `pod update`。
3. 导入 \<HHPopController/HHPopController.h\>。


### 手动安装

1. 下载 HHPopController 文件夹内的所有内容。
2. 将 HHPopController 内的源文件添加(拖放)到你的工程。
3. 导入 `HHPopController.h`。


系统要求
==============
该项目最低支持 `iOS 6.0` 和 `Xcode 7.0`。


许可证
==============
HHPopController 使用 MIT 许可证，详情见 LICENSE 文件。
