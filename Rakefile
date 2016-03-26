require 'opal'
require 'opal-jquery'
require 'opal-browser'
require 'opal-rspec'
require 'opal-irb'
require 'opal/sprockets/environment'

def build_static(app_basename, dest=".")
  # File.open("compiled/#{app_basename}.js", "w+") do |out|
  #   Opal::Processor.source_map_enabled = false
  #   env = Opal::Environment.new
  #   env.append_path "examples"
  #   env.append_path "opal"
  #   out << env[app_basename].to_s
  # end
  Opal.append_path "opal"
  File.binwrite "#{dest}/#{app_basename}.js", Opal::Builder.build("#{app_basename}").to_s +
                                              "Opal.require('#{app_basename}.js')"
  puts "Wrote #{app_basename}"
end

desc "debug chrome injection script"
task :build_injection_script do
  build_static('chrome-injection', '.')
end

desc "build jqconsole based irb for chrome panel"
task :build_jqconsole_chrome do
  build_static('app-jqconsole-chrome', "assets/javascripts")
end

desc "cleans up generated js"
task :clean do
  rm ['assets/javascripts/app-jqconsole-chrome.js', 'chrome-injection.js']
end


task :build => [:build_jqconsole_chrome, :build_injection_script]

task default: :build
