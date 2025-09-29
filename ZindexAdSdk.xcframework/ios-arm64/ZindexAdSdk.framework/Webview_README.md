# WebView 组件使用说明

## 概述

WebView组件是AdSDK中用于加载H5落地页的核心组件，提供了现代化的WKWebView实现，支持多种广告场景下的H5页面展示。

## 组件结构

```
webview/
├── WebViewController.swift      # WebView控制器
├── WebViewManager.swift         # WebView管理器
├── WebViewExtensions.swift      # WebView扩展工具
└── README.md                    # 使用说明
```

## 主要特性

✅ **现代化实现**
- 使用WKWebView替代已弃用的UIWebView
- 支持iOS 9.0及以上版本
- 更好的性能和安全性

✅ **完整的用户体验**
- 加载指示器
- 下拉刷新
- 错误处理和重试
- 分享功能
- 导航栏控制

✅ **广告专用优化**
- 禁用右键菜单
- 禁用文本选择
- 禁用拖拽操作
- 内联媒体播放支持

✅ **丰富的扩展功能**
- JavaScript交互
- CSS注入
- 页面截图
- 缓存管理
- URL工具方法

## 使用方法

### 1. CustomAd内部WebView使用（推荐）

CustomAd点击时默认使用内部WebView，不会跳转到系统浏览器：

```swift
// 在CustomAdAdapter中，所有广告类型都优先使用内部WebView
protected func handleAdClick(ad: CustomAd) {
    guard let viewController = getViewController() else { return }
    
    switch ad.ctype {
    case 1: // H5广告 - 直接使用内部WebView
        if !ad.ldp.isEmpty {
            openWebView(url: ad.ldp, title: ad.title, viewController: viewController)
        }
        
    case 9: // Deeplink - 优先尝试Deeplink，失败后使用内部WebView
        if !ad.deeplink.isEmpty {
            if openDeepLink(url: ad.deeplink) {
                // Deeplink成功，使用系统浏览器
                return
            } else {
                // Deeplink失败，使用内部WebView
                if !ad.ldp.isEmpty {
                    openWebView(url: ad.ldp, title: ad.title, viewController: viewController)
                }
            }
        }
        
    case 2: // 下载类广告 - 使用内部WebView
        if let downloadUrl = ad.durl, !downloadUrl.isEmpty {
            openWebView(url: downloadUrl, title: ad.title, viewController: viewController)
        }
        
    default:
        // 其他类型广告，使用内部WebView
        if !ad.ldp.isEmpty {
            openWebView(url: ad.ldp, title: ad.title, viewController: viewController)
        }
    }
}
```

**优势：**
- 🎯 **用户体验一致**：所有广告都在应用内打开
- 🔒 **用户留存**：不会意外跳转到系统浏览器
- 📱 **统一界面**：使用相同的WebView样式和交互
- 🛡️ **安全可控**：完全控制WebView的行为和内容

### 2. 基本使用

```swift
import AdSDK

// 打开H5落地页
WebViewManager.shared.openWebView(
    url: "https://example.com",
    title: "广告详情",
    from: self
)
```

### 2. 使用URL对象

```swift
let url = URL(string: "https://example.com")!
WebViewManager.shared.openWebView(
    url: url,
    title: "广告详情",
    from: self
)
```

### 3. 在CustomAd中使用（内部WebView，不跳转系统浏览器）

```swift
// 在CustomAdAdapter中处理H5广告点击
private func openWebView(url: String, title: String, viewController: UIViewController) {
    ALog.d(TAG, "使用内部WebView打开H5页面: \(url)")
    
    // 使用WebViewManager在应用内部打开H5落地页
    // 这不会跳转到系统浏览器，而是在应用内展示
    WebViewManager.shared.openWebView(
        url: url,
        title: title,
        from: viewController
    )
}
```

**关键特性：**
- ✅ **内部WebView优先**：所有广告类型都优先使用内部WebView
- ✅ **不跳转系统浏览器**：保持用户在应用内，提供统一体验
- ✅ **Deeplink智能处理**：仅在Deeplink成功时使用系统浏览器
- ✅ **完整错误处理**：Deeplink失败后自动使用内部WebView作为备选

### 4. 直接使用WebViewController

```swift
let webViewController = WebViewController(
    url: URL(string: "https://example.com")!,
    title: "广告详情"
)
let navigationController = UINavigationController(rootViewController: webViewController)
present(navigationController, animated: true)
```

## 配置选项

### WebView配置

```swift
// 广告专用配置
let adConfig = WebViewManager.WebViewConfig(
    allowsInlineMediaPlayback: true,
    allowsBackForwardNavigationGestures: false,
    allowsLinkPreview: false,
    scrollViewBounces: false,
    timeoutInterval: 15.0
)

// 默认配置
let defaultConfig = WebViewManager.defaultConfig
```

### WKWebViewConfiguration

```swift
// 创建广告专用配置
let config = WKWebViewConfiguration.createAdConfiguration()

// 创建安全配置
let secureConfig = WKWebViewConfiguration.createSecureConfiguration()
```

## 扩展功能

### JavaScript交互

```swift
// 执行JavaScript
webView.executeJavaScript("document.title") { result, error in
    if let title = result as? String {
        print("页面标题: \(title)")
    }
}

// 获取页面标题
webView.getTitle { title in
    print("页面标题: \(title ?? "未知")")
}

// 滚动到顶部
webView.scrollToTop()

// 滚动到底部
webView.scrollToBottom()
```

### CSS和JavaScript注入

```swift
// 注入CSS样式
webView.injectCSS("""
    body { 
        background-color: #f0f0f0; 
        font-family: -apple-system, BlinkMacSystemFont, sans-serif;
    }
""")

// 注入JavaScript代码
webView.injectJavaScript("""
    console.log('AdSDK WebView loaded');
    // 自定义JavaScript逻辑
""")
```

### 页面操作

```swift
// 隐藏元素
webView.hideElement(selector: ".ad-banner")

// 显示元素
webView.showElement(selector: ".content")

// 设置缩放
webView.setZoomScale(1.2)

// 获取页面截图
webView.takeScreenshot { image in
    if let screenshot = image {
        // 处理截图
    }
}
```

### 缓存管理

```swift
// 清除WebView缓存
webView.clearCache()

// 清除所有网站数据
webView.clearAllWebsiteData()
```

## 工具方法

### URL处理

```swift
// 验证URL
let isValid = WebViewUtils.isValidURL("https://example.com")

// 获取域名
let domain = WebViewUtils.getDomain(from: "https://example.com/path")

// 构建URL
let url = WebViewUtils.buildURL(
    baseURL: "https://example.com",
    path: "/api",
    parameters: ["id": "123", "type": "ad"]
)

// 编码参数
let encoded = WebViewUtils.encodeParameters(["key": "value"])

// 解码参数
let decoded = WebViewUtils.decodeParameters("key=value&type=ad")
```

### 请求头

```swift
// 获取User-Agent
let userAgent = WebViewUtils.getUserAgent()

// 创建广告专用请求头
let headers = WebViewUtils.createAdHeaders()
```

## 错误处理

WebView组件提供了完整的错误处理机制：

1. **网络错误**: 自动显示错误提示，支持重试
2. **加载超时**: 可配置超时时间，默认30秒
3. **无效URL**: 自动验证URL格式
4. **JavaScript错误**: 安全的JavaScript执行环境

## 安全特性

1. **内容安全策略**: 支持CSP规则配置
2. **HTTPS强制**: 可配置强制使用HTTPS
3. **JavaScript控制**: 可选择性禁用JavaScript
4. **Cookie管理**: 支持无痕浏览模式

## 性能优化

1. **缓存策略**: 智能缓存管理
2. **内存管理**: 自动内存清理
3. **预加载**: 支持页面预加载
4. **压缩传输**: 支持gzip压缩

## 注意事项

1. **iOS版本**: 需要iOS 9.0及以上版本
2. **权限要求**: 需要网络访问权限
3. **内存使用**: 大量WebView可能影响内存使用
4. **用户体验**: 建议添加加载指示器和错误处理

## 更新日志

### v1.0.0
- 初始版本发布
- 支持基本的H5页面加载
- 提供WebViewManager统一管理
- 包含完整的错误处理机制

## 技术支持

如有问题或建议，请联系开发团队。 