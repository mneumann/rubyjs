module RubyJS; class Compiler; class Node

  class Newline < Node
    kind :newline

    def consume(sexp)
      @compiler.set_position(sexp[0], sexp[1])
      super(sexp)
    end

    def args(line, file, child=nil)
      @line, @file, @child = line, file, child
    end

    def is?(klass)
      if @child
        @child.is?(klass)
      else
        false
      end
    end
  end
  
  #----------------------------------------------
  # Operators
  #----------------------------------------------

  class Negate < Node
    kind :negate

    def args(child)
      @child = child
    end
  end

  #----------------------------------------------
  # Special values
  #----------------------------------------------

  class True < Node
    kind :true
  end

  class False < Node
    kind :false
  end

  class Nil < Node
    kind :nil
  end

  class Self < Node
    kind :self
  end
  
  
  #----------------------------------------------
  # Literals
  #----------------------------------------------

  class Literal < Node
    kind :lit

    def normalize(value)
      case value
      when Fixnum, Float
        NumberLiteral.new_with_args(@compiler, value)
      when Regexp
        RegexLiteral.new_with_args(@compiler, value.source, value.options)
      when Range
        RangeLiteral.new_with_args(@compiler,
            NumberLiteral.new_with_args(@compiler, value.begin),
            NumberLiteral.new_with_args(@compiler, value.end),
            value.exclude_end?)
      else
        @value = value
        self
      end
    end

    attr_accessor :value
  end

  class NumberLiteral < Node
    kind :fixnum

    def args(value)
      @value = value
    end

    attr_accessor :value
  end

  class RangeLiteral < Node
    def args(start, stop, exclude_end)
      @start, @stop, @exclude_end = start, stop, exclude_end
    end

    attr_accessor :start, :stop, :exclude_end
  end

  class ArrayLiteral < Node
    kind :array

    def args(*elements)
      @elements = elements
    end

    attr_accessor :elements
  end

  class Const < Node
    kind :const

    def args(name)
      @name = name.to_s
    end
  end

  class Block < Node
    kind :block

    def args(*statements)
      @statements = statements
      @statements << Nil.new_with_args(@compiler) if @statements.empty?
    end

    attr_accessor :statements
  end

end; end; end # class Node; class Compiler; module RubyJS
