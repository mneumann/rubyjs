module RubyJS; class Compiler; class Node

  class Newline
    def javascript(*args)
      @child.javascript(*args)
    end
  end

  class Negate
    def as_javascript
    end
  end

  class True
    def as_javascript
      "true"
    end
  end

  class False
    def as_javascript
      "false"
    end
  end

  class Nil
    def as_javascript
      "nil"
    end
  end

  class NumberLiteral
    def as_javascript
      @value.to_s
    end

    def brackets?; true end
  end

  class SymbolLiteral
    def as_javascript
      @value.to_s
    end
  end

  class ArrayLiteral
    def as_javascript
      "[" + @elements.map {|elem| elem.javascript(:expression)}.join(", ") + "]"
    end
  end

  #
  # TODO: Need to replace +this+ with "self" when inside an iterator.
  #
  class Self
    def as_javascript
      "this"
    end
  end

  # XXX
  class Const
    def as_javascript
      @name
    end
  end

  class Splat
    # TODO
    def as_javascript
      'TODO'
    end
  end


  class Block
    def as_javascript
      raise if @statements.empty?
      last_i = @statements.size - 1

      case get(:mode)
      when :expression
        @statements.each_with_index.map {|stmt, i|
          stmt.javascript
        }.join(", ")
      else
        @statements.each_with_index.map {|stmt, i|
          mode = if get(:mode) == :last and i == last_i then :last else :statement end
          stmt.javascript(mode)
        }.join(";\n")
      end
    end

    def brackets?; raise end
    def compound?; true end
  end


end; end; end # class Node; class Compiler; module RubyJS
