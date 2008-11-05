require 'compiler'
require 'node'
require 'nodes'
require 'javascript'

require 'rubygems'
require 'parse_tree'
require 'unified_ruby'

sexp = Unifier.new.process(*ParseTree.new.parse_tree_for_string("def test() 1+2 end"))
p sexp
node = Compiler.new.sexp_to_node(sexp)
puts node.javascript
