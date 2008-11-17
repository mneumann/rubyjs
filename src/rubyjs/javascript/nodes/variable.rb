module RubyJS; class Compiler; class Node

  class LVar
    def as_javascript
      get(:local_encoder).encode_local_variable(@variable.name)
    end
  end

  class LAsgn
    def as_javascript
      get(:local_encoder).encode_local_variable(@variable.name) + " = " + @expr.javascript(:expression)
    end

    def brackets?; true end
  end

  class IVar
    def as_javascript
      get(:method_scope).add_ivar_lookup(@name)
      # TODO: use "self" in iterator
      "this." + get(:encoder).encode_instance_variable(@name)
    end
  end

  class IAsgn
    def as_javascript
      get(:method_scope).add_ivar_assignment(@name)
      # TODO: use "self" in iterator
      "this." + get(:encoder).encode_instance_variable(@name) + " = " + @expr.javascript(:expression)
    end

    def brackets?; true end
  end

end; end; end # class Node; class Compiler; module RubyJS
