require 'compiler'
require 'node'
require 'nodes'
require 'javascript'

require 'rubygems'
require 'unified_ruby'
require 'method_extractor'

require 'pp'

class A
  def self.x
  end
  def hallo
  end
  def super
  end
  def test(a,b=1,c=4, *all, &block) a + 1; loop do c = 1 end end
end

methods = MethodExtractor.from_class(A)

methods[:class].each do |name, sexp|
  node = Compiler.new.sexp_to_node(sexp)
  puts node.javascript
end

methods[:instance].each do |name, sexp|
  node = Compiler.new.sexp_to_node(sexp)
  puts node.javascript
end
