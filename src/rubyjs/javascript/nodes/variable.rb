module RubyJS; class Compiler; class Node

  class LVar
    def as_javascript
      encode(@variable)
    end
  end

  class LAsgn
    def as_javascript
      encode(@variable) + " = " + @expr.javascript(:expression)
    end

    def brackets?; true end
  end

  class IVar
    def as_javascript
      get(:method_scope).add_ivar_lookup(@variable.name)
      # TODO: use "self" in iterator
      "this." + encode(@variable)
    end
  end

  class IAsgn
    def as_javascript
      get(:method_scope).add_ivar_assignment(@variable.name)
      # TODO: use "self" in iterator
      "this." + encode(@variable) + " = " + @expr.javascript(:expression)
    end

    def brackets?; true end
  end

  class MAsgn
    # TODO
    def as_javascript
      'TODO'
    end
  end

end; end; end # class Node; class Compiler; module RubyJS
