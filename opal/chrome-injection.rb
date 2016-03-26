require 'opal_irb/completion_engine'
class ChromeEval
  def self.eval(str)
    `toBeEvaled = #{str}`
    if str.is_a? String
      str = "'#{str}'"
    end
    value = `eval(#{str})`
    `evaledValue = #{value}`
    $_  = value
    Native($_).inspect
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
