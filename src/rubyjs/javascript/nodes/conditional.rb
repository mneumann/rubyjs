module RubyJS; class Compiler; class Node

  #
  # The expression
  #
  #     a and b
  #
  # is equivalent to 
  #   
  #     if tmp = a 
  #       b
  #     else
  #       tmp 
  #     end
  #
  class And
    def as_javascript
      @scope.with_temporary_variable {|temp_var|
        tmp = get(:local_encoder).encode_temporary_variable(temp_var.name)
        left = @left.javascript(:expression)
        right = @right.javascript(:expression)
        "(#{tmp}=(#{left}),(#{cond_is(tmp, true)})?(#{right}):#{tmp})"
      }
    end
  end

  #
  # The expression
  #
  #     a or b
  #
  # is equivalent to
  #
  #     if tmp = a
  #       tmp 
  #     else
  #       b
  #     end
  #
  class Or
    def as_javascript
      @scope.with_temporary_variable {|temp_var|
        tmp = get(:local_encoder).encode_temporary_variable(temp_var.name)
        left = @left.javascript(:expression)
        right = @right.javascript(:expression)
        "(#{tmp}=(#{left}),(#{cond_is(tmp, true)})?(#{tmp}):#{right})"
      }
    end
  end

  class Not
    def as_javascript
      @scope.with_temporary_variable {|temp_var|
        tmp = get(:local_encoder).encode_temporary_variable(temp_var.name)
        child = @child.javascript(:expression)
        "(#{tmp}=(#{child}),#{cond_is(tmp, false)})"
      }
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
  end

end; end; end # class Node; class Compiler; module RubyJS
