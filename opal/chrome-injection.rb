# Opal code injected to respond to opal-console
require 'opal_irb/completion_engine'
require 'awesome_print_lite'

class OpalConsole
  class Config
    def initialize
      self.auto_pretty_print = true
    end
    
    def auto_pretty_print?
      @auto_pretty_print
    end
    
    def auto_pretty_print=(bool)
      @auto_pretty_print = bool
    end

  end

  def self.config
    # sometimes this gets cached as the wrong type - how?
    if ! @@config.is_a? Config
      @@config = Config.new
    else
      @@config
    end
  end

end

AwesomePrintLite.force_colors = true

class ChromeEval
  def self.eval(str)
    `toBeEvaled = #{str}`
    if Native(str).is_a? String
      str = "'#{str}'"
    end
    value = `eval(#{str})`
    `evaledValue = #{value}`
    $_  = value
    
    ai = AwesomePrintLite::Inspector.new(raw: true)
    # ai = AwesomePrintLite::Inspector.new#(raw: true)
    if OpalConsole.config.auto_pretty_print?
      if(Native.native?($_))
        # `console.log("Is Native")`
        # `console.log(#{$_})`
        Native($_).inspect
      else
        # `console.log("NOT Native")`
        # `console.log(#{$_})`
        # wrapped_obj = $_.is_a? Module ? $_ : Native($_)
        wrapped_obj = Native($_)
        if(wrapped_obj.is_a?(Native::Object))
          wrapped_obj.inspect
        else
          if wrapped_obj.is_a?(Module)
            wrapped_obj = $_
          end
          ai.awesome($_)
        end
      end
    else
      Native($_).inspect
    end
    
  end

  def self.complete(text)
    index, matches = OpalIrb::CompletionEngine.get_matches(text, InspectedIrb.new)
    # alert "completion index = #{index}, matches = #{matches.inspect}"
    [index, matches]
  end

  # TODO: THis should be OpalIrb, but need to refactor gem so I don't
  # inject opal into chrome
  class InspectedIrb
    def irb_vars
      %x|irbVars = [];
       for(variable in Opal.irb_vars) {
         if(Opal.irb_vars.hasOwnProperty(variable)) {
            irbVars.push([variable, Opal.irb_vars[variable]])
         }
       };
       return irbVars;|
      end

      def irb_varnames
        irb_vars.map { |varname, value| varname }
      end

      def irb_gvars
        %x|gvars = [];
       for(variable in Opal.gvars) {
         if(Opal.gvars.hasOwnProperty(variable)) {
            gvars.push([variable, Opal.gvars[variable]])
         }
       };
       return gvars;|
      end

      def irb_gvarnames
        irb_gvars.map { |varname, value| varname }
      end

      def opal_classes
        classes = []
        $opal_js_object = Native(`Opal`)    # have to make this global right now coz not seen in the each closure w/current opal
        $opal_js_object.each {|k|
          attr = $opal_js_object[k]
          classes << attr if attr.is_a?(Class)
        }
        classes.uniq.sort_by { |cls| cls.name } # coz some Opal classes are the same, i.e. module == class, base, Kernel = Object
      end

      def opal_constants
        constants = []
        $opal_js_object = Native(`Opal`)    # have to make this global right now coz not seen in the each closure w/current opal
        $opal_js_object.each {|k|
          attr = $opal_js_object[k]
          constants << attr
        }
        constants.uniq

      end
    
    end
  end
