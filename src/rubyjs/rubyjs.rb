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

  module Environment; end
end

require 'rubyjs/compiler'
require 'rubyjs/scope'
require 'rubyjs/nodes/all'
require 'rubyjs/javascript/all'
require 'rubyjs/model'
require 'rubyjs/rewrites'
require 'rubyjs/eval_into'
