require 'rubygems'
gem 'ParseTree', '> 3.0.0'

$LOAD_PATH.unshift ".."

require 'pp'

require 'rubyjs/compiler'
require 'rubyjs/scope'
require 'rubyjs/node'
require 'rubyjs/nodes'
require 'rubyjs/javascript'
require 'rubyjs/model'
require 'rubyjs/rewrites'

module RubyJS
  module Environment
    class Object
    end

    class Array < Object
      def hallo
        a = 1
        a ||= 4
        a &&= 5
      end

=begin
      def super
        @a = "hallo"
      end
      def test(a,b=1,c=4, *all, &block) a + 1; loop do c = 1 end end
=end
    end

  end
end

world = RubyJS::WorldModel.new
model = world.lookup(RubyJS::Environment::Array)

(model.cmethods.values + model.imethods.values).each do |meth|
  node = RubyJS::Compiler.new.sexp_to_node(meth.sexp)
  pp node
  puts node.javascript
  #p node.method_scope
  #p node.scope.variables.values.map{|n| n.name}
end
