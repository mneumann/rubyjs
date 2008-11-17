module RubyJS; class Compiler; class Node

  #
  # Local variable assignment
  #
  class LAsgn < Node
    kind :lasgn

    def args(name, expr)
      @variable = get(:scope).find_variable(name, true) || raise("Undefined variable #{name}")
      @expr = expr
    end
  end

  #
  # Local variable lookup
  #
  class LVar < Node
    kind :lvar

    def args(name)
      @variable = get(:scope).find_variable(name) || raise("Undefined variable #{name}")
    end
  end

  #
  # Global variable lookup
  #
  class GVar < Node
    kind :gvar

    def args(name)
      @name = name
    end
  end

  #
  # Global variable assignment
  #
  class GAsgn < Node
    kind :gasgn

    def args(name, expr)
      @name, @expr = name, expr
    end
  end

  #
  # Instance variable lookup
  #
  class IVar < Node
    kind :ivar

    def args(name)
      @name = name.to_s
    end
  end

  #
  # Instance variable assignment
  #
  class IAsgn < Node
    kind :iasgn

    def args(name, expr)
      @name, @expr = name.to_s, expr
    end
  end
  
  #
  # Multiple assignment
  #
  # Simple case:
  #
  # a, b = 1, 2
  #
  # [:masgn,
  #  [:array, [:lasgn, :a], [:lasgn, :b]],
  #  [:array, [:lit, 1], [:lit, 2]]]]]]
  #
  # Case with splat argument:
  #
  # a, *b = 1, 2, 3
  #
  # [:masgn,
  #  [:array, [:lasgn, :a]],
  #  [:lasgn, :b],
  #  [:array, [:lit, 1], [:lit, 2], [:lit, 3]]]]]]
  #
  # Another case:
  #
  # a, b = 1
  #
  # [:masgn,
  #  [:array, [:lasgn, :a], [:lasgn, :b]],
  #  [:to_ary, [:lit, 1]]]
  #
  class MAsgn < Node
    kind :masgn

    #
    # The last argument always contains the values.
    #
    def args(assignment, *rest)
      @values = []
      if last = rest.pop
        @values << last
      end
      @assignments = [assignment] + rest
    end

    attr_accessor :assignments, :values 
  end

end; end; end # class Node; class Compiler; module RubyJS
