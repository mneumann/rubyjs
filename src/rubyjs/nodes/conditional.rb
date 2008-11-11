module RubyJS; class Compiler; class Node

  #
  # The "&&" or "and" operator.
  #
  # Short-circuit behaviour.
  #
  class And < Node 
    kind :and

    def args(left, right)
      @left, @right = left, right
    end
  end

  #
  # The "||" or "or" operator.
  #
  # Short-circuit behaviour.
  #
  class Or < Node
    kind :or

    def args(left, right)
      @left, @right = left, right
    end
  end

  #
  # The "!" or "not" operator.
  #
  class Not < Node
    kind :not

    def args(child)
      @child = child
    end
  end

  class If < Node
    kind :if

    def args(cond, _then, _else)
      @condition, @then, @else = cond, expand_nil(_then), expand_nil(_else)
    end
  end

  class Case < Node
    kind :case

    def args(cond, *clauses)
      @condition = cond
      @when_clauses = clauses
      @else_clause = clauses.pop
    end
  end 

  class When < Node
    kind :when

    def args(compare_list, body)
      @compare_list, @body = compare_list, expand_nil(body) 

      if @compare_list.is?(ArrayLiteral)
        @compare_list = @compare_list.elements
      else
        raise
      end
    end
  end

end; end; end # class Node; class Compiler; module RubyJS
