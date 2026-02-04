Pod::Spec.new do |s|
  s.name             = 'ARCraft'
  s.version          = '1.0.0'
  s.summary          = 'AR development toolkit for iOS with ARKit integration.'
  s.description      = 'ARCraft provides AR development tools with ARKit, RealityKit support.'
  s.homepage         = 'https://github.com/muhittincamdali/ARCraft'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/ARCraft.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation', 'ARKit', 'RealityKit'
end
