require 'pp'
require 'rubygems'
gem 'ParseTree', '> 3.0.0'

$LOAD_PATH.unshift ".."
require 'rubyjs'

RubyJS.eval_into(RubyJS::Environment, [File.expand_path("..")]) {
  require 'rubyjs/example'
}

world = RubyJS::WorldModel.new
model = world.lookup(RubyJS::Environment::Array)

(model.cmethods.values + model.imethods.values).each do |meth|
  node = RubyJS::Compiler.new.sexp_to_node(meth.sexp)
  pp node
  puts node.javascript
  #p node.method_scope
  #p node.scope.variables.values.map{|n| n.name}
end
