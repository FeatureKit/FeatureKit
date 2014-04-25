#
#  Be sure to run `pod spec lint DNTFeatures.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "DNTFeatures"
  s.version      = "0.0.1"
  s.summary      = "An Objective-C library to provide Feature flags and debug options."

  s.description  = <<-DESC
                   Use feature flags to hide code which is still in development.
                   
                   DNTFeatures provides classes to register flags, query the state of a 
                   flag, and present a view controller to switch the flags on or off.
                   
                   Extend this mechanism by allowing server control of flags, update the
                   default value from a server to enable features in production. This can
                   be used for powerful release strategies, such as turning on a feature
                   gradually over a user base, or restrict features to user/market slices.
                   
                   Additionally, you can define debug options for feature to further 
                   control behaviour or allow additional configuration during development
                   or QA. E.g. Enable Verbose Logging for a particular feature.

                   DESC

  s.homepage     = "http://github.com/danthorpe/DNTFeatures"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniel Thorpe" => "danthorpe@me.com" }
  s.social_media_url   = "http://twitter.com/danthorpe"

  s.platform     = :ios
  s.platform     = :ios, "6.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"

  s.source       = { :git => "http://github.com:danthorpe/DNTFeatures.git", :tag => "0.0.1" }
  s.source_files  = "sources/*.{h,m}"
  s.prefix_header_contents = '''
  #ifdef __OBJC__    
    #define DNT_WEAK_SELF __weak __typeof(&*self)weakSelf = self;
    #define DNT_STRING(value) (@#value)
    #define DNT_YESNO(value) value ? @"YES" : @"NO"
    #define DNT_PRETTY_METHOD NSStringFromSelector(_cmd)
  #endif
  '''    
  s.resources = "sources/*.{storyboard,xib}"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "YapDatabase", "~> 2.4"

end
