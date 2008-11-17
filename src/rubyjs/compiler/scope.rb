module RubyJS; class Compiler

  require 'set'

  class LocalVariable
    attr_reader :name, :scope

    def initialize(name, scope)
      @name, @scope = name, scope
    end
  end

  class TemporaryVariable < LocalVariable
  end

  #
  # Local variable scope
  #
  class LocalScope
    attr_reader :node, :variables, :kind, :child_scopes
    attr_reader :temporary_variables

    def initialize(node, enclosing_scope=nil, kind=:method)
      @node = node
      @child_scopes = Set.new
      if @enclosing_scope = enclosing_scope
        @enclosing_scope.register_child_scope(self)
      end
      @kind = kind
      @variables = Hash.new

      #
      # Each scope maintains its own pool of temporary variables. That
      # implies that temporary variables can't be used across
      # scope-boundaries! 
      #
      @temporary_variable_pool = []
      @temporary_variable_cnt = 0
      @temporary_variables = Hash.new 
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

    #
    # Gets a temporary variable either from the temporary variable pool
    # or create a new temporary variable within the current scope.
    #
    # The name of a TemporaryVariable is just a per-scope unique number.
    #
    def get_temporary_variable(&block)
      temp_var = @temporary_variable_pool.shift || 
        TemporaryVariable.new((@temporary_variable_cnt += 1).to_s, self)

      @temporary_variables[temp_var.name] = temp_var 

      return temp_var
    end

    #
    # Puts a temporary variable back into the pool of available
    # temporary variables for the purpose of reuse. 
    #
    def put_temporary_variable(temp_var)
      raise ArgumentError unless temp_var.is_a?(TemporaryVariable)
      raise ArgumentError unless @temporary_variables.include?(temp_var.name)
      @temporary_variable_pool.unshift(temp_var)
    end

    #
    # Calls the block with a usable temporary variable and automatically
    # put it back to the pool once the block finishes its execution.
    #
    def with_temporary_variable
      temp_var = get_temporary_variable
      begin
        yield temp_var
      ensure
        put_temporary_variable(temp_var)
      end
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

    def all_variables_recursive(&block)
      @variables.each_value(&block)
      @child_scopes.each {|cs|
        cs.all_variables_recursive(&block)
      }
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

end; end # class Compiler; module RubyJS
