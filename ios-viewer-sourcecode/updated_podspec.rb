#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_igolf_viewer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_igolf_viewer'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '15.6'

  # IGolfViewer3D framework
  s.vendored_frameworks = 'IGolfViewer3D.xcframework'

  # Texture resources
  s.resources = 'Assets/**/*.png'

  # System framework dependencies for IGolfViewer3D
  s.frameworks = 'GLKit', 'CoreLocation'

  # Flutter.framework does not contain a i386 slice.
  # IGolfViewer3D.xcframework only supports x86_64 for simulator, not arm64
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
  s.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.swift_version = '5.0'
end
