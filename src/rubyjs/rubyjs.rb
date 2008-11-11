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
require 'rubyjs/javascript/nodes/all'
require 'rubyjs/model'
require 'rubyjs/rewrites'
require 'rubyjs/eval_into'
require 'rubyjs/naming/name_generator'
require 'rubyjs/naming/name_cache'
