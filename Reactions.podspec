Pod::Spec.new do |s|
  s.name             = 'Reactions'
  s.version          = '3.1.0'
  s.license          = 'MIT'
  s.summary          = 'Fully customizable reactions control'
  s.homepage         = 'https://github.com/RomanTysiachnik/Reactions'
  s.authors          = { 'Yannick Loriot' => 'contact@yannickloriot.com' }
  s.social_media_url = 'https://twitter.com/yannickloriot'
  s.source           = { :git => 'https://github.com/RomanTysiachnik/Reactions.git', :tag => s.version }

  s.ios.deployment_target = '12.1'
  s.ios.framework         = 'UIKit'

  s.source_files         = 'Sources/**/*.swift'
  s.ios.resource_bundles = { 'Reactions' => 'Resources/**/*' }

  s.requires_arc = true
end
