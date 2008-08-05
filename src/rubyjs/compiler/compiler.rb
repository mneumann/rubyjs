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
end
