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
      end
      def super
      end
      def test(a,b=1,c=4, *all, &block) a + 1; loop do c = 1 end end
    end

  end
end

model =  RubyJS::EntityModel.of(RubyJS::Environment::Array)
model.cmethods.each do |name, sexp|
  node = RubyJS::Compiler.new.sexp_to_node(sexp)
  puts node.javascript
end
model.imethods.each do |name, sexp|
  node = RubyJS::Compiler.new.sexp_to_node(sexp)
  puts node.javascript
end
