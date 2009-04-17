module RubyJS; class Compiler

  require 'set'

  class LocalScope
    attr_reader :variables
    attr_reader :temporary_variables
    attr_reader :parent_scope
    attr_reader :node           # The AST node which introduced this Scope

    def initialize(node, parent_scope=nil)
      @node = node
      @parent_scope = parent_scope 
      @child_scopes = Set.new
      @parent_scope.register_child_scope(self) if @parent_scope

      @variables = Hash.new

      #
      # Each local scope maintains its own pool of temporary variables.
      # That implies that temporary variables can't be used across
      # scope-boundaries! 
      #
      @temporary_variable_pool = []
      @temporary_variable_cnt = 0
      @temporary_variables = Hash.new 
    end

    def register_child_scope(scope)
      @child_scopes.add(scope)
    end

    #
    # Returns a list of all scopes starting from +self+
    # towards the root scope.
    #
    def all_scopes_to_root
      scopes = []
      current = self
      while current
        scopes << current
        current = current.parent_scope
      end
      scopes
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
      var = @variables[name] || (@parent_scope ? @parent_scope.find_variable(name) : nil)
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
  end # class LocalScope

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
  end # class MethodScope


  class LoopControlScope
    def initialize(node)
      @node = node
    end
  end # class LoopControlScope


  class IteratorControlScope
    def initialize(node)
      @node = node
    end
  end # class IteratorControlScope

end; end # class Compiler; module RubyJS
