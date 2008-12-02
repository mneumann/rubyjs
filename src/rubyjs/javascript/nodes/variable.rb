module RubyJS; class Compiler; class Node

  class LVar
    def as_javascript
      @variable.encode(self.encoder)
    end
  end

  class LAsgn
    def as_javascript
      @variable.encode(self.encoder) + " = " + @expr.javascript(:expression)
    end

    def brackets?; true end
  end

  class IVar
    def as_javascript
      get(:method_scope).add_ivar_lookup(@variable.name)
      # TODO: use "self" in iterator
      "this." + @variable.encode(self.encoder)
    end
  end

  class IAsgn
    def as_javascript
      get(:method_scope).add_ivar_assignment(@variable.name)
      # TODO: use "self" in iterator
      "this." + @variable.encode(self.encoder) + " = " + @expr.javascript(:expression)
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
