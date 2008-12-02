module RubyJS; class Compiler; class Node

  class Break
    def as_javascript
      "return"
    end
  end

  class While
    def as_javascript
      "while (cond) { #{ @body ? @body.javascript(:statement) : 'nil' } }"
=begin
      case get(:mode)
      when :expression
        #(function() { while (condition) { ... }; return nil })()
      when :statement
        # 
      when :last
        # while true
        #   break if blah # => convert break into return when it is a
        #   loop leaving break.
        # end
        #
        # -> need return value. 
        # tmp=nil; while (condition) {
        #   break;
        #   ...
        # }; return tmp;
      else
        raise
      end
=end
    end

    def compound?; true end
  end


  class Yield
    # TODO
    def as_javascript
      args = @arguments.map {|arg| arg.javascript(:expression)}.join(",")
      "yield(#{args})"
    end
  end

  class Iter
    def as_javascript
      set(:self => get(:alternate_self))  do
        "function() {" + @body.javascript(:last) + "}"
      end
    end

    def brackets?; true end
  end

end; end; end # class Node; class Compiler; module RubyJS
