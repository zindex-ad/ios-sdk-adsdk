Pod::Spec.new do |spec|
  spec.name         = "ZindexAdSdk"
  spec.version      = "1.0.0"
  spec.summary      = "米花糖iOS广告SDK - 功能强大的广告聚合框架"
  spec.description  = <<-DESC
    米花糖iOS广告SDK是一个功能强大的广告SDK，支持多种广告形式，方便开发者简单容易的接入，提升开发者收益。
    
    主要特性：
    - 支持横幅、插屏、原生、激励视频、开屏广告
    - 模块化设计，支持动态适配器加载
    - 智能策略和瀑布流机制
    - 实时监控和性能指标
    - 高度可配置，支持远程配置
  DESC

  spec.homepage     = "https://github.com/zindex-ad/ios-sdk-adsdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Zindex" => "support@zindex.com" }

  # Platform
  spec.platform     = :ios, "13.0"
  spec.ios.deployment_target = "13.0"

  # Source
  spec.source       = { 
    :git => "https://github.com/zindex-ad/ios-sdk-adsdk.git", 
    :tag => "v#{spec.version}" 
  }

  # Framework
  spec.vendored_frameworks = "ZindexAdSdk.xcframework"
  # XCFramework 内部实际模块/二进制名为 AdSdk
  spec.module_name = "AdSdk"

  # Dependencies
  spec.frameworks = "Foundation", "UIKit", "AdSupport", "AppTrackingTransparency", "StoreKit", "SystemConfiguration", "CoreTelephony", "Security", "WebKit"
  
  # Build Settings
  spec.requires_arc = true
  spec.xcconfig = { 
    "OTHER_LDFLAGS" => "-ObjC"
  }

  # Swift Version
  spec.swift_version = "5.0"

  # Podspec Metadata
  spec.cocoapods_version = ">= 1.10.0"
end
