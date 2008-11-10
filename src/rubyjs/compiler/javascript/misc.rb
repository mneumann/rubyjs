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

  class StringLiteral
    def as_javascript
      @string.inspect
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

  class Block
    def as_javascript
      raise if get(:mode) == :expression
      raise if @statements.empty?
      last_i = @statements.size - 1

      @statements.each_with_index.map {|stmt, i|
        mode = if get(:mode) == :last and i == last_i then :last else :statement end
        stmt.javascript(mode)
      }.join(";\n")
    end

    def brackets?; raise end
    def compound?; true end
  end

end; end; end # class Node; class Compiler; module RubyJS
