Pod::Spec.new do |s|
  s.name         = "KICaptureKit"
  s.version      = "0.0.1"
  s.summary      = "KICaptureKit"
  s.description  = <<-DESC
  					KICaptureKit
                   DESC

  s.homepage      = "https://github.com/smartwalle/KICaptureKit"
  s.license       = "MIT"
  s.author        = { "SmartWalle" => "smartwalle@gmail.com" }
  s.platform      = :ios, "7.0"
  s.source        = { :git => "https://github.com/smartwalle/KICaptureKit.git", :tag => "#{s.version}" }
  s.source_files  = "KICaptureKit/KICaptureKit/*.{h,m}", "KICaptureKit/KICaptureView/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.frameworks    = "AVFoundation", "UIKit"
  s.requires_arc  = true
end
