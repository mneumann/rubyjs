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
      pieces = @pieces.reject {|piece| piece.is?(StringLiteral) and piece.string.empty? }.
        map {|piece| 
          str = piece.javascript(:expression)
          if piece.is?(EvalString)
            "(#{str}).to_s()"
          else
            str
          end
        }

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

    def brackets?; true end
  end

  #
  # A backtick string (inline Javascript) which contains Ruby expressions. 
  #
  class DynamicBacktickString
    def as_javascript
      @pieces.map {|piece|
        if piece.is?(StringLiteral)
          piece.string
        else
          piece.javascript(:expression)
        end
      }.join("")
    end

    def brackets?; true end
  end

  #
  # This is the #{xxx} expression which occurs within a String literal.
  #
  # The real Javascript generation takes place in the parent nodes
  # (DynamicString, DynamicBacktickString).
  #
  class EvalString
    def as_javascript
      @expr.javascript(:expression)
    end
  end

end; end; end # class Node; class Compiler; module RubyJS
