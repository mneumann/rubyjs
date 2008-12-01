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
        raise unless @arguments.is?(ArgList)
        if self.respond_to?("plugin_#{@method_name}")
          self.send("plugin_#{@method_name}", *@arguments.elements)
        else
          raise
        end

      else
        get(:method_scope).add_method_call(@method_name)
        fmt = @receiver.brackets? ? "(%s).%s(%s)" : "%s.%s(%s)"
        fmt % [
          @receiver.javascript(:expression),
          get(:encoder).encode_method(@method_name),
          @arguments.javascript(:expression)
        ]
      end
    end

    def plugin_attr(arg)
      raise ArgumentError unless arg.is?(SymbolLiteral)
      get(:encoder).encode_attr(arg.value.to_s)
    end

    def plugin_inline(arg)
      raise ArgumentError unless arg.is?(StringLiteral)
      arg.string
    end

    def plugin_runtime(arg)
      raise ArgumentError unless arg.is?(SymbolLiteral)
      get(:encoder).encode_runtime(arg.value.to_s)
    end

    def plugin_method(arg)
      raise ArgumentError unless arg.is?(SymbolLiteral)
      get(:encoder).encode_method(arg.value.to_s)
    end

    #
    # Checks like "arg == null ? #{nil} : #{arg}" are pretty common in
    # the core of RubyJS. This is a helper "macro" to avoid typing this
    # over and over again.
    #
    def plugin_conv2ruby(arg)
      @scope.nearest_local_scope.with_temporary_variable {|temp_var|
        tmp = get(:local_encoder).encode_temporary_variable(temp_var.name)
        js = arg.javascript(:expression)
        "(#{tmp}=(#{js}),#{tmp}==null ? #{get(:encoder).encode_nil} : #{tmp})" 
      }
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
      arr = (@scope.nearest_local_scope.variables.values - @arguments.variables).map {|var|
        get(:local_encoder).encode_local_variable(var.name)
      } 
      arr += (@scope.nearest_local_scope.temporary_variables.values).map {|var|
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

  class Super
    def as_javascript
      get(:method_scope).add_super_call
      raise
    end
  end

  class ZSuper
    def as_javascript
      get(:method_scope).add_super_call
      raise
    end
  end

  class AttrAssign
    def as_javascript
      get(:method_scope).add_method_call(@method_name)
      raise
    end
  end

  class BlockPass
    # TODO
    def as_javascript
      'TODO'
    end
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
