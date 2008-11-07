#
# Subclasses of Node
#

class Compiler; class Node
  
  class Newline < Node
    kind :newline

    def consume(sexp)
      @compiler.set_position(sexp[0], sexp[1])
      super(sexp)
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

    def self.test(compiler)
      nd = compiler.string_to_node(":sym")
      expect(nd.class) == self
      expect(nd.value) == :sym 
    end
  end

  class NumberLiteral < Node
    kind :fixnum

    def args(value)
      @value = value
    end

    attr_accessor :value

    def self.test(compiler)
      nd = compiler.string_to_node("1")
      expect(nd.class) == self
      expect(nd.value) == 1 
    end
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
  
  #----------------------------------------------
  # Variable Access
  #----------------------------------------------

  #
  # Local variable assignment
  #
  class LAsgn < Node
    kind :lasgn

    def args(name, expr)
      @variable = get(:scope).find_variable(name, true) || raise("Undefined variable #{name}")
      @expr = expr
    end
  end

  #
  # Local variable lookup
  #
  class LVar < Node
    kind :lvar

    def args(name)
      @variable = get(:scope).find_variable(name) || raise("Undefined variable #{name}")
    end
  end

  #
  # Global variable lookup
  #
  class GVar < Node
    kind :gvar

    def args(name)
      @name = name
    end
  end

  #
  # Global variable assignment
  #
  class GAsgn < Node
    kind :gasgn

    def args(name, expr)
      @name, @expr = name, expr
    end
  end

  #
  # Instance variable lookup
  #
  class IVar < Node
    kind :ivar

    def args(name)
      @name = name
    end
  end

  #
  # Instance variable assignment
  #
  class IAsgn < Node
    kind :iasgn

    def args(name, expr)
      @name, @expr = name, expr
    end
  end
  
  #
  # Multiple assignment
  #
  # Simple case:
  #
  # a, b = 1, 2
  #
  # [:masgn,
  #  [:array, [:lasgn, :a], [:lasgn, :b]],
  #  [:array, [:lit, 1], [:lit, 2]]]]]]
  #
  # Case with splat argument:
  #
  # a, *b = 1, 2, 3
  #
  # [:masgn,
  #  [:array, [:lasgn, :a]],
  #  [:lasgn, :b],
  #  [:array, [:lit, 1], [:lit, 2], [:lit, 3]]]]]]
  #
  # Another case:
  #
  # a, b = 1
  #
  # [:masgn,
  #  [:array, [:lasgn, :a], [:lasgn, :b]],
  #  [:to_ary, [:lit, 1]]]
  #
  class MAsgn < Node
    kind :masgn

    #
    # The last argument always contains the values.
    #
    def args(assignment, *rest)
      @values = []
      if last = rest.pop
        @values << last
      end
      @assignments = [assignment] + rest
    end

    attr_accessor :assignments, :values 
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

  class LocalVariable
    attr_reader :name, :scope

    def initialize(name, scope)
      @name, @scope = name, scope
    end
  end

  #
  # Local variable scope
  #
  class LocalScope
    attr_reader :node

    def initialize(node, enclosing_scope=nil)
      @node = node
      @enclosing_scope = enclosing_scope
      @variables = Hash.new
    end

    def find_variable(name, declare_if_not_found=false)
      name = name.to_s
      var = @variables[name] || (@enclosing_scope ? @enclosing_scope.find_variable(name) : nil)
      if declare_if_not_found and var.nil?
        declare_variable(name)
      else
        var
      end
    end

    #
    # Variables are always declared in the outer most local scope
    #
    def declare_variable(name)
      name = name.to_s
      raise if @variables[name]
      var = LocalVariable.new(name, self)
      @variables[name] = var
      return var
    end
  end

  class ClosedScope < Node
    def initialize(compiler)
      super(compiler)
      @scope = LocalScope.new(self)
    end

    def consume(sexp)
      set(:scope => @scope) do
        super(sexp)
      end
    end
  end

  class DefineMethod < ClosedScope
    kind :defn

    def args(method_name, arguments, body)
      @method_name, @arguments, @body = method_name, arguments, body
    end

    attr_accessor :method_name, :arguments, :body
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

    def args(*arguments)
      if arguments.last.is_a?(Block)
        # optional arguments assignment 
        @optional = arguments.pop
      end

      @catch_all = nil
      @block = nil
      @arguments = []

      arguments.each {|arg|
        arg = arg.to_s
        case arg[0,1]
        when '*'
          raise if @catch_all
          arg = arg[1..-1] 
          @catch_all = arg
        when '&'
          raise if @block
          arg = arg[1..-1] 
          @block = arg
        else
          @arguments << arg
        end
        get(:scope).find_variable(arg, true)
      }
    end

    def min_arity
      @arguments.size - (@optional ? @optional.statements.size : 0)
    end
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
      @method_call, @block_assignment, @body = method_call, block_assignment, body
    end

    attr_accessor :method_call, :block_assignment, :body
  end

  #
  # This node type is introduced in FCall.
  #
  class ArgList < ArrayLiteral
    kind :arglist
  end

  #----------------------------------------------
  # Method calls
  #----------------------------------------------

  class MethodCall < Node
    kind :call

    def args(receiver, method_name, arguments)
      @receiver, @method_name, @arguments = receiver, method_name, arguments
      if @receiver.nil?
        @private_call = true
        @receiver = Self.new_with_args(@compiler)
      end
    end

    attr_accessor :receiver, :method_name, :arguments
  end

  #----------------------------------------------
  # Super calls
  #----------------------------------------------

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
