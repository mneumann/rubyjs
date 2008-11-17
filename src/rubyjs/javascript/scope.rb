module RubyJS; class Compiler

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
