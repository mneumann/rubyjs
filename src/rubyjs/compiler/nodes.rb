#
# Subclasses of Node
#

class Compiler; class Node
  
  class Newline < Node
    kind :newline

    def consume(sexp)
      @compiler.set_position(sexp[0], sexp[1])
      super
    end

    def args(line, file, child=nil)
      @line, @file, @child = line, file, child
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
  # Operators
  #----------------------------------------------

  class UnaryOp < Node
    attr_accessor :child

    def args(child)
      @child = child
    end
  end

  class BinaryOp < Node
    attr_accessor :left, :right

    def args(left, right)
      @left, @right = left, right
    end
  end

  #
  # The "&&" or "and" operator.
  #
  class And < BinaryOp
    kind :and
  end

  #
  # The "||" or "or" operator.
  #
  class Or < BinaryOp
    kind :or
  end

  #
  # The "!" or "not" operator.
  #
  class Not < UnaryOp
    kind :not
  end

  class Negate < UnaryOp
    kind :negate
  end
  
  #----------------------------------------------
  # Literals
  #----------------------------------------------

  class NumberLiteral < Node
    kind :fixnum

    def args(value)
      @value = value
    end

    attr_accessor :value
  end

  class Literal < Node
    kind :lit

    def normalize(value)
      case value
      when Fixnum
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

  class EmptyArrayLiteral < Node
    kind :zarray

    def normalize
      ArrayLiteral.new_with_args(@compiler)
    end
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
  
  #----------------------------------------------
  # Variable Access
  #----------------------------------------------

  class GetVariable < Node
    def args(name)
      @name = name
    end

    attr_accessor :name
  end

  class SetVariable < Node
    def args(name, expr)
      @name, @expr = name, expr
    end

    attr_accessor :name, :expr
  end

  #
  # Local variable lookup
  #
  class LVar < GetVariable
    kind :lvar
  end

  #
  # Local variable assignment
  #
  class LAsgn < SetVariable
    kind :lasgn
  end

  #
  # Dynamic variable lookup
  #
  class DVar < GetVariable
    kind :dvar
  end
  
  #
  # Dynamic variable assignment.
  #
  # For example:
  #
  #   loop do |a|
  #     loop do |a|
  #     end
  #   end
  #
  # The first "a" will generate a DAsgnCurr, whereas the second "a" will
  # generate a DAsgn node as it uses the outer scope. 
  #
  class DAsgn < SetVariable
    kind :dasgn
  end

  #
  # Dynamic variable assignment in current scope.
  #
  # For example:
  #
  #   loop do |a|
  #     a = 1
  #   end
  #
  # generates for the block parameter "|a|":
  #
  #   [:dasgn_curr, :a],
  #
  # and for the "a = 1" assignment:
  #
  #   [:dasgn_curr, :a, [:lit, 1]]
  #
  # See also class DAsgn.
  #   
  class DAsgnCurr < SetVariable
    kind :dasgn_curr

    def args(name, expr=nil)
      super
    end
  end

  #
  # Global variable lookup
  #
  class GVar < GetVariable
    kind :gvar
  end

  #
  # Global variable assignment
  #
  class GAsgn < SetVariable
    kind :gasgn
  end

  #
  # Instance variable lookup
  #
  class IVar < GetVariable
    kind :ivar
  end

  #
  # Instance variable assignment
  #
  class IAsgn < SetVariable
    kind :iasgn
  end
 
  #----------------------------------------------
  # Control flow
  #----------------------------------------------

  class If < Node
    kind :if

    def args(cond, _then, _else)
      @condition, @then, @else = cond, _then, _else
    end

    attr_accessor :condition, :then, :else
  end

  class While < Node
    kind :while

    def args(cond, body, check_first=true)
      @condition, @body, @check_first = cond, expand_nil(body), check_first
    end

    attr_accessor :condition, :body, :check_first
  end

  class Until < Node
    kind :until

    def normalize(cond, body, check_first=true)
      While.new_with_args(@compiler, cond, body, check_first)
    end
  end

  class Block < Node
    kind :block

    def args(*statements)
      @statements = statements
    end

    attr_accessor :statements
  end

  #----------------------------------------------
  # Method
  #----------------------------------------------

  class Define < Node
    kind :defn

    def args(method_name, body)
      @method_name, @body = method_name, body
    end

    attr_accessor :method_name, :body
  end

  class Scope < Node
    kind :scope

    def args(body)
      @body = body
    end

    attr_accessor :body
  end

  class Args < Node
    kind :args

    # FIXME!!!

    def args(*arguments)
      @arguments = arguments
    end

    attr_accessor :arguments
  end

  #
  # Is produced by:
  #
  #   def m(&call)
  #   end
  #
  class BlockArg < Node
    kind :block_arg

    def args(argument_name)
      @argument_name = argument_name
    end

    attr_accessor :argument_name
  end

  #
  # Is produced by:
  #
  #   a = proc { ... }
  #
  #   [1,2,3].each(&a)
  #
  # In this example, +block+ is [:lvar, :a] and +body+ is
  # the method call [1,2,3].each.
  #
  class BlockPass < Node
    kind :block_pass

    def args(block, body)
      @block, @body = block, body
    end

    attr_accessor :block, :body
  end

  #----------------------------------------------
  # Control flow 
  #----------------------------------------------

  class Return < Node
    kind :return

    def args(argument=nil)
      @argument = argument
    end

    attr_accessor :argument
  end

  class Iter < Node
    kind :iter

    def args(method_call, block_assignment, body)
      method_call, block_assignment, body = @method_call, @block_assignment, @body
    end

    attr_accessor :method_call, :block_assignment, :body
  end

  #----------------------------------------------
  # Method calls
  #----------------------------------------------

  #
  # Method call without receiver
  #
  class FCall < Node
    kind :fcall

    def args(method_name, arguments=nil)
      @method_name, @arguments = method_name, arguments
    end

    attr_accessor :method_name, :arguments
  end

  #
  # Method call without receiver or variable access.
  #
  # This is a speciality of Ruby, and is required when the Ruby parser
  # can't determine at parse-time whether "a" is the method call "a()"
  # or a local variable.
  #
  class VCall < Node
    kind :vcall

    def args(method_or_variable_name)
      @method_or_variable_name = method_or_variable_name
    end

    attr_accessor :method_or_variable_name
  end

  #
  # Method call with receiver
  #
  class Call < Node
    kind :call

    def args(receiver, method_name, arguments=nil)
      @receiver, @method_name, @arguments = receiver, method_name, arguments
    end

    attr_accessor :receiver, :method_name, :arguments
  end

  #
  # Super call.
  #
  # Produced by:
  #
  #   super()
  #   super(1,2,3)
  #
  class Super < Node
    kind :super

    def args(arguments=nil)
      @arguments = arguments
    end

    attr_accessor :arguments
  end

  #
  # Super call, passing all arguments from the method directly to the
  # super method.
  #
  # Produced by:
  #
  #   super
  #
  class ZSuper < Node
    kind :zsuper
  end

  #
  # Attribute assignment.
  #
  # Produced by:
  #
  #   a.value = 123
  #   a.value=(123)
  #
  # Special syntax:
  #
  #   * Argument number always 1
  #   * No blocks
  #
  class AttrAssign < Node
    kind :attrasgn

    def args(receiver, method_name, argument)
      @receiver, @method_name, @argument = receiver, method_name, argument
    end

    attr_accessor :receiver, :method_name, :argument
  end

end; end # class Node; class Compiler
