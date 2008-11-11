module RubyJS; class Compiler; class Node

  class RegexLiteral < Node
    kind :regex

    def args(source, options)
      @source, @options = source, options
    end

    attr_accessor :source, :options
  end

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

  class BackRef < Node
    kind :back_ref

    def args(kind)
      @kind = kind.chr.to_sym
    end

    attr_accessor :kind
  end

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

end; end; end # class Node; class Compiler; module RubyJS
