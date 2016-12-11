Pod::Spec.new do |s|
    s.name         = "AppID"
    s.version      = '0.0.1'
    s.summary      = "TBD"
    s.homepage     = "https://github.com/ibm-bluemix-mobile-services/appid-clientsdk-swift"
    s.license      = 'Apache License, Version 2.0'
    s.author       = { "IBM Bluemix Services Mobile SDK" => "mobilsdk@us.ibm.com" }

    s.source       = { :git => 'https://github.com/ibm-bluemix-mobile-services/appid-clientsdk-swift.git', :tag => "v#{s.version}" }
    s.requires_arc = true
    s.source_files = 'Source/**/*.swift', 'Source/Resources/BMSSecurity.h'
    s.ios.deployment_target = '8.0'
end
