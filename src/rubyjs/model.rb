#
# Introspects the entities (classes, modules) of an application going to
# be compiled to Javascript. 
#
# Copyright (c) 2007-2009 by Michael Neumann (mneumann@ntecs.de).
#

module RubyJS

  #
  # A WorldModel is a collection of all classes and modules defined
  # within a RubyJS::Environment, i.e. all entities of an application
  # that are going to be compiled to Javascript.
  #
  # Ruby classes and modules (which we call entities) are wrapped by
  # subclasses of EntityModel (ClassModel, ModuleModel).
  #
  class WorldModel

    def initialize(namespace)
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
      @entity_model_map[entity] || EntityModel.for(entity, self)
    end

    def root_object
      namespace()::Object
    end 

    def namespace
      @namespace
    end 

    def namespace_scope_r
      /^#{namespace()}::(.*)$/
    end

    protected

    def all_entities
      seen = Hash.new
      new_entities = [namespace()]

      while entity = new_entities.shift
        next if seen.include?(entity)
        seen[entity] = true
        each_entity(entity) {|e| new_entities << e}
      end

      seen.delete(namespace())
      return seen.keys
    end

    def each_entity(under)
      under.constants.each {|const|
        value = under.const_get(const)
        yield value if value.kind_of?(::Module)
      }
    end

  end # class WorldModel


  #
  # Abstract base class for representations of Ruby classes or modules.
  #
  # The +world+ is a reference to a WorldModel which contains all
  # entities of the application that is going to be compiled.
  #
  class EntityModel

    attr_reader :world
    attr_reader :entity
    attr_reader :name, :name_pieces
    
    def self.for(entity, world=WorldModel.new)
      if entity.is_a?(::Class)
        ClassModel.new(entity, world)
      elsif entity.is_a?(::Module)
        ModuleModel.new(entity, world)
      elsif entity.nil?
        nil
      else
        raise ArgumentError
      end
    end

    def initialize(entity, world)
      raise ArgumentError unless entity.is_a?(::Class) or entity.is_a?(::Module)
      @entity = entity
      @world = world
      @world.register(entity, self)
      @name = namify(entity) 
      @name_pieces = @name.split("::")
      @methods = MethodModel.all_for(entity) 
    end

    def imethods
      @methods.select {|m| m.instance_method?}
    end

    def cmethods
      @methods.select {|m| m.class_method?}
    end

    include Comparable

    def <=>(other)
      return -1 if prefix_of(self.name_pieces, other.name_pieces)
      return 1 if prefix_of(other.name_pieces, self.name_pieces)
      return self.name <=> other.name
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
  # Class ModuleModel represents a Ruby module.
  #
  class ModuleModel < EntityModel

    attr_reader :modules

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

  end # class ModuleModel


  #
  # A ClassModel represents a Ruby class.
  #
  class ClassModel < EntityModel

    attr_reader :modules
    attr_reader :sclass, :sclasses

    def initialize(entity, world)
      raise ArgumentError unless entity.is_a?(::Class)
      super(entity, world)

      #
      # determine modules and superclass
      #

      a = entity.ancestors
      raise unless a.shift == entity
      a = a[0...(a.index(::Object))]

      #
      # "correct" the ancestor chain by inserting
      # RubyJS's root object (like Ruby's Object class).
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
      @modules = (@sclass ? a[0...(a.index(@sclass.entity))] : a).map {|e| @world.lookup(e) }
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

  end # class ClassModel

end # module RubyJS
