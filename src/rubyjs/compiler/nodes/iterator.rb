module RubyJS; class Compiler; class Node

  # TODO: For-loop
  
  class Loop < Node
    def consume(sexp)
      set(:iterator_scope => self) do
        super(sexp)
      end
    end

    def args(cond, body, check_first=true)
      @condition, @body, @check_first = cond, body, check_first
    end
  end

  class While < Loop
    kind :while
  end

  class Until < Loop
    kind :until
  end

  class IteratorControl < Node
    def args(argument=nil)
      @iterator_scope = get(:iterator_scope) || raise("#{kind()} allowed only in loop or iterator") 
      @argument = argument
    end
  end

  class Break < IteratorControl
    kind :break
  end

  class Next < IteratorControl 
    kind :next
  end

  class Yield < Node
    kind :yield

    def args(*arguments)
      @arguments = arguments
    end
  end

  class Iter < Node
    kind :iter

    def initialize(compiler)
      super(compiler)
      @scope = LocalScope.new(self, @scope, :iter)
    end

    def consume(sexp)
      method_call, *rest = *sexp

      res = super([method_call]) 
      raise if res.size != 1
      res.first.iter = self 

      set(:iterator_scope => self, :scope => @scope) { res.push(*super(rest)) }
      return res
    end

    def args(method_call, block_assignment, body=nil)
      @method_call, @block_assignment, @body = method_call, block_assignment, expand_nil(body)
    end
  end

end; end; end # class Node; class Compiler; module RubyJS
