# 广告监听器使用指南

## 概述

广告监听器（AdListener）是 AdSDK 中用于接收广告事件回调的核心组件。通过实现相应的监听器协议，开发者可以监听广告的生命周期事件，并根据这些事件更新UI、记录数据或执行其他业务逻辑。

## 监听器架构

### 基础监听器协议

- **`AdListener`**: 所有广告类型通用的基础协议，定义了加载、点击、曝光、关闭等通用回调方法
- **`InterstitialListener`**: 插屏广告特有回调协议，继承自 `AdListener`
- **`BannerListener`**: 横幅广告特有回调协议，继承自 `AdListener`
- **`RewardVideoListener`**: 激励视频广告特有回调协议，继承自 `AdListener`
- **`NativeListener`**: 原生广告特有回调协议，继承自 `AdListener`
- **`SplashListener`**: 开屏广告特有回调协议，继承自 `AdListener`

### 监听器管理器

- **`ListenerManager`**: 统一管理各种类型监听器的单例类，负责添加、移除和通知监听器

## 快速开始

### 1. 创建监听器

```swift
import AdSdk

// 创建插屏广告监听器
class MyInterstitialListener: NSObject, InterstitialListener {
    
    // 重写需要的方法
    func onAdLoadSuccess(_ ad: Any) {
        print("插屏广告加载成功")
        // 在这里更新UI或执行其他逻辑
    }
    
    func onAdLoadFailed(_ ad: Any, error: AdError) {
        print("插屏广告加载失败: \(error.errorMessage)")
        // 在这里显示错误提示
    }
    
    func onInterstitialReadyToShow(_ ad: Any) {
        print("插屏广告准备就绪")
        // 在这里启用展示按钮
    }
    
    func onInterstitialShowCompleted(_ ad: Any) {
        print("插屏广告展示完成")
        // 在这里执行展示完成后的逻辑
    }
}
```

### 2. 注册监听器

```swift
// 创建监听器实例
let interstitialListener = MyInterstitialListener()

// 注册到监听器管理器
ListenerManager.shared.addListener(interstitialListener, type: "interstitial")
```

### 3. 移除监听器

```swift
// 在不需要时移除监听器
ListenerManager.shared.removeListener(interstitialListener, type: "interstitial")
```

## 监听器类型详解

### 通用广告回调（AdListener）

所有广告类型都支持以下回调方法：

| 方法 | 说明 | 使用场景 |
|------|------|----------|
| `onAdLoadStarted(_:)` | 广告开始加载 | 显示加载指示器 |
| `onAdLoadSuccess(_:)` | 广告加载成功 | 隐藏加载指示器，更新UI |
| `onAdLoadFailed(_:error:)` | 广告加载失败 | 显示错误提示，重试按钮 |
| `onAdClicked(_:)` | 广告被点击 | 记录点击事件，统计转化 |
| `onAdImpression(_:)` | 广告曝光 | 记录曝光事件，统计展示 |
| `onAdClosed(_:)` | 广告关闭 | 清理资源，更新状态 |
| `onAdPlayStarted(_:)` | 广告播放开始 | 显示播放状态 |
| `onAdPlayCompleted(_:)` | 广告播放完成 | 执行完成逻辑 |
| `onAdPlayFailed(_:error:)` | 广告播放失败 | 显示失败提示 |

### 插屏广告特有回调（InterstitialListener）

插屏广告除了通用回调外，还提供以下特有回调：

| 方法 | 说明 | 使用场景 |
|------|------|----------|
| `onInterstitialReadyToShow(_:)` | 准备就绪可展示 | 启用展示按钮 |
| `onInterstitialShowStarted(_:)` | 开始展示 | 记录展示时间 |
| `onInterstitialShowCompleted(_:)` | 展示完成 | 执行完成逻辑 |
| `onInterstitialShowFailed(_:error:)` | 展示失败 | 显示失败提示 |
| `onInterstitialCloseStarted(_:)` | 开始关闭 | 记录关闭时间 |
| `onInterstitialCloseCompleted(_:)` | 关闭完成 | 清理资源 |
| `onInterstitialShowDuration(_:duration:)` | 展示时长 | 统计展示效果 |
| `onInterstitialShowPercentage(_:percentage:)` | 展示比例 | 更新进度条 |

### 横幅广告特有回调（BannerListener）

横幅广告的特有回调包括：

| 方法 | 说明 | 使用场景 |
|------|------|----------|
| `onBannerSizeChanged(_:oldSize:newSize:)` | 尺寸变化 | 调整容器大小 |
| `onBannerRefreshed(_:)` | 广告刷新 | 显示刷新状态 |
| `onBannerRefreshFailed(_:error:)` | 刷新失败 | 显示错误提示 |
| `onBannerAutoPlayStarted(_:)` | 自动播放开始 | 显示播放状态 |
| `onBannerAutoPlayStopped(_:)` | 自动播放停止 | 隐藏播放状态 |
| `onBannerVisibilityChanged(_:isVisible:visibilityPercentage:)` | 可见性变化 | 统计可见度 |

### 激励视频广告特有回调（RewardVideoListener）

激励视频广告的特有回调包括：

| 方法 | 说明 | 使用场景 |
|------|------|----------|
| `onRewardVideoStarted(_:)` | 开始播放 | 显示播放界面 |
| `onRewardVideoCompleted(_:)` | 播放完成 | 发放奖励 |
| `onRewardVideoFailed(_:error:)` | 播放失败 | 显示失败提示 |
| `onRewardVideoClosed(_:)` | 关闭播放 | 隐藏播放界面 |
| `onRewardVideoRewarded(_:rewardType:rewardAmount:)` | 奖励发放 | 处理奖励逻辑 |
| `onRewardVideoSkipped(_:)` | 被跳过 | 处理跳过逻辑 |

## 最佳实践

### 1. 继承基础类

推荐继承 `BaseAdListenerExample` 类，这样可以获得所有方法的默认实现，只需要重写需要的方法：

```swift
class MyCustomListener: BaseAdListenerExample, InterstitialListener {
    
    // 只需要重写需要的方法
    override func onAdLoadSuccess(_ ad: Any) {
        super.onAdLoadSuccess(ad) // 调用父类实现
        // 添加自定义逻辑
        updateMyUI()
    }
    
    private func updateMyUI() {
        // 自定义UI更新逻辑
    }
}
```

### 2. 使用弱引用

监听器管理器使用弱引用管理监听器，不会造成循环引用，但建议在适当的时机移除监听器：

```swift
class MyViewController: UIViewController {
    
    private var interstitialListener: MyInterstitialListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建并注册监听器
        interstitialListener = MyInterstitialListener()
        ListenerManager.shared.addListener(interstitialListener!, type: "interstitial")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 移除监听器
        if let listener = interstitialListener {
            ListenerManager.shared.removeListener(listener, type: "interstitial")
        }
    }
}
```

### 3. 主线程UI更新

回调方法在后台队列中执行，UI更新需要在主线程进行：

```swift
func onAdLoadSuccess(_ ad: Any) {
    DispatchQueue.main.async {
        // 在主线程更新UI
        self.loadingIndicator.isHidden = true
        self.showAdButton.isEnabled = true
    }
}
```

### 4. 错误处理

合理处理各种错误情况，提供用户友好的提示：

```swift
func onAdLoadFailed(_ ad: Any, error: AdError) {
    DispatchQueue.main.async {
        let alert = UIAlertController(
            title: "广告加载失败",
            message: error.errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "重试", style: .default) { _ in
            // 重试加载广告
            self.retryLoadAd()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        self.present(alert, animated: true)
    }
}
```

## 监听器类型常量

使用预定义的监听器类型常量来注册监听器：

```swift
// 建议使用这些常量
ListenerManager.shared.addListener(listener, type: "interstitial")
ListenerManager.shared.addListener(listener, type: "banner")
ListenerManager.shared.addListener(listener, type: "reward_video")
ListenerManager.shared.addListener(listener, type: "native")
ListenerManager.shared.addListener(listener, type: "splash")
```

## 注意事项

1. **内存管理**: 监听器使用弱引用，但建议在适当的时机移除监听器
2. **线程安全**: 回调方法在后台队列执行，UI更新需要在主线程进行
3. **错误处理**: 合理处理各种错误情况，提供用户友好的提示
4. **性能考虑**: 避免在回调方法中执行耗时的操作
5. **生命周期**: 监听器的生命周期应该与使用它的对象保持一致

## 示例项目

参考 `AdListenerExample.swift` 文件中的完整实现示例，了解如何实现各种类型的监听器。

## 技术支持

如果在使用过程中遇到问题，请参考：

1. 错误码定义：`AdError.swift`
2. 监听器管理：`ListenerManager.swift`
3. 实现示例：`AdListenerExample.swift`
4. 各类型监听器协议文件
