module RubyJS; class Compiler; class Node

  class Scope < Node
    kind :scope

    def args(body)
      @body = body
    end

    attr_accessor :body
  end

  class DefineMethod < Node
    kind :defn

    def initialize(compiler)
      super(compiler)
      @scope = LocalScope.new(self)
      @method_scope = MethodScope.new
    end

    def consume(sexp)
      set(:scope => @scope, :method_scope => @method_scope) do
        super(sexp)
      end
    end

    def args(method_name, arguments, body)
      @method_name, @arguments, @body = method_name, arguments, body
    end

    attr_reader :method_scope
    attr_accessor :method_name, :arguments, :body
  end


  #
  #
  #
  class MethodArguments < Node
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
          @catch_all = get(:scope).find_variable(arg[1..-1], true)
        when '&'
          raise if @block
          @block = get(:scope).find_variable(arg[1..-1], true)
        else
          @arguments << get(:scope).find_variable(arg, true)
        end
      }
    end

    def variables
      (@arguments + [@catch_all, @block]).compact
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
  # Method calls
  #----------------------------------------------

  class ArgList < ArrayLiteral
    kind :arglist
  end

  class MethodCall < Node
    kind :call

    def args(receiver, method_name, arguments)
      @receiver, @method_name, @arguments = receiver, method_name.to_s, arguments

      get(:method_scope).add_method_call(@method_name)

      if @receiver.nil?
        @private_call = true
        @receiver = Self.new_with_args(@compiler)
      end
    end

    attr_accessor :iter
  end

  class Return < Node
    kind :return

    def args(argument=nil)
      @argument = expand_nil(argument)
    end
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
      get(:method_scope).add_super_call
    end

    attr_accessor :arguments
  end

  #
  # Super call, passing all arguments from the method directly to the
  # super method.
  #
  # Produced by:
  #
  #   super # without parens
  #
  class ZSuper < Node
    kind :zsuper

    def args
      get(:method_scope).add_super_call
    end
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
      @receiver, @method_name, @argument = receiver, method_name.to_s, argument
      get(:method_scope).add_method_call(@method_name)
    end

    attr_accessor :receiver, :method_name, :argument
  end

end; end; end # class Node; class Compiler; module RubyJS
