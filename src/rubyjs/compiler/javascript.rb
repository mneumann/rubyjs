class Compiler; class Node

  #
  # Needs this node to be bracketized when used as receiver?
  # By default, yes.
  #
  # Examples: 
  #
  #   A number as receiver needs to be bracketized
  #
  #       8.to_s -> (8).to_s
  #
  #   A boolean needs not
  #
  #       true.to_s -> true.to_s
  #
  def brackets?
    true
  end

  #----------------------------------------------
  # Nodes
  #----------------------------------------------

  class True
    def brackets?() false end

    def javascript() "true" end
  end

  class False
    def brackets?() false end

    def javascript() "false" end
  end

  class Nil
    def brackets?() false end

    def javascript() "nil" end
  end

  class NumberLiteral
    def brackets?() true end

    def javascript
      @value.to_s
    end
  end

  #
  # TODO: Need to replace +this+ with "self" when inside an iterator.
  #
  class Self
    def brackets?() false end

    def javascript() "this" end
  end

  class Block
    def brackets?() raise end

    def javascript
      @statements.map {|s| s.javascript}.join(";")
    end
  end

  class ArgList
    def brackets?() raise end

    def javascript
      @elements.map {|e| e.javascript}.join(", ")
    end
  end

  class MethodCall
    def brackets?() false end

    def javascript
      fmt = @receiver.brackets? ? "(%s).%s(%s)" : "%s.%s(%s)"
      fmt % [@receiver.javascript, @method_name.to_s, @arguments.javascript] 
    end
  end

  class Scope
    def javascript
      @body.javascript
    end
  end

  class DefineMethod
    def javascript
      "function #{@method_name}() {" + @body.javascript + "}"   
    end
  end

  class Args
    def javascript
      nil
    end
  end

end; end # class Node; class Compiler
