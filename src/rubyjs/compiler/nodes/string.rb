module RubyJS; class Compiler; class Node

  class StringLiteral < Node
    kind :str

    def args(string)
      @string = string
    end
  end

  #
  # String interpolation.
  #
  # A string containing #{ expr }.
  #
  class DynamicString < Node
    kind :dstr

    def args(string, *pieces)
      @string = string
      @pieces = pieces
    end
  end

  #
  # Represents a `...` string.
  #
  class BacktickString < Node
    kind :xstr

    def args(string)
      @string = string
    end
  end  
  
  #
  # Represents a `...` string which contains #{ expr }.
  #
  class DynamicBacktickString < Node
    kind :dxstr

    def args(string, *pieces)
      @string = string
      @pieces = pieces
    end
  end  

  #
  # A #{ ... } piece.
  #
  class EvalString < Node
    kind :evstr

    def args(expr)
      @expr = expr
    end
  end

end; end; end # class Node; class Compiler; module RubyJS
