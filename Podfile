source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'VideoTest2' do
pod 'Alamofire'
pod 'ObjectMapper'
pod 'AlamofireObjectMapper'
pod 'SDWebImage', '~>3.7'
pod 'Kingfisher', '~> 3.2.2'
pod 'SnapKit', '~> 3.0.2'
pod 'ReachabilitySwift', '~> 3'
pod 'RxSwift'
pod 'RxCocoa'
pod 'NVActivityIndicatorView'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
