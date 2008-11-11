module RubyJS

  class NameCache

    attr_reader :cache

    def initialize(name_generator)
      @name_generator = name_generator
      @cache = Hash.new
    end

    #
    # Find the generated name for +name+ or create a new one.
    #
    # For the same +name+ this method always returns the same generated
    # name.
    #
    def find_or_create(name)
      raise unless name.is_a?(String)
      @cache[name] ||= @name_generator.next
    end

    def reverse_lookup(encoded_name)
      @cache.index(encoded_name)
    end

  end # class NameCache

end # module RubyJS
