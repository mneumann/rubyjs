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

    def is(klass)
      if @child
        @child.is(klass)
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

  class RegexLiteral < Node
    kind :regex

    def args(source, options)
      @source, @options = source, options
    end

    attr_accessor :source, :options
  end

  class RangeLiteral < Node
    def args(start, stop, exclude_end)
      @start, @stop, @exclude_end = start, stop, exclude_end
    end

    attr_accessor :start, :stop, :exclude_end
  end

  class StringLiteral < Node
    kind :str

    def args(str)
      @string = str
    end

    attr_accessor :string
  end

  class ArrayLiteral < Node
    kind :array

    def args(*elements)
      @elements = elements
    end

    attr_accessor :elements
  end

  #----------------------------------------------
  # Dynamic Literals
  #----------------------------------------------

  class DynamicString < Node
    kind :dstr

    def args(str, *pieces)
      @string = str
      @pieces = pieces
    end

    attr_accessor :string, :pieces
  end

  #----------------------------------------------
  # Regular Expressions
  #----------------------------------------------

  class DynamicRegex < Node
    kind :dregx

    def args(str, *pieces)
      @string = str
      @pieces = pieces
      if pieces.last.kind_of?(Fixnum)
        @options = pieces.pop
      else
        @options = 0
      end
    end

    attr_accessor :string, :pieces
  end

  class DynamicOnceRegex < DynamicRegex
    kind :dregx_once
  end

  # 
  # A regular expression match. For example:
  #
  #   /regexp/ =~ a
  #
  # is converted to 
  #
  #   [:match2, [:lit, /regexp/], [:lvar, :a]]
  #
  class Match2 < Node
    kind :match2

    #def normalize(pattern, target)
    #  Call.new_with_args(@compiler, pattern, :=~, ArrayLiteral.new_with_args(@compiler, target))
    #end

    def args(pattern, target)
      @pattern, @target = pattern, target
    end

    attr_accessor :pattern, :target
  end

  # 
  # A regular expression match. For example:
  #
  #   a =~ /regexp/
  #
  # is converted to 
  #
  #   [:match3, [:lit, /regexp/], [:lvar, :a]]
  #
  class Match3 < Node
    kind :match3

    def args(pattern, target)
      @pattern, @target = pattern, target
    end

    attr_accessor :target, :pattern
  end

=begin
  class BackRef < Node
    kind :back_ref

    def args(kind)
      @kind = kind.chr.to_sym
    end

    attr_accessor :kind
  end
=end

  #
  # Regular expression lookup $1 .. $9
  #
  class NthRef < Node
    kind :nth_ref

    def args(n)
      raise Error, "NthRef: out of bounds" if n < 1 or n > 9
      @n = n
    end

    attr_accessor :n
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
