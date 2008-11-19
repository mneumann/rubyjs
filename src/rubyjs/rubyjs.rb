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

require 'rubyjs/compiler/compiler'
require 'rubyjs/compiler/scope'
require 'rubyjs/compiler/rewrites'
require 'rubyjs/compiler/nodes/all'

require 'rubyjs/javascript/scope'
require 'rubyjs/javascript/nodes/all'
require 'rubyjs/javascript/naming'
require 'rubyjs/javascript/runtime'
require 'rubyjs/javascript/code_generator'

require 'rubyjs/model'
require 'rubyjs/eval_into'
