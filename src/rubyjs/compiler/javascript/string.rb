module RubyJS; class Compiler; class Node

  class StringLiteral
    def as_javascript
      @string.inspect
    end
  end

end; end; end # class Node; class Compiler; module RubyJS
