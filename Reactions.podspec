Pod::Spec.new do |s|
  s.name             = 'Reactions'
  s.version          = '4.0.0'
  s.license          = 'MIT'
  s.summary          = 'Fully customizable reactions control'
  s.homepage         = 'https://github.com/RomanTysiachnik/Reactions'
  s.source           = { :git => 'https://github.com/RomanTysiachnik/Reactions.git', :tag => s.version }
  s.authors          = { 'Roman Tysiachnik' => 'roman.tysiachnik@sigma.software' }

  s.ios.deployment_target = '12.1'
  s.ios.framework         = 'UIKit'

  s.source_files         = 'Sources/**/*.swift'
  
  s.requires_arc = true
end
