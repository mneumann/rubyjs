module RubyJS; module JavascriptNaming

  require 'rubyjs/naming/name_generator'
  require 'rubyjs/naming/name_cache'

  #
  # An encoder for
  #
  #   * local variables
  #   * temporary variables
  #   * attributes
  #   * methods
  #   * instance variables
  #   * RubyJS runtime functions
  #   * global variables
  #   * constants
  #   * +nil+
  #
  class NameEncoder
    def initialize
      @local_cache = new_cache()
      @attr_cache = new_cache()
      @method_cache = new_cache()
      @ivar_cache = new_cache()
      @runtime_cache = new_cache()
      @global_cache = new_cache()
      @constant_cache = new_cache()
    end

    def reset_local_cache!
      @local_cache = new_cache()
    end

    def to_yaml
      # we don't want to dump the local_cache
      old, @local_cache = @local_cache, nil
      begin
        super
      ensure
        @local_cache = old
      end
    end

    #
    # Naming for temporary variables
    #
    def encode_temporary_variable(name)
      raise ArgumentError unless name =~ /^\d+$/
      "T#{name}"
    end

    #
    # Naming for local variables
    #
    def encode_local_variable(name)
      raise ArgumentError if ('A'..'Z').include?(name.to_s[0,1])
      "_" + @local_cache.find_or_create(name.to_s)
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

    protected

    def new_cache
      NameCache.new(NameGenerator.new)
    end
  end

end; end # module JavascriptNaming; module RubyJS
