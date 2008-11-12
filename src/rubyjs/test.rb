require 'pp'
require 'rubygems'
gem 'ParseTree', '> 3.0.0'

$LOAD_PATH.unshift ".."
require 'rubyjs'

RubyJS.eval_into(RubyJS::Environment, [File.expand_path("..")]) {
  require 'rubyjs/example'
}

require 'set'
require 'rubyjs/javascript/naming'

all_methods = Set.new

world = RubyJS::WorldModel.new
world.register_all_entities!

world.entity_models_sorted.each {|model|
  (model.cmethods.values + model.imethods.values).each do |meth|
    meth.node = RubyJS::Compiler.new.sexp_to_node(meth.sexp)

    #all_methods += node.method_scope.method_calls

    #puts node.javascript

    #pp node
    #pp node.scope
    #pp node.method_scope
    #puts node.javascript
    #p node.method_scope
    #p node.scope.variables.values.map{|n| n.name}
  end

}

encoder = RubyJS::JavascriptNameEncoder.new

world.entity_models_sorted.each {|model|
  (model.cmethods.values + model.imethods.values).each do |meth|
    meth.node.set(:encoder => encoder)
    puts meth.node.javascript
  end
}
