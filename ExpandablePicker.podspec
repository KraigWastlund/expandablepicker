#
# Be sure to run `pod lib lint ExpandablePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'ExpandablePicker'
    s.version          = '1.1.6'
    s.summary          = 'Pick from a list of items.'
    s.description      = 'A picker selects an item from a list of items.  This picker alows for and shows heirarchical relationships within the picker and allows selection of any item in the list.'
    s.swift_version    = '4.2'
    
    s.homepage         = 'https://github.com/FishbowlInventory/ExpandablePicker'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'FishbowlInventory' => ' development@fishbowlinventory.com' }
    s.source           = { :git => 'https://github.com/FishbowlInventory/ExpandablePicker.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '12.0'
    
    s.source_files = 'ExpandablePicker/Classes/**/*'
    
#    s.resource_bundles = {
#        'ExpandablePicker' => ['ExpandablePicker/Assets/*.xcassets']
#    }
    s.resource = 'ExpandablePicker/Assets/*.xcassets'
    
    s.frameworks = 'UIKit'
end

# trunk command vvvvv
# pod trunk push ExpandablePicker.podspec
