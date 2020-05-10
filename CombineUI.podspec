Pod::Spec.new do |s|
  s.name             = 'CombineUI'
  s.version          = '0.1.1'
  s.summary          = 'Combine bindings for Cocoa Touch.'
  s.description      = 'This library exposes UIControl, UITableView, NSFetchedResultsController, and other common Cocoa Touch classes to Combine.'
  s.homepage         = 'https://github.com/pranjalsatija/CombineUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pranjalsatija' => 'me@pranj.co' }
  s.source           = { :git => 'https://github.com/pranjalsatija/CombineUI.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'CombineUI/Sources/**/*'
end
