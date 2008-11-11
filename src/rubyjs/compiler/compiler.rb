module RubyJS

  class Compiler
    class Error < RuntimeError; end
    
    #
    # Converts +sexp+ into a Compiler::Node.
    #
    def sexp_to_node(sexp)
      return nil if sexp.nil?

      if node_class = Node::Mapping[sexp.first]
        node_class.create(self, sexp)
      else
        raise Error, "Unable to resolve '#{sexp.first.inspect}'"
      end
    end

    def set_position(line, file)
      @line, @file = line, file
    end

    def initialize
      @state = {}
    end 

    def get(key)
      @state[key]
    end

    def set(hash, &block)
      if block
        old_state = @state.dup
        begin
          @state.update(hash)
          block.call
        ensure
          @state = old_state
        end
      else
        @state.update(hash)
      end
    end

  end # class Compiler

end # module RubyJS
