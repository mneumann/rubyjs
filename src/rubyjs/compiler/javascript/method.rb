module RubyJS; class Compiler; class Node

  class ArgList
    def as_javascript
      raise if get(:mode) != :expression
      @elements.map {|e| e.javascript }.join(", ")
    end

    def brackets?; raise end
  end

  class MethodCall
    def as_javascript
      fmt = @receiver.brackets? ? "(%s).%s(%s)" : "%s.%s(%s)"
      #
      # TODO: encode method_name
      #
      fmt % [
        @receiver.javascript(:expression),
        @method_name.to_s,
        @arguments.javascript(:expression)
      ]
    end
  end

  class Scope
    def as_javascript
      @body.javascript
    end

    def brackets?; raise end
    def compound?; true end
  end

  class DefineMethod
    def as_javascript
      raise if get(:mode) == :expression

      args = @arguments.javascript_arglist
      opt = @arguments.javascript_optional
      "function #{@method_name}(#{args}){\n" +
        (opt ? opt + ";" : "") + @body.javascript(:last) + "}"
    end

    def brackets?; raise end
  end

  class MethodArguments
    def javascript_arglist
      args = @arguments 
      if @block and not @catch_all
        args += ["_", @block]
      end
      args.join(", ")
    end

    def javascript_optional
      return nil unless @optional

      "switch(arguments.length) {\n" + 
      @optional.statements.each_with_index.map {|opt, i|
        "case #{self.min_arity+i}: #{opt.javascript(:statement)};"
      }.join("\n") + "}\n"
    end

    def brackets?; raise end
  end

  class Return
    #
    # We don't want "return" to be generate within Node#javascript.
    #
    def compound?; true end

    def as_javascript
      # FIXME: implement as expression
      raise if get(:mode) == :expression
      "return (#{@argument.javascript(:expression)})"
    end
  end

end; end; end # class Node; class Compiler; module RubyJS
