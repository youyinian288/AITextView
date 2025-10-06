Pod::Spec.new do |s|
  s.name             = "AITextView"
  s.version          = "4.3.0"
  s.summary          = "AI Text Editor for iOS written in Swift"
  s.homepage         = "https://github.com/T-Pro/AITextView"
  s.license          = 'BSD 3-clause'
  s.author           = { "Caesar Wirth" => "cjwirth@gmail.com", "Pedro Paulo de Amorim" => "pp.amorim@hotmail.com" }
  s.source           = { :git => "https://github.com/T-Pro/AITextView.git", :tag => s.version.to_s }

  s.platform     = :ios, '12.0'
  s.swift_version = '5.7'
  s.requires_arc = true

  s.source_files = 'AITextView/Sources/*'
  s.resources = [
      'AITextView/Sources/Resources/icons/*',
      'AITextView/Sources/Resources/editor/*'
    ]
end
