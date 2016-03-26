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
end
