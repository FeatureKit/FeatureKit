Pod::Spec.new do |s|
  s.name         = "FeatureKit"
  s.version      = "0.6"
  s.summary      = "A Swift framework to provide Feature flags."
  s.description  = <<-DESC

Use feature flags to hide code which is still in development.
                   
Briefly, feature flags enable continuous deployment of product features. During the 
development of new product features, the changes are “switched off” behind a feature flag.
When the product feature is ready, the flag can be switched to enable the new feature. 
This could all be done after the application has shipped to customers.

This allows for multiple streams of development to occur concurrently, which is often 
necessary for large products or teams.

FeatureKit provides a software framework to support the basics on the 
client side. It will allow client side application developers to:

	1. Define the feature identifiers
	2. Instantiate a “service” layer which can be queried for features
	3. Toggling of features
	4. Loading of features via a URL, with an appropriate mapper

DESC

  s.homepage     = "https://github.com/FeatureKit/FeatureKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniel Thorpe" => "danthorpe@me.com" }
  s.social_media_url   = "http://twitter.com/danthorpe"
  s.osx.deployment_target = '10.11'  
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.2'    
  s.watchos.deployment_target = '2.2'      
  s.source       = { :git => "https://github.com/FeatureKit/FeatureKit.git", :tag => "#{s.version}" }
  s.source_files = "Sources/*.{h,m,swift}"
  s.requires_arc = true
  s.xcconfig     = { "FEATUREKIT_VERSION" => "#{s.version}" }
  s.dependency 'ValueCoding', '~> 1'
  s.dependency 'Result', '~> 2'
end
