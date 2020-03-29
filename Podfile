# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'zetten' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for zetten
  pod 'FirebaseCore'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Crashlytics'
  pod "FirebaseFirestoreSwift"
  pod 'GRDB.swift'
  pod 'GRDBCombine'  
  pod 'Resolver'
  target 'ZettenTests' do
    inherit! :search_paths
    # Pods for testing
  end
#
#  target 'zettenUITests' do
#    # Pods for testing
#  end
 
  post_install do |installer|
    installer.pods_project.targets.select { |target| target.name == "GRDB.swift" }.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['OTHER_SWIFT_FLAGS'] = "$(inherited) -D SQLITE_ENABLE_FTS5"
      end
    end
  end

end
