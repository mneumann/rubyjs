module RubyJS
  def self.debug
    @debug
  end

  def self.debug=(bool)
    @debug = bool
  end

  def self.log(message)
    STDERR.puts(message) if debug()
  end
end
