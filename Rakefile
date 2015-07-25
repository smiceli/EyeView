# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

#require 'rubygems'  
#require 'motion-sparkinspector'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  name = 'EyeView'
  app.name = name
  app.codesign_certificate = 'iPhone Developer: Sean Miceli (RKYL64RF52)'
  app.provisioning_profile = '/Users/smiceli/Library/MobileDevice/Provisioning Profiles/e12d3ee8-c7a4-41f4-adae-5c467d365130.mobileprovision'
  app.frameworks += ['AVFoundation']
  app.device_family = [:iphone, :ipad]
  app.deployment_target = '8.0'
  app.identifier = "com.bullhead_soft.#{name}"
end
