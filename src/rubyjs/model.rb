module RubyJS

  require 'set'
  require 'rubyjs/method_extractor'

  class MethodModel
    attr_reader :name, :sexp, :entity_model
    attr_accessor :node # the associated Compiler::Node

    def initialize(entity_model, name, sexp, is_class_method=false)
      @entity_model = entity_model
      @name, @sexp = name, sexp
      @is_class_method = is_class_method
    end

    def class_method?
      @is_class_method
    end
  end

  #
  # Class EntityModel is an abstract class that 
  # represents either a Ruby class or a module.
  #
  class EntityModel

    attr_reader :world
    attr_reader :of, :name, :name_pieces, :modules
    attr_reader :imethods, :cmethods
    
    def self.of(entity, world=WorldModel.new)
      if entity.is_a?(::Class)
        ClassModel.new(entity, world)
      elsif entity.is_a?(::Module)
        ModuleModel.new(entity, world)
      else
        return nil if entity.nil?
        raise ArgumentError
      end
    end

    def initialize(entity, world)
      raise ArgumentError unless entity.is_a?(::Class) or entity.is_a?(::Module)
      @of = entity
      @world = world
      @world.register(entity, self)
      @name = namify(entity) 
      @name_pieces = @name.split("::")

      @imethods = {}
      @cmethods = {}
      methods = MethodExtractor.extract(entity)
      methods[:instance].each {|k, v|
        @imethods[k] = MethodModel.new(self, k, v)
      }
      methods[:class].each {|k, v|
        @cmethods[k] = MethodModel.new(self, k, v, true)
      }
    end

    include Comparable

    def <=>(other)
      return -1 if prefix_of(self.name_pieces, other.name_pieces)
      return 1 if prefix_of(other.name_pieces, self.name_pieces)
      return 0
    end

    protected

    #
    # true if arr1 is prefix of arr2, otherwise false
    #
    #   prefix_of([1,2,3], [1,2]) # => false
    #   prefix_of([1,2], [1,2,3]) # => true
    #   prefix_of([1,2], [1,2])   # => false (!!!)
    #
    def prefix_of(arr1, arr2)
      return false if arr1 == arr2
      return false if arr1.size > arr2.size
      arr2[0,arr1.size] == arr1
    end

    def namify(entity)
      name = entity.name
      if name =~ @world.namespace_scope_r
        name = $1
      else
        raise "Entity #{entity} must be scoped inside #{@world.namespace_scope_r}"
      end
      return name
    end

  end # class EntityModel

  #
  # Class ClassModel represents a Ruby class.
  #
  class ClassModel < EntityModel
    attr_reader :sclass, :sclasses

    def initialize(entity, world)
      raise ArgumentError unless entity.is_a?(::Class)
      super(entity, world)

      #
      # determine modules and superclass
      #

      a = entity.ancestors
      raise unless a.first == entity
      a = a[1...(a.index(::Object))]

      #
      # "correct" the ancestor chain
      #
      a << @world.root_object if entity != @world.root_object

      #
      # determine superclasses
      #
      @sclasses = a.select {|e| e.is_a?(::Class)}.map {|e| @world.lookup(e) }
      @sclass = @sclasses.first

      #
      # Determine included modules
      #
      @modules = (@sclass ? a[0...(a.index(@sclass.of))] : a).map {|e| @world.lookup(e) }
    end

    def <=>(other)
      # modules go before classes
      return 1 if other.is_a?(ModuleModel)

      # other is a superclass of self
      return 1 if self.sclasses.include?(other)

      # self is a superclass of other
      return -1 if other.sclasses.include?(self)

      super(other)
    end

  end # ClassModel

  #
  # Class ModuleModel represents a Ruby module.
  #
  class ModuleModel < EntityModel
    def initialize(entity, world)
      raise ArgumentError unless entity.is_a?(::Module)
      super(entity, world)

      a = entity.ancestors
      raise unless a.shift == entity

      @modules = a.map {|e| @world.lookup(e)}
    end

    def <=>(other)
      # classes go after modules
      return -1 if other.is_a?(ClassModel)

      # other is included in self 
      return 1 if self.modules.include?(other)

      # self is included in other
      return -1 if other.modules.include?(self)

      super(other)
    end

  end # ModuleModel

  #
  # Class WorldModel represents ... 
  #
  class WorldModel

    def initialize(namespace=::RubyJS::Environment)
      @namespace = namespace
      @entity_model_map = {}
    end

    def entity_models_sorted
      @entity_model_map.values.sort {|a,b| a <=> b}
    end

    def register_all_entities!
      all_entities.each {|e| lookup(e) }
    end

    def register(entity, model)
      raise if @entity_model_map.include?(entity)
      @entity_model_map[entity] = model
    end

    def lookup(entity)
      @entity_model_map[entity] || EntityModel.of(entity, self)
    end

    protected

    def all_entities
      seen = Set.new
      new_entities = [namespace()]

      while entity = new_entities.shift
        next if seen.include?(entity)
        seen.add(entity)
        each_entity(entity) {|e| new_entities << e}
      end

      seen.delete(namespace())
      seen.to_a
    end

    def each_entity(under)
      under.constants.each {|const|
        value = under.const_get(const)
        yield value if value.kind_of?(::Module)
      }
    end

    public

    def root_object
      namespace()::Object
    end 

    def namespace
      @namespace
    end 

    def namespace_scope_r
      /^#{namespace()}::(.*)$/
    end

  end # WorldModel

end # module RubyJS
