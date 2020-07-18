#
#  Be sure to run `pod spec lint CalendarView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "CalendarView"
  spec.version      = "0.0.1"
  spec.summary      = "iOS library with a ready-to-use calendar with multiple event indicators for each cell"

  spec.homepage     = "https://github.com/afterfocus/CalendarView"
  spec.author             = { "Maksim" => "AfterFocus@icloud.com" }
  spec.social_media_url   = "https://vk.com/afterfocus"
  spec.license = { :type => "MIT", :file => "LICENSE" }

  spec.platform     = :ios
  spec.ios.deployment_target = "13.0"

  spec.source       = { :git => "https://github.com/afterfocus/CalendarView.git",                       :tag => "#{spec.version}" }

  spec.source_files  = "CalendarView/**/*.{swift}"
  spec.resources = "CalendarView/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
  
  spec.framework = "UIKit"
  spec.requires_arc = true
  spec.swift_version = "5.0"
end
