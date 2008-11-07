module RubyJS

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
        args = @arguments.javascript_arglist
        opt = @arguments.javascript_optional
        "function #{@method_name}(#{args}){\n" +
          (opt ? opt + ";" : "") + 
          @body.javascript + "}"   
      end
    end

    class Args
      def javascript_arglist
        args = @arguments 
        if @block and not @catch_all
          args += ["_", @block]
        end
        args.join(", ")
      end

      def javascript_optional
        return nil unless @optional

        "switch(arguments.length) {\n" + 
        @optional.statements.each_with_index.map {|opt, i|
          "case #{self.min_arity+i}: #{opt.javascript};"
        }.join("\n") + 
        "}\n"
      end
    end

    class LVar
      def brackets?() false end

      def javascript
        "#{@variable.name}"
      end
    end

    class LAsgn
      def javascript
        "#{@variable.name} = #{@expr.javascript}"
      end
    end

    class Iter
      def javascript
        "function() {\n" +
        @body.javascript +
        "};" + 
        @method_call.javascript
      end
    end

  end; end # class Node; class Compiler

end # module RubyJS
