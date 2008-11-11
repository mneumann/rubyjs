module RubyJS

  require 'rubyjs/naming/name_generator'
  require 'rubyjs/naming/name_cache'

  class JavascriptNameEncoder

    def initialize
      @cache = NameCache.new(NameGenerator.new)
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
      "a$" + @cache.find_or_create(name.to_s)
    end

    #
    # Naming for methods.
    #
    # Scope: Dot-scope
    #
    def encode_method(name)
      "m$" + @cache.find_or_create(name.to_s)
    end

    #
    # Naming for instance variables.
    #
    # Scope: Dot-scope
    #
    def encode_instance_variable(name)
      raise ArgumentError unless name.to_s[0,1] == '@'
      "i$" + @cache.find_or_create(name.to_s)
    end

    #
    # Naming for runtime functions.
    #
    # Scope: Global
    #
    def encode_runtime(name)
      "r$" + @cache.find_or_create(name.to_s)
    end

    #
    # Naming for global variables.
    #
    # Scope: Global
    #
    def encode_global_variable(name)
      raise ArgumentError unless name.to_s[0,1] == '$'
      "g$" + @cache.find_or_create(name.to_s)
    end
    
    #
    # Naming for constants.
    #
    # Scope: Global
    #
    def encode_constant(name)
      raise ArgumentError unless ('A'..'Z').include?(name.to_s[0,1])
      "c$" + @cache.find_or_create(name.to_s)
    end
  end

end
