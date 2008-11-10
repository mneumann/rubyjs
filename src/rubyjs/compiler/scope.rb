module RubyJS; class Compiler

  require 'set'

  class LocalVariable
    attr_reader :name, :scope

    def initialize(name, scope)
      @name, @scope = name, scope
    end
  end

  #
  # Local variable scope
  #
  class LocalScope
    attr_reader :node, :variables, :kind, :child_scopes

    def initialize(node, enclosing_scope=nil, kind=:method)
      @node = node
      @child_scopes = Set.new
      if @enclosing_scope = enclosing_scope
        @enclosing_scope.register_child_scope(self)
      end
      @kind = kind
      @variables = Hash.new
    end

    def register_child_scope(sc)
      @child_scopes.add(sc)
    end

    def method?
      @kind == :method
    end

    def iter?
      @kind == :iter
    end

    def find_variable(name, declare_if_not_found=false)
      name = name.to_s
      var = @variables[name] || (@enclosing_scope ? @enclosing_scope.find_variable(name) : nil)
      if declare_if_not_found and var.nil?
        declare_variable(name)
      else
        var
      end
    end

    #
    # Variables are always declared in the outer most local scope
    #
    def declare_variable(name)
      name = name.to_s
      raise if @variables[name]
      var = LocalVariable.new(name, self)
      @variables[name] = var
      return var
    end
  end
  
  #
  # Method scope used to write down called method and accessed
  # instance methods.
  #
  class MethodScope
    attr_reader :ivar_assignments, :ivar_lookups
    attr_reader :method_calls

    def initialize
      @ivar_assignments = Set.new
      @ivar_lookups = Set.new
      @method_calls = Set.new
      @super_call = false
    end

    def add_super_call
      @super_call = true
    end

    def add_method_call(m)
      @method_calls.add(m)
    end

    def add_ivar_lookup(ivar)
      @ivar_lookups.add(ivar)
    end

    def add_ivar_assignment(ivar)
      @ivar_assignments.add(ivar)
    end
  end

end; end # class Compiler; module RubyJS
