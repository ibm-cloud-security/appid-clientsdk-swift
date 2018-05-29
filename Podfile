use_frameworks!

def shared_pods
	platform :ios, '10.0'
	pod 'BMSCore', '~> 2.3.1'
	pod 'JOSESwift', '~> 1.1.0'
end

target 'BluemixAppID' do
	shared_pods
end

target 'BluemixAppIDTests' do
	shared_pods
end

# Jose requires swift 4.1, but project defaults to swift 3.3
post_install do |installer|
	installer.pods_project.targets.each do |target|
		if ['JOSESwift'].include? target.name
			target.build_configurations.each do |config|
				config.build_settings['SWIFT_VERSION'] = '4.1'
			end
		end
	end
end
