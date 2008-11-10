module RubyJS; class Compiler; class Node

  class StringLiteral
    def as_javascript
      @string.inspect
    end
  end

  class DynamicString
    #
    # We optimize empty StringLiterals away and do a further
    # optimization for the "#{...}" case.
    #
    def as_javascript
      pieces = @pieces.reject {|piece| piece.is(StringLiteral) and piece.string.empty? }.
        map {|piece| piece.javascript(:expression) }

      case pieces.size
      when 0
        raise
      when 1
        pieces.first
      else
        "[" + pieces.join(",") + "].join('')"
      end
    end
  end

  #
  # In RubyJS the backtick string literals are used to insert inline
  # Javascript into the generated Javascript code.
  #
  class BacktickString
    def as_javascript
      @string
    end
  end

  class EvalString
    def as_javascript
      "(" + @expr.javascript(:expression) + ").to_s()"
    end
  end

end; end; end # class Node; class Compiler; module RubyJS
