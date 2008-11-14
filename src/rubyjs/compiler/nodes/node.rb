module RubyJS; class Compiler

  #
  # Represents an abstract syntax tree (AST) node.
  #
  class Node
    Mapping = {}

    #
    # Each Node has an associated scope which is by default the current
    # dynamic variable of compiler.get(:scope) at the time of the
    # creation of the node.
    #
    attr_accessor :scope

    #
    # Registers a sexp type, or returns the registered sexp type.
    #
    def self.kind(name=nil)
      return @kind if name.nil?
      Mapping[@kind = name] = self
    end

    #
    # Returns the registered kind of the class of object +self+.
    #
    def kind
      self.class.kind
    end

    #
    # Creates a Node for the given +compiler+ and process +sexp+.
    #
    def self.create(compiler, sexp)
      sexp.shift || raise(Compiler::Error, "no sexp type")

      node = new(compiler)
      args = node.consume(sexp)

      begin
        if node.respond_to?(:normalize)
          node = node.normalize(*args)
        else
          node.args(*args)
        end
      rescue ArgumentError => e
        arity = node.method(node.respond_to?(:normalize) ? :normalize : :args).arity
        err_msg = "%s (%s) takes %s argument(s): passed %s (%s) -- %s" % [
          kind(), self, arity , args.size, args.inspect, e.message ]
        raise ArgumentError, err_msg
      end

      return node
    end

    def self.new_with_args(compiler, *args)
      node = new(compiler)
      node.args(*args)
      return node
    end

    def compiler
      @compiler
    end

    def initialize(compiler)
      @compiler = compiler
      @scope = compiler.get(:scope)
    end

    #
    # Consumes the +sexp+ translating it into an Array suitable for
    # input to method +args+ or +normalize+.
    #
    def consume(sexp)
      out = []
      sexp.each do |s|
        if s.kind_of?(Array)
          #
          # Reject +nil+, so that we can optimize out whole expressions
          # just by returning +nil+ from sexp_to_node. 
          #
          v = @compiler.sexp_to_node(s)
          out << v unless v.nil?
        else
          out << s
        end
      end
      return out
    end

    def args
    end

    def expand_nil(obj)
      if obj.nil? then Nil.new(@compiler) else obj end
    end

    #
    # Used for accessing/propagating state within the AST
    #

    #
    # Access dynamic state variables
    #
    def get(key)
      @compiler.get(key)
    end

    #
    # Set dynamic state variables which propagate through the AST 
    #
    def set(hash, &block)
      @compiler.set(hash, &block)
    end

    #
    # Is +self+ of class +klass+? 
    #
    def is?(klass)
      self.is_a?(klass)
    end

  end # class Node

end; end # class Compiler; module RubyJS
