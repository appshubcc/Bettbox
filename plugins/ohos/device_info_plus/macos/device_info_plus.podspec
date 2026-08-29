#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'device_info_plus'
  s.version          = '0.0.1'
  s.summary          = 'No-op implementation of the macos device_info_plus to avoid build issues on macos'
  s.description      = <<-DESC
 No-op implementation of the device_info_plus plugin to avoid build issues on macos.
https://github.com/flutter/flutter/issues/46618
                          DESC
  s.homepage         = 'https://github.com/fluttercommunity/plus_plugins/tree/master/packages/device_info_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Community' => 'authors@fluttercommunity.dev' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'FlutterMacOS'

  s.platform = :osx
  s.osx.deployment_target = '10.11'
end
