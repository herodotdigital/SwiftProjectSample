# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

use_frameworks!
def rx_swift()
    pod 'RxSwift', :git => "https://github.com/ReactiveX/RxSwift.git", :branch => 'rxswift-3.0'
    pod 'RxCocoa', :git => "https://github.com/ReactiveX/RxSwift.git", :branch => 'rxswift-3.0'
    pod 'NSObject+Rx'
    pod 'RxOptional'
    pod 'RxDataSources', '2.0.2'
    pod 'Moya/RxSwift', '~> 8.0'
end

def production_libs()
    rx_swift()
    pod 'Moya', '~> 8.0'
    pod 'SnapKit', '~> 3.0'
    pod 'Alamofire'
    pod 'Kingfisher'
    pod 'SwiftyJSON'
    pod 'Cartography', '~> 1.1'
    pod 'R.swift', '~> 3.3'
    pod 'IQKeyboardManagerSwift'
    pod 'DateTools'
    pod 'KILabel', '~> 1.0.0'
    pod 'CocoaLumberjack/Swift'
    pod 'MBProgressHUD', '~> 0.9.2'
    pod 'Fabric'
    pod 'Crashlytics'
end

target 'SwiftProjectSample' do
  production_libs()
  pod 'Reveal-iOS-SDK', :configurations => ['Debug']
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D','TRACE_RESOURCES']
        end
      end
    end
  end
end

use_frameworks!
def test_target_libs()
    pod 'Nimble'
    pod 'Fakery', '~> 2.1.0'
    pod 'OHHTTPStubs'
    pod 'OHHTTPStubs/Swift'
    pod 'RxNimble'
    pod 'Quick'
end

target 'SwiftProjectSampleTests' do
  test_target_libs()
  production_libs()
end
