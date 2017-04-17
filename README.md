# HHPopController
更好用的仿微信、QQ弹框控件


Demo Project
==============
See `HHPopControllerDemo/HHPopControllerDemo.xcodeproj`

<img src="https://github.com/theSkyOfJune/HHPopController/blob/master/gif/Untitled.gif" width="375"><br/>


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
This library requires `iOS 6.0+` and `Xcode 7.0+`.


许可证
==============
YYModel 使用 MIT 许可证，详情见 LICENSE 文件。
