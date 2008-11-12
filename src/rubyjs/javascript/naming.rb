module RubyJS; module JavascriptNaming

  require 'rubyjs/naming/name_generator'
  require 'rubyjs/naming/name_cache'

  class NameEncoder
    protected

    def new_cache
      NameCache.new(NameGenerator.new)
    end
  end

  #
  # A NameEncoder for names local to a method (i.e. local variables and
  # temporary variables).
  #
  class LocalNameEncoder < NameEncoder
    def initialize
      @local_cache = new_cache()
    end

    #
    # Naming for local variables
    #
    def encode_local_variable(name)
      raise ArgumentError if ('A'..'Z').include?(name.to_s[0,1])
      "_" + @local_cache.find_or_create(name.to_s)
    end
  end

  # 
  # A NameEncoder for names used throughout a RubyJS program.
  #
  class GlobalNameEncoder < NameEncoder

    def initialize
      @attr_cache = new_cache()
      @method_cache = new_cache()
      @ivar_cache = new_cache()
      @runtime_cache = new_cache()
      @global_cache = new_cache()
      @constant_cache = new_cache()
    end

    def encode_nil
      "nil"
    end

    #
    # Naming for Javascript attributes.
    #
    # Scope: Dot-scope
    #
    def encode_attr(name)
      "a$" + @attr_cache.find_or_create(name.to_s)
    end

    #
    # Naming for methods.
    #
    # Scope: Dot-scope
    #
    def encode_method(name)
      "m$" + @method_cache.find_or_create(name.to_s)
    end

    #
    # Naming for instance variables.
    #
    # Scope: Dot-scope
    #
    def encode_instance_variable(name)
      raise ArgumentError unless name.to_s[0,1] == '@'
      "i$" + @ivar_cache.find_or_create(name.to_s)
    end

    #
    # Naming for runtime functions.
    #
    # Scope: Global
    #
    def encode_runtime(name)
      "r$" + @runtime_cache.find_or_create(name.to_s)
    end

    #
    # Naming for global variables.
    #
    # Scope: Global
    #
    def encode_global_variable(name)
      raise ArgumentError unless name.to_s[0,1] == '$'
      "g$" + @global_cache.find_or_create(name.to_s)
    end
    
    #
    # Naming for constants.
    #
    # Scope: Global
    #
    def encode_constant(name)
      raise ArgumentError unless ('A'..'Z').include?(name.to_s[0,1])
      "c$" + @constant_cache.find_or_create(name.to_s)
    end

  end

end; end # module JavascriptNaming; module RubyJS
