module RubyJS

  require 'method_extractor'
  require 'set'

  class MethodModel
    attr_reader :name, :sexp, :entity_model

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

    protected

    def namify(entity)
      name = entity.name
      if name =~ @world.namespace_scope_r
        name = $1
      else
        raise "Entity #{entity} must be scoped inside #{@world.namespace_scope_r}"
      end
      return name
    end
  end

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
      a = a[0...(a.index(::Object))]

      s = entity.superclass
      s = nil if s == ::Object

      # remove entity from the ancestor chain
      a = a[1..-1] if a[0] == entity

      # superclasses
      @sclasses = a.select {|e| e.is_a?(::Class)}.map {|e| @world.lookup(e) }

      # a now contains the included modules
      a = a[0...(a.index(s))] if s

      if entity == @world.root_object
        raise unless s.nil?
        s = nil
      else
        s = @world.root_object if s.nil?
      end

      @sclass = @world.lookup(s)
      @modules = a.map {|e| @world.lookup(e)}
    end
  end

  #
  # Class ModuleModel represents a Ruby module.
  #
  class ModuleModel < EntityModel
    def initialize(entity, world)
      raise ArgumentError unless entity.is_a?(::Module)
      super(entity, world)

      a = entity.ancestors

      # remove entity from the ancestor chain
      a = a[1..-1] if a[0] == entity

      @modules = a.map {|e| @world.lookup(e)}
    end
  end

  #
  # Class WorldModel represents ... 
  #
  class WorldModel

    def initialize
      @entity_model_map = {}
      register_all_entities!
    end

    def entity_models_sorted
      sort_entity_models(@entity_model_map.values)
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

    def sort_entity_models(arr)
      arr.sort {|e1, e2|
        if e1.is_a?(ModuleModel) and e2.is_a?(ClassModel)
          # modules go before classes
          -1
        elsif e1.is_a?(ClassModel) and e2.is_a?(ModuleModel) 
          # classes go after modules
          1
        elsif e1.is_a?(ModuleModel) and e2.is_a?(ModuleModel)
          if e1.modules.include?(e2)
            1
          elsif e2.modules.include?(e1)
            -1
          else
            if prefix_of(e1.name_pieces, e2.name_pieces)
              -1
            elsif prefix_of(e2.name_pieces, e1.name_pieces)
              1
            else
              0
            end
          end
        elsif e1.is_a?(ClassModel) and e2.is_a?(ClassModel)
          if e1.sclasses.include?(e2)
            1
          elsif e2.sclasses.include?(e1)
            -1
          else
            if prefix_of(e1.name_pieces, e2.name_pieces)
              -1
            elsif prefix_of(e2.name_pieces, e1.name_pieces)
              1
            else
              0
            end
          end
        else
         raise
        end 
      }
    end

    #
    # true if arr1 is prefix of arr2, otherwise false
    #
    #   prefix_of([1,2,3], [1,2]) # => false
    #   prefix_of([1,2], [1,2,3]) # => true
    #
    def prefix_of(arr1, arr2)
      return false if arr1.size > arr2.size
      arr2[0,arr1.size] == arr1
    end

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
      RubyJS::Environment
    end 

    def namespace_scope_r
      /^#{namespace()}::(.*)$/
    end
  end

end # module RubyJS
