# Custom广告适配器架构重构

## 概述

本次重构将Custom广告适配器的架构进行了重大改进，使其更加符合面向对象的设计原则和继承关系。

## 重构前的问题

1. **继承关系不合理**：所有Custom适配器都继承自通用的`CustomAdAdapter`，而不是对应类型的适配器
2. **代码重复**：每个Custom适配器都需要实现相同的广告加载、展示逻辑
3. **职责不清**：`CustomAdAdapter`既作为基类又作为通用工具类使用

## 重构后的架构

### 1. CustomAdHelper - 通用工具类

将原来的`CustomAdAdapter`重构为`CustomAdHelper`静态工具类，提供通用的Custom广告处理功能：

```swift
public class CustomAdHelper {
    // 通用加载方法
    internal static func loadCustomAd(posid: String, adType: AdType) async throws -> CustomAd
    
    // 通用展示上报
    internal static func reportAdDisplay(_ ad: CustomAd)
    
    // 通用点击处理
    internal static func handleAdClick(_ ad: CustomAd)
    
    // 通用广告视图创建
    internal static func createAdView(ad: CustomAd, layoutId: String, setupView: @escaping (UIView, CustomAd) -> Void) -> UIView?
    
    // 通用ECPM获取
    internal static func getECPM(_ ad: CustomAd) -> Double
}
```

### 2. Custom适配器继承关系

现在每个Custom适配器都继承自对应类型的适配器：

```swift
// 横幅广告
public class CustomBannerAdapter: BannerAdAdapter

// 插屏广告  
public class CustomInterstitialAdapter: InterstitialAdAdapter

// 激励视频广告
public class CustomRewardVideoAdapter: RewardVideoAdAdapter

// 原生广告
public class CustomNativeAdapter: NativeAdAdapter

// 开屏广告
public class CustomSplashAdapter: SplashAdAdapter
```

### 3. 适配器职责分工

#### 父类适配器（BannerAdAdapter等）
- 负责对应广告类型的通用逻辑
- 提供展示、交互、生命周期管理
- 处理可见性检测、自动刷新等特性

#### Custom适配器
- 继承父类的所有功能
- 使用`CustomAdHelper`处理Custom广告特有的逻辑
- 专注于Custom广告数据的处理和展示

#### CustomAdHelper
- 提供Custom广告的通用工具方法
- 处理Custom广告的加载、上报、点击等逻辑
- 支持不同类型的Custom广告（H5、Deeplink、下载等）

## 重构优势

### 1. 继承关系合理
- 每个Custom适配器都继承自对应类型的适配器
- 充分利用父类的功能，避免重复实现
- 符合面向对象的设计原则

### 2. 代码复用
- `CustomAdHelper`提供通用的Custom广告处理功能
- 各个Custom适配器可以复用相同的逻辑
- 减少代码重复，提高维护性

### 3. 职责清晰
- 父类适配器：负责广告类型的通用逻辑
- Custom适配器：负责Custom广告的特有逻辑
- CustomAdHelper：负责Custom广告的通用工具方法

### 4. 扩展性好
- 新增Custom广告类型时，只需要继承对应的适配器
- 复用`CustomAdHelper`的通用功能
- 保持架构的一致性和可维护性

## 使用示例

### 创建Custom横幅广告适配器

```swift
let customBannerAdapter = CustomBannerAdapter()
customBannerAdapter.setListener(bannerListener)

// 加载广告
try await customBannerAdapter.loadAsync(posid: "custom_banner_001")

// 展示广告
try await customBannerAdapter.showAsync()
```

### 创建Custom激励视频广告适配器

```swift
let customRewardVideoAdapter = CustomRewardVideoAdapter()
customRewardVideoAdapter.setListener(rewardVideoListener)

// 加载广告
try await customRewardVideoAdapter.loadAsync(posid: "custom_reward_001")

// 展示广告
try await customRewardVideoAdapter.showAsync()
```

## 技术细节

### 1. 访问权限调整
为了支持继承，调整了父类适配器中关键属性和方法的访问权限：

```swift
// 从private改为internal
internal var bannerView: UIView?
internal var interstitialView: UIView?
internal var nativeAdView: UIView?
internal var splashView: UIView?
internal var videoContainer: UIView?

internal func createBannerView()
internal func showBannerAd()
internal func startVisibilityTracking()
// ... 其他关键方法
```

### 2. Custom广告数据处理
- 使用`CustomAdHelper.loadCustomAd()`加载Custom广告数据
- 使用`CustomAdHelper.createAdView()`创建广告视图
- 使用`CustomAdHelper.handleAdClick()`处理点击事件
- 使用`CustomAdHelper.getECPM()`获取ECPM

### 3. 错误处理
- 统一的错误处理机制
- 详细的日志记录
- 优雅的异常处理

## 访问权限修复详情

在重构过程中，发现并修复了多个访问权限问题，确保子类可以正确访问父类的属性和方法：

### 修复的属性访问权限

#### InterstitialAdAdapter
```swift
// 修复前
private var isShowing = false
private var showStartTime: Date?
private var showDuration: TimeInterval = 0

// 修复后
internal var isShowing = false
internal var showStartTime: Date?
internal var showDuration: TimeInterval = 0
```

#### SplashAdAdapter
```swift
// 修复前
private var isShowing = false
private var showStartTime: Date?
private var showDuration: TimeInterval = 0
private var countdownTimer: Timer?
private var countdownLabel: UILabel?
private var skipButton: UIButton?
private var logoImageView: UIImageView?
private var adImageView: UIImageView?

// 修复后
internal var isShowing = false
internal var showStartTime: Date?
internal var showDuration: TimeInterval = 0
internal var countdownTimer: Timer?
internal var countdownLabel: UILabel?
internal var skipButton: UIButton?
internal var logoImageView: UIImageView?
internal var adImageView: UIImageView?
```

#### RewardVideoAdAdapter
```swift
// 修复前
private var isPlaying = false
private var isCompleted = false
private var playStartTime: Date?
private var playDuration: TimeInterval = 0
private var skipButton: UIButton?
private var progressView: UIProgressView?
private var timeLabel: UILabel?

// 修复后
internal var isPlaying = false
internal var isCompleted = false
internal var playStartTime: Date?
internal var playDuration: TimeInterval = 0
internal var skipButton: UIButton?
internal var progressView: UIProgressView?
internal var timeLabel: UILabel?
```

#### NativeAdAdapter
```swift
// 修复前
private var isVisible = false

// 修复后
internal var isVisible = false
```

### 修复的方法访问权限

#### 创建和展示方法
```swift
// 所有适配器中的关键方法都从private改为internal
internal func createBannerView()
internal func createInterstitialView()
internal func createNativeAdView()
internal func createSplashView()
internal func createVideoPlayer()

internal func showBannerAd()
internal func showInterstitialAd()
internal func showNativeAd()
internal func showSplashAd()
internal func showRewardVideoAd()
```

#### 生命周期管理方法
```swift
internal func startVisibilityTracking()
internal func setupImpressionTracking()
internal func startCountdown()
internal func startVideoPlayback()
internal func startSkipCountdown()
internal func updateCountdown()
```

### 修复结果

- ✅ 编译成功，无错误
- ✅ 所有Custom适配器可以正确访问父类属性和方法
- ✅ 继承关系正常工作
- ✅ 代码功能完整

## 方法冲突和类型错误修复

在重构过程中，还发现并修复了其他类型的问题：

### 1. Objective-C选择器冲突

#### CustomNativeAdapter
```swift
// 问题：actionButtonTapped方法与父类NativeAdAdapter中的方法冲突
@objc private func actionButtonTapped() // 冲突

// 解决：重命名方法避免冲突
@objc private func customActionButtonTapped() // 修复后
```

**修复详情**：
- 将`actionButtonTapped`重命名为`customActionButtonTapped`
- 更新所有按钮的target action引用
- 避免与父类方法的Objective-C选择器冲突

#### CustomSplashAdapter
```swift
// 问题：skipButtonTapped方法与父类SplashAdAdapter中的方法冲突
skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside) // 冲突

// 解决：重命名方法避免冲突
skipButton.addTarget(self, action: #selector(customSkipButtonTapped), for: .touchUpInside) // 修复后
```

**修复详情**：
- 将`skipButtonTapped`重命名为`customSkipButtonTapped`
- 添加新的`@objc`方法处理跳过按钮点击
- 避免与父类方法的访问权限冲突

### 2. 类型错误修复

#### CustomRewardVideoAdapter
```swift
// 问题：AdType枚举中没有rewardVideo成员
customAd = try await CustomAdHelper.loadCustomAd(posid: posid, adType: .rewardVideo) // 错误

// 解决：使用正确的枚举值
customAd = try await CustomAdHelper.loadCustomAd(posid: posid, adType: .rewarded) // 修复后
```

**修复详情**：
- 将`.rewardVideo`改为`.rewarded`
- 使用`AdType`枚举中实际存在的值

#### CustomAdAdapter
```swift
// 问题1：尝试修改结构体参数（值类型）
ad.isClicked = true // 错误：不能修改let常量

// 解决：移除对参数的修改
// 注意：由于CustomAd是结构体（值类型），我们不能直接修改传入的参数
// 这里我们只处理点击逻辑，不修改ad对象

// 问题2：不必要的nil合并操作符
return Double(ad.price ?? 0) // 警告：ad.price是Int类型，不是可选类型

// 解决：移除多余的nil合并操作符
return Double(ad.price) // 修复后
```

**修复详情**：
- 移除对结构体参数的修改操作
- 修复类型不匹配的警告
- 添加注释说明结构体值类型的特性

**进一步优化**：
由于`CustomAd`是结构体（值类型），我们修改了`handleAdClick`方法的实现：

```swift
// 修改前：无法修改结构体参数
internal static func handleAdClick(_ ad: CustomAd) {
    ad.isClicked = true // 错误：不能修改结构体参数
    // ... 其他逻辑
}

// 修改后：返回修改后的副本
internal static func handleAdClick(_ ad: CustomAd) -> CustomAd {
    var modifiedAd = ad
    modifiedAd.isClicked = true
    
    Task {
        await adClient.reportAdClick(modifiedAd)
    }
    handleCustomAdClick(modifiedAd)
    
    return modifiedAd
}
```

**调用方式更新**：
所有调用`handleAdClick`的地方都需要使用返回值来更新本地的`customAd`属性：

```swift
// 修改前
CustomAdHelper.handleAdClick(ad)

// 修改后
customAd = CustomAdHelper.handleAdClick(ad)
```

这样既保持了结构体的不可变性，又实现了状态更新的需求。

### 3. 修复总结

通过这次修复，解决了以下问题：

1. **Objective-C选择器冲突**：重命名冲突的方法，避免与父类方法的选择器冲突
2. **访问权限问题**：确保子类可以正确访问父类的属性和方法
3. **类型错误**：使用正确的枚举值和类型
4. **结构体值类型**：正确处理结构体参数，避免修改尝试

### 4. 最终编译结果

- ✅ 编译成功，无错误
- ✅ 所有Custom适配器可以正确访问父类属性和方法
- ✅ 继承关系正常工作
- ✅ 方法冲突已解决
- ✅ 类型错误已修复
- ✅ 代码功能完整

## 4. WebView集成

### 4.1 功能概述
Custom广告点击时现在使用内部WebView打开网页，而不是使用系统浏览器，提供更好的用户体验和广告追踪能力。

### 4.2 技术实现

#### 4.2.1 CustomAdHelper修改
```swift
// 修改前：无法获取视图控制器上下文
internal static func handleAdClick(_ ad: CustomAd) -> CustomAd

// 修改后：支持传递视图控制器
internal static func handleAdClick(_ ad: CustomAd, from viewController: UIViewController? = nil) -> CustomAd
```

#### 4.2.2 H5处理逻辑
```swift
private static func handleH5(_ ad: CustomAd, from viewController: UIViewController?) {
    guard !ad.ldp.isEmpty else { return }
    
    // 如果有视图控制器，使用内部WebView打开
    if let viewController = viewController {
        WebViewManager.shared.openWebView(
            url: ad.ldp,
            title: ad.title,
            from: viewController
        )
    } else {
        // 如果没有视图控制器，回退到系统浏览器
        if let url = URL(string: ad.ldp) {
            UIApplication.shared.open(url)
        }
    }
}
```

### 4.3 适配器修改

#### 4.3.1 添加getCurrentViewController方法
每个Custom适配器都添加了获取当前视图控制器的方法：

```swift
/// 获取当前视图控制器
private func getCurrentViewController() -> UIViewController? {
    // 通过广告视图的window来获取当前视图控制器
    if let window = bannerView?.window { // 或其他视图
        return window.rootViewController?.topMostViewController()
    }
    return nil
}
```

#### 4.3.2 调用方式更新
```swift
// 修改前
customAd = CustomAdHelper.handleAdClick(ad)

// 修改后
customAd = CustomAdHelper.handleAdClick(ad, from: getCurrentViewController())
```

### 4.4 UIViewController扩展
添加了`topMostViewController`扩展方法来获取最顶层的视图控制器：

```swift
extension UIViewController {
    /// 获取最顶层的视图控制器
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}
```

### 4.5 优势
1. **用户体验**：用户无需离开应用即可查看广告详情
2. **广告追踪**：更好的点击和展示追踪能力
3. **品牌一致性**：保持应用内的视觉风格
4. **加载速度**：内部WebView通常比系统浏览器启动更快
5. **回退机制**：当无法获取视图控制器时，自动回退到系统浏览器

### 4.6 注意事项
1. **内存管理**：WebView会占用一定内存，需要及时释放
2. **网络权限**：确保应用有网络访问权限
3. **视图控制器获取**：依赖广告视图的window属性，确保广告已正确添加到视图层次结构中
4. **回退机制**：当无法获取视图控制器时，会自动使用系统浏览器作为备选方案

## 5. 线程安全性修复

### 5.1 问题描述
在非主线程上修改UI视图的属性会导致崩溃，错误信息：
```
Modifying properties of a view's layer off the main thread is not allowed: view <UILabel: 0x105318360> with no associated or ancestor view controller
```

### 5.2 问题原因
Custom适配器的`loadAsync`方法可能在任意线程上执行，但UI相关的代码（如创建UILabel、设置layer属性等）必须在主线程上执行。

### 5.3 解决方案
使用`MainActor.run`确保所有UI相关的代码都在主线程上执行：

```swift
public override func loadAsync(posid: String) async throws {
    // 使用CustomAdHelper加载广告
    do {
        customAd = try await CustomAdHelper.loadCustomAd(posid: posid, adType: .native)
        
        // 确保在主线程上创建UI
        await MainActor.run {
            createCustomNativeAdView()
        }
        
        ALog.d("CustomNativeAdapter", "Custom原生广告加载完成: \(posid)")
    } catch {
        ALog.e("CustomNativeAdapter", "Custom原生广告加载失败: \(error.localizedDescription)")
        throw error
    }
}
```

### 5.4 修复的适配器
- ✅ `CustomBannerAdapter`：横幅广告
- ✅ `CustomInterstitialAdapter`：插屏广告
- ✅ `CustomNativeAdapter`：原生广告
- ✅ `CustomSplashAdapter`：开屏广告
- ✅ `CustomRewardVideoAdapter`：激励视频广告（无需修复，无UI创建）

### 5.5 技术要点
1. **MainActor.run**：确保代码块在主线程上执行
2. **await关键字**：等待主线程执行完成
3. **UI线程安全**：所有UI相关的操作都必须在主线程上执行
4. **异步协调**：保持异步加载的性能优势，同时确保UI线程安全

### 5.6 最佳实践
1. **UI操作隔离**：将UI创建和配置代码封装在单独的方法中
2. **线程检查**：在UI相关方法开始时检查是否在主线程
3. **错误处理**：提供清晰的错误信息，便于调试
4. **性能考虑**：只在必要时切换到主线程，避免不必要的线程切换

## 6. 原生广告UI优化

### 6.1 概述
原生广告的UI设计需要更加注重用户体验和品牌一致性。

### 6.2 布局设计

#### 6.2.1 基础布局
```swift
// 基础布局层次
┌─────────────────────────────────────┐
│                                     │
│          广告主大图                  │
│        (75% 高度)                   │
│                                     │
├─────────────────────────────────────┤
│ [广告] 标题文字              [X]    │
│ (60px 高度)                         │
└─────────────────────────────────────┘
```

#### 6.2.2 基础约束
```swift
// 基础约束
- 广告主大图：占据顶部75%空间，圆角16pt
- 底部信息行：固定60px高度
- 广告标识：左侧，40x24，橙色背景
- 标题：中间，16pt粗体，单行显示
- 关闭按钮：右侧，32x32，圆形X图标
```

#### 6.2.3 新布局设计（最新优化）
- **大图展示**：广告主图片占据视图75%的高度，提供强烈的视觉冲击
- **底部信息行**：图片下方60px高度的信息行，包含广告标识、标题和关闭按钮
- **关闭功能**：右侧X按钮，点击可关闭广告
- **简化交互**：移除整个视图的点击事件，专注于关闭功能

### 6.3 技术实现

#### 6.3.1 图片加载
```swift
/// 异步加载图片
private func loadImage(from urlString: String, into imageView: UIImageView) {
    guard let url = URL(string: urlString) else { return }
    
    // 创建URLSession任务
    let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        DispatchQueue.main.async {
            if let data = data, let image = UIImage(data: data) {
                imageView.image = image
                imageView.backgroundColor = .clear
            } else {
                // 加载失败时显示默认图标
                self?.setDefaultImage(for: imageView)
            }
        }
    }
    task.resume()
}
```

#### 6.3.2 新布局结构
```swift
// 新布局层次（大图 + 底部信息行）
┌─────────────────────────────────────┐
│                                     │
│          广告主大图                  │
│        (75% 高度)                   │
│                                     │
├─────────────────────────────────────┤
│ [广告] 标题文字              [X]    │
│ (60px 高度)                         │
└─────────────────────────────────────┘

// 布局约束
- 广告主大图：占据顶部75%空间，圆角16pt
- 底部信息行：固定60px高度
- 广告标识：左侧，40x24，橙色背景
- 标题：中间，16pt粗体，单行显示
- 关闭按钮：右侧，32x32，圆形X图标
```

#### 6.3.3 关闭按钮实现
```swift
@objc private func closeButtonTapped() {
    ALog.d("CustomNativeAdapter", "Custom原生广告关闭按钮被点击")
    
    // 通知监听器广告被关闭
    notifyAdClosed()
    
    // 清理广告视图
    cleanup()
}
```

### 6.4 视觉元素

#### 6.4.1 颜色方案
- **主色调**：系统蓝色（原行动按钮，已移除）
- **辅助色**：系统橙色（广告标识）
- **背景色**：系统背景色
- **文字色**：系统标签色
- **关闭按钮**：系统灰色，圆形设计

#### 6.4.2 字体设计
- **标题**：16pt 粗体，单行显示
- **广告标识**：12pt 粗体
- **移除元素**：描述文字、来源信息、行动按钮

#### 6.4.3 尺寸规格
- **卡片圆角**：16pt
- **大图圆角**：16pt
- **广告标识圆角**：12pt
- **关闭按钮圆角**：16pt
- **底部信息行高度**：60px
- **大图高度比例**：75%

### 6.5 交互优化

#### 6.5.1 移除功能
- **整体点击**：移除整个视图的点击手势
- **行动按钮**：移除"立即查看"按钮
- **复杂交互**：简化用户交互流程

#### 6.5.2 新增功能
- **关闭按钮**：右侧X按钮，点击关闭广告
- **专注体验**：用户可以选择关闭不感兴趣的广告
- **清晰反馈**：关闭操作有明确的视觉反馈

### 6.6 用户体验提升

1. **视觉冲击**：大图展示提供强烈的视觉吸引力
2. **信息简洁**：底部信息行只显示必要信息
3. **操作明确**：关闭按钮功能清晰，易于理解
4. **布局清晰**：75%图片 + 25%信息的黄金比例
5. **响应迅速**：关闭操作响应快速，用户体验流畅

### 6.7 性能优化

1. **异步加载**：图片异步加载，不阻塞UI
2. **内存管理**：使用weak引用避免循环引用
3. **视图复用**：底部信息行容器复用
4. **约束优化**：使用multiplier实现比例布局

### 6.8 扩展性

1. **模块化设计**：图片加载和关闭逻辑独立
2. **配置化**：支持自定义图片比例、信息行高度
3. **主题支持**：可适配不同的应用主题
4. **国际化**：支持多语言文本显示

## 总结

通过这次重构，Custom广告适配器的架构变得更加合理和可维护：

1. **继承关系正确**：每个Custom适配器都继承自对应类型的适配器
2. **代码复用充分**：通过`CustomAdHelper`复用通用逻辑
3. **职责分工明确**：父类、子类、工具类各司其职
4. **扩展性良好**：新增Custom广告类型时架构保持一致
5. **访问权限正确**：子类可以正确访问父类的属性和方法

这种架构设计符合面向对象的设计原则，提高了代码的可维护性和扩展性。