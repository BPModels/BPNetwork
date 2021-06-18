#
# Be sure to run `pod lib lint BPNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'BPNetwork'
  s.version          = '0.1.8'
  s.summary          = 'A short description of BPNetwork.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/BPModels/BPNetwork'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'TestEngineerFish' => '916878440@qq.com' }
  s.source           = { :git => 'https://github.com/BPModels/BPNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'BPNetwork/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BPNetwork' => ['BPNetwork/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.swift_versions = '5.0'
  
   # 网络请求
   s.dependency 'Alamofire', '~> 4.8.2'
   # JSON转对象
   s.dependency 'ObjectMapper', '~> 3.5.1'
   # JSON转对象的配合网络请求
   s.dependency 'AlamofireObjectMapper', '~> 5.2'
   # 日志库
   s.dependency 'BPLog'
   # 设备信息库
   s.dependency 'BPDeviceInfo'
   
end
