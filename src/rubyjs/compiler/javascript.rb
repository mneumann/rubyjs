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

      def javascript(as_expression=nil)
        "true"
      end
    end

    class False
      def brackets?() false end

      def javascript(as_expression=nil)
        "false"
      end
    end

    class Nil
      def brackets?() false end

      def javascript(as_expression=nil)
        "nil"
      end
    end

    class NumberLiteral
      def brackets?() true end

      def javascript(as_expression=nil)
        @value.to_s
      end
    end

    class StringLiteral
      def brackets?() false end

      def javascript(as_expression=nil)
        @string.inspect
      end
    end

    #
    # TODO: Need to replace +this+ with "self" when inside an iterator.
    #
    class Self
      def brackets?() false end

      def javascript(as_expression=nil)
        "this"
      end
    end

    class If
      def brackets?
        false
      end

      def javascript(as_expression=nil)
        cond = @condition.javascript(true)
        th = @then.javascript(as_expression)
        el = @else.javascript(as_expression)

        if as_expression
          "(#{cond} ? #{th} : #{el})"
        else
          "if (#{cond}) {\n#{th}\n} else {\n#{el}\n}"
        end
      end
    end

    class Block
      def brackets?() raise end

      def javascript(as_expression=false)
        raise if as_expression
        @statements.map {|s| s.javascript(as_expression) + ";"}.join("\n")
      end
    end

    class ArgList
      def brackets?() raise end

      def javascript(as_expression=true)
        #raise unless as_expression
        @elements.map {|e| e.javascript(as_expression)}.join(", ")
      end
    end

    class MethodCall
      def brackets?() false end

      def javascript(as_expression=nil)
        fmt = @receiver.brackets? ? "(%s).%s(%s)" : "%s.%s(%s)"
        fmt % [@receiver.javascript(true), @method_name.to_s, @arguments.javascript(true)] 
      end
    end

    class Scope
      def javascript(as_expression=nil)
        @body.javascript(as_expression)
      end
    end

    class DefineMethod
      def javascript(as_expression=false)
        raise if as_expression

        args = @arguments.javascript_arglist
        opt = @arguments.javascript_optional
        "function #{@method_name}(#{args}){\n" +
          (opt ? opt + ";" : "") + 
          @body.javascript(as_expression) + "}"
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

      def javascript_optional(as_expression=false)
        raise if as_expression
        return nil unless @optional

        "switch(arguments.length) {\n" + 
        @optional.statements.each_with_index.map {|opt, i|
          "case #{self.min_arity+i}: #{opt.javascript(as_expression)};"
        }.join("\n") + 
        "}\n"
      end
    end

    class LVar
      def brackets?() false end

      def javascript(as_expression=nil)
        "#{@variable.name}"
      end
    end

    class LAsgn
      def javascript(as_expression=nil)
        "#{@variable.name} = #{@expr.javascript(true)}"
      end
    end

    class IVar
      def brackets?() false end

      def javascript(as_expression=nil)
        "#{@name}"
      end
    end

    class IAsgn
      def javascript(as_expression=nil)
        "#{@name} = #{@expr.javascript(true)}"
      end
    end


    class Iter
      def javascript(as_expression=nil)
        "function() {\n" +
        @body.javascript(false) +
        "};" #+ 
        # FIXME
        #@method_call.javascript(as_expression)
      end
    end

  end; end # class Node; class Compiler

end # module RubyJS
