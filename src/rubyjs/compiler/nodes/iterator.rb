module RubyJS; class Compiler; class Node

  # TODO: For-loop
  
  class Loop < Node
    def consume(sexp)
      set(:control_scope => LoopControlScope.new(self)) do
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

  class LoopOrIteratorControl < Node
    attr_reader :control_scope

    def args(argument=nil)
      @control_scope = get(:control_scope)
      @argument = argument
    end
  end

  class Break < LoopOrIteratorControl
    kind :break
  end

  class Next < LoopOrIteratorControl 
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

    def consume(sexp)
      method_call, *rest = *sexp

      res = super([method_call]) 
      raise if res.size != 1
      # append Iter to ArgumentList
      res.first.arguments << self

      @local_scope = LocalScope.new(self, @local_scope)
      control_scope = IteratorControlScope.new(self)
      set(:control_scope => control_scope, :local_scope => @local_scope) { res.push(*super(rest)) }

      return res
    end

    def normalize(method_call, block_assignment, body=nil)
      @method_call, @block_assignment, @body = method_call, block_assignment, expand_nil(body)
      return @method_call
    end
  end

end; end; end # class Node; class Compiler; module RubyJS
