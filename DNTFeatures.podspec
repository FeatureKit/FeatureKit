Pod::Spec.new do |s|
  s.name         = "DNTFeatures"
  s.version      = "0.5"
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
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/danthorpe/DNTFeatures.git", :tag => "#{s.version}" }
  s.source_files  = "sources/*.{h,m}"
  s.prefix_header_contents = '''
  #ifdef __OBJC__    
    #define DNT_WEAK_SELF __weak __typeof(&*self)weakSelf = self;
    #define DNT_STRING(value) (@#value)
    #define DNT_YESNO(value) value ? @"YES" : @"NO"
    #define DNT_PRETTY_METHOD NSStringFromSelector(_cmd)
  #endif
  '''    
  s.resources = "sources/*.{storyboard,xib}", "resources/*.{storyboard,xib}"
  s.requires_arc = true

  s.xcconfig = { "DNTFEATURES_VERSION" => "#{s.version}" }
  s.dependency "YapDatabase", "~> 2"
end
