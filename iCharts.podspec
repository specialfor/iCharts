#
# Be sure to run `pod lib lint iCharts.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iCharts'
  s.version          = '1.0.0'
  s.summary          = 'The solution for Telegram "March Coding Competition". Completely implemented using Core Animation and Auto Layout (NSLayoutAnchor).'
  s.swift_version    = '4.2'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Architecture
  TL;DR
  
  - fully implemented on CALayers
  - preferred composition over inheritance
  - fully data-driven UI
  - render only visible part of a chart
  
  Details
  
  The implementation of iCharts framework is highly motivated by Core Animaton CALayers capabilities and classes composition instead of inheritance in order to have flexible, extendable and easy-maintainable code base with SRP principle in the head.
  
  Note: of course in competition situation with time boundaries it is very hard to find trade offs between speed and quality, that's why some principles of SOLID are violated sometime.
  
  Also it should be remarked that all parts of UI are data-driven. Props is used as a dumb representation of UI state at each point of time. This approach makes possible to implement time-traveling debugging feature in future.
                       DESC

  s.homepage         = 'https://github.com/specialfor/iCharts'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Volodymyr Hryhoriev' => 'volodja.grigoriev@gmail.com' }
  s.source           = { :git => 'https://github.com/specialfor/iCharts.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/specialfor_ios'

  s.ios.deployment_target = '10.0'

  s.source_files = 'iCharts/Classes/**/*'
end
