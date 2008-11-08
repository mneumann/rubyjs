require 'rubygems'
require 'pp'

require 'compiler'
require 'node'
require 'nodes'
require 'javascript'
require 'model'

module RubyJS
  module Environment
    class Object
    end

    class Array < Object
      def self.x
      end

      def hallo
        if true
          1
        else
          3
        end
      end

      def super
        @a = "hallo"
      end
      def test(a,b=1,c=4, *all, &block) a + 1; loop do c = 1 end end
    end

  end
end

world = RubyJS::WorldModel.new
model = world.lookup(RubyJS::Environment::Array)

(model.cmethods.values + model.imethods.values).each do |meth|
  node = RubyJS::Compiler.new.sexp_to_node(meth.sexp)
  puts node.javascript(false)
  #p node.method_scope
  #p node.scope.variables.values.map{|n| n.name}
end
