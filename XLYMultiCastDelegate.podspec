Pod::Spec.new do |s|
  s.name         = "XLYMultiCastDelegate"
  s.version      = "1.0.0"
  s.summary      = "use delegate instead of NSNotification to cast message to mulitiple objects."

  s.homepage     = "https://github.com/kaizeiyimi/XLYMultiCastDelegate"
  
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "kaizei" => "kaizeiyimi@126.com" }

  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/kaizeiyimi/XLYMultiCastDelegate.git", :tag => 'v1.0.0' }
  s.source_files  = "codes/**/*.{h,m}"

  s.requires_arc = true

end
