Pod::Spec.new do |s|
  s.name         = "ShareCenter"
  s.version      = "2.0"
  s.summary      = "share client include sina weibo ,tencent weibo, renren"

  s.description  = <<-DESC
                   share client include sina weibo ,tencent weibo, renren
                   DESC

  s.homepage     = "https://github.com/studentdeng/ShareCenterExample"
  s.license      = 'MIT'
  s.author       = { "curer" => "studentdeng@hotmail.com" }
  s.platform     = :ios, '5.0'

  s.source       = { :git => "https://github.com/studentdeng/ShareCenterExample.git", :tag => s.version.to_s }
  s.source_files  = 'ShareCenter', 'ShareCenter/**/*.{h,m}'

  s.frameworks   = 'QuartzCore', 'Security', 'CoreGraphics', 'AudioToolbox'
  s.library = 'sqlite3.0'
  s.vendored_libraries = 'ShareCenter/Vender/sina/libWeiboSDK/libWeiboSDK.a'

  s.prefix_header_contents = <<-EOS
#ifdef __OBJC__
#import "ROConnect.h"
#endif /* __OBJC__*/
EOS

end