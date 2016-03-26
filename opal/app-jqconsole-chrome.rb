require 'opal'
require 'opal-jquery'
require 'opal-parser'
require 'browser'               # include opal browser so we have access to it
require 'browser/dom'
require 'opal_chrome_panel_jqconsole'

Document.ready? do
  OpalChromePanelJqconsole.create("#console")
end
