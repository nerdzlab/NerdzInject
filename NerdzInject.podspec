

Pod::Spec.new do |s|
  s.name             = 'NerdzInject'
  s.version          = '1.0.8'
  s.summary          = 'A CSS-like way of creation and applying styles to view components'
  s.homepage         = 'https://github.com/nerdzlab/NerdzInject'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NerdzLab' => 'supernerd@nerdzlab.com' }
  s.source           = { :git => 'https://github.com/nerdzlab/NerdzInject.git', :tag => s.version }
  s.social_media_url = 'https://nerdzlab.com'
  s.ios.deployment_target = '8.0'
  s.swift_versions = ['5.0']
  s.source_files = 'Sources/**/*'
end
