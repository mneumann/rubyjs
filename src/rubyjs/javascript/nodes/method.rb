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
      if @receiver.is?(Const) and @receiver.name == 'RubyJS'
        #
        # Treat a special case.
        #

        raise unless @arguments.is?(ArgList) and @arguments.elements.size == 1
        arg = @arguments.elements.first
        if arg.is?(Literal)
          value = arg.value
          raise unless value.kind_of?(Symbol)
          value = value.to_s
        elsif arg.is?(StringLiteral)
          value = arg.string
        else
          raise
        end

        # XXX encode value accordingly
        case @method_name
        when 'attr'
          value
        when 'inline'
          value
        when 'runtime'
          value
        when 'method'
          value
        else
          raise
        end

      else
        fmt = @receiver.brackets? ? "(%s).%s(%s)" : "%s.%s(%s)"
        #
        # TODO: encode method_name
        #
        fmt % [
          @receiver.javascript(:expression),
          get(:encoder).encode_method(@method_name),
          @arguments.javascript(:expression)
        ]
      end
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
        variable_declaration() + 
        (opt ? opt + ";" : "") + @body.javascript(:last) + "}"
    end

    def variable_declaration
      arr = (@scope.variables.values - @arguments.variables).map {|var|
        get(:encoder).encode_local_variable(var.name)
      }

      if arr.empty?
        ""
      else
        "var " + arr.join(',') + ";"
      end
    end

    def brackets?; raise end
  end

  class MethodArguments
    def javascript_arglist
      args = @arguments.map {|a| get(:encoder).encode_local_variable(a) }
      if @block and not @catch_all
        args += ["_", get(:encoder).encode_local_variable(@block)]
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
