module RubyJS

  class Compiler; class Node

    #
    # Needs this node to be bracketized when used as receiver?
    # By default, no.
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
      false
    end

    #
    # Compound statements have special behaviour in case of 
    # <tt>get(:mode) == :last</tt>, in that they pass the mode 
    # further to their sub-statements instead of generating 
    # a "return" on their own.
    #
    def compound?
      false
    end

    #
    # External function to generate javascript of a Node.
    #
    # Calls method <tt>as_javascript</tt> internally, but
    # might take special actions (e.g. surround the output).
    #
    def javascript(mode=nil)
      raise ArgumentError unless [nil, :expression, :statement, :last].include?(mode)
      h = {}
      h[:mode] = mode if mode != nil
      set(h) {
        if get(:mode) == :last and !compound?
          "return (" + as_javascript + ")"
        else
          as_javascript
        end
      }
    end

    def as_javascript; raise end

    protected :as_javascript

    #----------------------------------------------
    # Nodes
    #----------------------------------------------

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

    class If
      def as_javascript
        s1, s2 = @then, @else
        negate = false
        if s1.nil?
          s1, s2 = s2, s1
          negate = true
        end

        if s1.nil?
          #
          # This is a very special case in which both "then" and "else"
          # parts are missing. For example:
          #
          #   if true
          #   end
          #
          # Or
          #
          #   if true
          #   else
          #   end
          #
          # What we do is, to evalute the condition (as it might include
          # side-effects) and return "nil".
          #
          case get(:mode)
          when :expression
            return "(#{@condition.javascript(:expression)},nil)" 
          when :statement
            return "#{@condition.javascript(:expression)}" 
          when :last
            return "#{@condition.javascript(:expression)}; return nil" 
          else
            raise
          end
        end
          
        cond = conditionalize(@condition, negate)

        if get(:mode) == :expression
          #
          # In an expression, we always need the "then" and the "else"
          # part!
          #
          # If the "else" part is missing, replace it with "nil".
          #
          "(#{cond} ? #{s1.javascript} : #{s2 ? s2.javascript : 'nil'})"
        else
          "if (#{cond}) {\n#{s1.javascript}\n}" + 
          if s2
            " else {\n#{s2.javascript}\n}" 
          elsif get(:mode) == :last
            #
            # In case this is the last statement, and the else
            # part is missing, generate one.
            #
            " else {return nil}"
          else
            ""
          end
        end
      end

      def compound?; true end

      protected

      #
      # We do some minor optimizations if we face
      # some literal values where we already know
      # the outcome.
      #
      def conditionalize(cond, negate=false)
        case cond
        when Nil, False
          negate ? "true" : "false"
        when True, StringLiteral, NumberLiteral #...
          negate ? "false" : "true"
        else
          str = cond.javascript(:expression)
          tmp = "t1" # TODO: need temporary variable!!!
          if negate
            "(#{tmp}=(#{str}),#{tmp}===false||#{tmp}===nil)"
          else
            "(#{tmp}=(#{str}),#{tmp}!==false&&#{tmp}!==nil)"
          end
        end
      end
    end

    class Block
      def as_javascript
        raise if get(:mode) == :expression
        raise if @statements.empty?
        last_i = @statements.size - 1

        @statements.each_with_index.map {|stmt, i|
          mode = if get(:mode) == :last and i == last_i then :last else :statement end
          stmt.javascript()
        }.join(";\n")
      end

      def brackets?; raise end
      def compound?; true end
    end

    class ArgList
      def as_javascript
        raise if get(:mode) != :expression
        @elements.map {|e| e.javascript }.join(", ")
      end

      def brackets?; raise end
    end

    class MethodCall
      def as_javascript
        fmt = @receiver.brackets? ? "(%s).%s(%s)" : "%s.%s(%s)"
        fmt % [
          @receiver.javascript(:expression),
          @method_name.to_s,
          @arguments.javascript(:expression)
        ]
      end
    end

    class Scope
      def as_javascript
        @body.javascript
      end

      def brackets?; raise end
      def compound?; true end
    end

    class DefineMethod
      def as_javascript
        raise if get(:mode) == :expression

        args = @arguments.javascript_arglist
        opt = @arguments.javascript_optional
        "function #{@method_name}(#{args}){\n" +
          (opt ? opt + ";" : "") + @body.javascript(:last) + "}"
      end

      def brackets?; raise end
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
          "case #{self.min_arity+i}: #{opt.javascript(:statement)};"
        }.join("\n") + "}\n"
      end

      def brackets?; raise end
    end

    class LVar
      def as_javascript
        "#{@variable.name}"
      end
    end

    class LAsgn
      def as_javascript
        "#{@variable.name} = #{@expr.javascript(:expression)}"
      end

      def brackets?; true end
    end

    class IVar
      def as_javascript
        "#{@name}"
      end
    end

    class IAsgn
      def as_javascript
        "#{@name} = #{@expr.javascript(:expression)}"
      end

      def brackets?; true end
    end


    #
    # TODO
    #
    class Iter
      def as_javascript
        "function() {\n" +
        @body.javascript(:last) +
        "};" #+ 
        # FIXME
        #@method_call.javascript(as_expression)
      end

      def brackets?; true end
    end

  end; end # class Node; class Compiler

end # module RubyJS
