#
# Be sure to run `pod lib lint CTableViewManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                  = 'CTableViewManager'
  s.version               = '2.0.0'
  s.summary               = '管理UITableView数据'
  s.description           = <<-DESC
使用面向对象的方式替代直接使用数据源和代理
                            DESC
  s.homepage              = 'https://github.com/zhangjiuzhou/CTableViewManager'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.source                = { :git => 'https://github.com/zhangjiuzhou/CTableViewManager.git', :tag => s.version.to_s }
  s.author                = { 'nbyh100@sina.com' => 'nbyh100@sina.com' }
  s.ios.deployment_target = '9.0'
  s.source_files          = 'CTableViewManager/Classes/**/*'
  s.public_header_files   = 'CTableViewManager/Classes/*.h'
  s.private_header_files  = 'CTableViewManager/Classes/Private/*.h'
end
