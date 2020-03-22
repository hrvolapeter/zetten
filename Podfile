# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Zetten-test' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Zetten-test
  pod 'FirebaseCore'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Crashlytics'
  pod "FirebaseFirestoreSwift"
  pod 'GRDB.swift'
  pod 'Resolver'
  post_install do |installer|
      installer.pods_project.targets.select { |target| target.name == "GRDB.swift" }.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['OTHER_SWIFT_FLAGS'] = "$(inherited) -D SQLITE_ENABLE_FTS5"
      end
    end
  end
end
