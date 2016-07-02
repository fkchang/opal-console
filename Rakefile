require 'opal'
require 'opal-jquery'
require 'opal-browser'
require 'opal-rspec'
require 'opal-irb'
require 'opal/sprockets/environment'
require 'awesome_print_lite'

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

desc "build chrome injection script"
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


desc "build all js scripts from opal"
task :build => [:build_jqconsole_chrome, :build_injection_script] do
  sh 'say done building'
end

desc 'zip up file to upload to Chrome store'
task :zip do
  Dir.mkdir 'zip' unless Dir.exist? 'zip'
  cp '../opal-console.pem', 'zip/key.pem'
  cp_r 'assets', 'zip/'
  cp_r 'vendor', 'zip/'
  cp Dir['*.js'], 'zip'
  cp Dir['*.html'], 'zip'
  cp 'manifest.json', 'zip'
  Dir.chdir('zip') {
    sh 'zip -r ../opal-console.zip *'
  }
end

task default: :build
