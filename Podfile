# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Flash Chat' do

pod 'Firebase'
pod 'Firebase/Database'
pod 'Firebase/Auth'
pod 'SVProgressHUD'
pod 'ChameleonFramework'
use_frameworks!


end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
    end
  end
end
