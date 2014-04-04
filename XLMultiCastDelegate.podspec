Pod::Spec.new do |s|
  s.name         = "XLMultiCastDelegate"
  s.version      = "0.1"
  s.summary      = "XLMultiCastDelegate can act like normal delegate object but can multicast the method invocation the other delegates."
  s.homepage     = "https://github.com/kaizeiyimi/XLMultiCastDelegate"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "王凯" => "kaizeiyimi@126.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/kaizeiyimi/XLMultiCastDelegate.git", :tag=> "0.1" }
  s.source_files  = 'codes/*.{h,m}'
  s.requires_arc = true
end
