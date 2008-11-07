require 'compiler'
require 'node'
require 'nodes'
require 'javascript'

require 'rubygems'
require 'parse_tree'
require 'unified_ruby'

require 'pp'

sexp = Unifier.new.process(*ParseTree.new.parse_tree_for_string("def test(a,b=1,c=4, *all, &block) a + 1; loop do c = 1 end end"))
pp sexp
node = Compiler.new.sexp_to_node(sexp)
puts node.javascript
