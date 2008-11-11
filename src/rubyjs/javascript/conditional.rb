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
      @left.javascript + "&&" + @right.javascript
=begin
      #(t1=a;  
      #t = a;
      #if (T(t)) b; else t;

      #
      #@local_variables_need_no_initialization.add(tmp)
      #"(#{tmp}=#{process(a)}, (#{tmp}!==false&&#{tmp}!==nil) ? (#{process(b)}) : #{tmp})"

      cond = conditionalize(@left)

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
=end
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
  #       a
  #     else
  #       b
  #     end
  #
  class Or
    def as_javascript
      @left.javascript + "||" + @right.javascript
    end
  end

  class Not
    def as_javascript
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
