# require 'guard/guard'
notification "terminal_notifier"

guard "process", :name => "compile-opal", :command => "rake" do
  watch /(opal|spec)\/.+\.rb/
end
