require 'opal_irb_jqconsole'

class OpalChromePanelJqconsole < OpalIrbJqconsole
  def self.console
    @console
  end

  # create on a pre existing div
  def self.create(parent_element_id)
    @console = OpalChromePanelJqconsole.new(parent_element_id)
  end

  def setup_cmd_line_methods
    # stub out parent
  end
  COMMANDS = ['help', 'history', '$_']

  def local_command?(cmd)
    cmd =~ /^lputs/ ||
      COMMANDS.include?(cmd)   
  end

  def process_local_cmd(cmd)
    case cmd
    when 'help'
      OpalChromePanelJqconsole.help
    when 'history'
      OpalChromePanelJqconsole.history
    when /lputs (.+)/
      OpalChromePanelJqconsole.unescaped_write(eval($1))

    end
  end

  def handler(cmd)
    if cmd && `#{cmd} != undefined`
      if local_command?(cmd)
        process_local_cmd(cmd)
      else
        process(cmd)
      end
    end
    @jqconsole.Prompt(true, lambda {|c| handler(c) }, lambda {|c| check_is_incomplete(c)})
  end

  def redirect_console_dot_log
    OpalIrbLogRedirector.add_to_redirect(lambda {|args| OpalChromePanelJqconsole.write(args)})
  end

  # can't use eval as a Chrome panel extention
  # Chrome panel handles eval as asynchronous
  def eval_handler(raw_result, raw_exception)
    result = Native(raw_result)
    `console.orig_log(#{raw_exception})` if raw_exception
    exception = Native(raw_exception)
    if exception && (exception.isError || exception.isException)
      log exception
      if exception.isError
        result_str = "Error " + exception.code + ": " + exception.description
      elsif exception.isException
        result_str = "Exception: " + exception.value
      end
    else
      result_str = result
    end
    $_ = raw_result
    @jqconsole.Write(" => #{result_str} \n")
  end

  # we override this because processing has to be asynchronous and connect to the inspectedWindow
  # we wrap that interface via a TOP JS variable
  # We've injected a ChromeEval class into inspectedWindow
  def process(cmd)
    begin
      log "\n\n|#{cmd}|"
      if cmd
        cmd = cmd.sub /return(.+)/, "return#{$1}.$to_json()"
        $irb_last_compiled = @irb.parse cmd
        log $irb_last_compiled
        top.runIt("tmpVar_Irb = #{$irb_last_compiled}; Opal.ChromeEval.$eval(tmpVar_Irb)", lambda { |result, exception| eval_handler(result, exception)})
        # top.runIt("Opal.ChromeEval.$eval(#{$irb_last_compiled})", lambda { |result, exception| eval_handler(result, exception)})
        # top.runIt($irb_last_compiled, lambda { |result, exception| eval_handler(result, exception)})
      end
    rescue Exception => e
      # alert e.backtrace.join("\n")
      if e.backtrace
        output = "FOR:\n#{$irb_last_compiled}\n============\n" + e.backtrace.join("\n")
        # TODO remove return when bug is fixed in rescue block
        return output
      # FF doesn't have Error.toString() as the first line of Error.stack
      # while Chrome does.
      # if output.split("\n")[0] != `e.toString()`
      #   output = "#{`e.toString()`}\n#{`e.stack`}"
      # end
      else
        output = `e.toString()`
        log "\nReturning NO have backtrace |#{output}|"
        # TODO remove return when bug is fixed in rescue block
        return output
      end
    end
  end

  # overriding this to do some intialization
  # TBD: extend parent class to have a dedicated init function we can properly overriding
  # I can't think of any meaningful way to support a code link handling URL yet, so commandeering this
  def setup_code_link_handling
    top.runIt("Opal.ChromeEval.$eval(Opal.RUBY_ENGINE_VERSION)",
              lambda { |result, exception|
                `console.orig_log(exception)` if exception
                msg = result ? "Inspected Window Opal::VERSION = #{result}\n" : "Opal not running or older than 0.7 - Console not supported for this page\n"
                write  msg
              })
    
  end

  def top
    top = Native(`TOP`)
  end

  def tab_complete(text)
    # alert "completing #{text.inspect}"
    top.runIt("Opal.ChromeEval.$complete(#{text.inspect})",
              lambda { |results, exception|
                # alert("tab complete results = #{results.inspect}")
                index, matches = results
                results = OpalIrb::CompletionResults.new(text, index, matches)
                results.set_old_prompt(@jqconsole, CONSOLE_PROMPT, 'jqconsole-old-prompt')
                results.display_matches(@jqconsole)
                results.update_prompt(@jqconsole)
                results.insert_tab?
              })
    false
  end

end
