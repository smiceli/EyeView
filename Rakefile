# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'EyeView'
  app.codesign_certificate = 'iPhone Developer: Sean Miceli (RKYL64RF52)'
  app.provisioning_profile = '/Users/smiceli/Library/MobileDevice/Provisioning Profiles/FCDA2B2F-BDB9-4FBF-A11B-D3CDE501FC12.mobileprovision'
  app.frameworks += ['AVFoundation']
end
