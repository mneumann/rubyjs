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

        if self.respond_to?("plugin_#{@method_name}")
          self.send("plugin_#{@method_name}", value)
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

    def plugin_attr(value)
      get(:encoder).encode_attr(value)
    end

    def plugin_inline(value)
      value
    end

    def plugin_runtime(value)
      get(:encoder).encode_runtime(value)
    end

    def plugin_method(value)
      get(:encoder).encode_method(value)
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

      #
      # We have to generate the body before generating
      # the variable declarations, as within the body temporary
      # variables might be allocated.
      #
      body = @body.javascript(:last)

      "function(#{args}){\n" +
        variable_declaration() + 
        (opt ? opt + ";" : "") + body + "}"
    end

    def variable_declaration
      arr = (@scope.variables.values - @arguments.variables).map {|var|
        get(:local_encoder).encode_local_variable(var.name)
      } 
      arr += (@scope.temporary_variables.values).map {|var|
        get(:local_encoder).encode_temporary_variable(var.name)
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
      args = @arguments.map {|var| get(:local_encoder).encode_local_variable(var.name) }
      if @block and not @catch_all
        args += ["_", get(:local_encoder).encode_local_variable(@block.name)]
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
