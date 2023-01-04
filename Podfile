platform :ios, '13.0'

use_frameworks!

target 'Gespodo FootScan 3D' do
  project 'Gespodo FootScan 3D.xcodeproj'
  
  pod 'Alamofire', '~> 4.5'
  pod 'Alamofire-SwiftyJSON', '~>3.0'
  pod 'DropDown'
  source 'https://github.com/CocoaPods/Specs.git'
  pod 'PhoneNumberKit', '~> 2.5'
  #pod 'PromiseKit', '~> 6.8'
  #pod 'PromiseKit/Alamofire'
  pod 'FlagPhoneNumber'




  # Pods for PodTest
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'

  # pod files here
end


# target 'Gespodo FootScan 3D' do
# use_modular_headers!



# This should solve error "ITMS-90381: Too many symbol files" from the App Store Connect
# https://stackoverflow.com/questions/25755240/too-many-symbol-files-after-successfully-submitting-my-apps
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
    end
end
