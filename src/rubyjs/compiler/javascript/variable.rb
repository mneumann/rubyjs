module RubyJS; class Compiler; class Node

  class LVar
    def as_javascript
      "#{@variable.name}"
    end
  end

  class LAsgn
    def as_javascript
      "#{@variable.name} = #{@expr.javascript(:expression)}"
    end

    def brackets?; true end
  end

  class IVar
    def as_javascript
      "#{@name}"
    end
  end

  class IAsgn
    def as_javascript
      "#{@name} = #{@expr.javascript(:expression)}"
    end

    def brackets?; true end
  end

end; end; end # class Node; class Compiler; module RubyJS
