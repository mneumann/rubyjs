module RubyJS

  require 'rubyjs/javascript/naming'
  require 'rubyjs/javascript/runtime'
  require 'set'

  class Context
    attr_reader :encoder
  end

  class CodeGenerator
    def initialize(encoder)
      @encoder = encoder
      @vars = Set.new
    end

    def generate_method(meth, out="")
      @encoder.reset_local_cache!
      h = {
        :encoder => @encoder,
        :method_scope => RubyJS::Compiler::MethodScope.new 
      }
      meth.node.set(h) { out << meth.node.javascript }
      return out
    end

    def generate_runtime(out="")
      @vars << @encoder.encode_nil

      runtime = RubyJS::EntityModel.for(RubyJS::Runtime, RubyJS::WorldModel.new(RubyJS))
      runtime.imethods.sort_by{|m| m.name}.each do |meth|
        @vars << @encoder.encode_runtime(meth.name)

        # compile method
        meth.node = RubyJS::Compiler.new.sexp_to_node(meth.sexp)

        # produce output
        out << @encoder.encode_runtime(meth.name) + " = " + generate_method(meth) + ";\n"
      end
      out << @encoder.encode_runtime(:SETUP) + "();\n"
      return out
    end

    def generate_model(world, model, out="")
      c = @encoder.encode_constant(model.name)
      @vars << c

      #
      # create new class, e.g.
      #
      #   Array = Class.new(...)
      #
      #
      out << c + " = " 
      out << @encoder.encode_constant(world.lookup(RubyJS::Environment::Class).name) 
      out << "." + @encoder.encode_method("new") 
      out << "("
        sclass = (model.respond_to?(:sclass) and model.sclass) ? @encoder.encode_constant(model.sclass.name) : @encoder.encode_nil 
        classname = model.name.inspect
        oc = model.entity.const_get(:OBJECT_CONSTRUCTOR__) rescue @encoder.encode_nil
        out << [sclass, classname, oc].join(", ")
      out << ");\n"

      #
      # Add instance methods 
      #
      unless model.imethods.empty?
        out << @encoder.encode_runtime(:add_instance_methods) + "(#{c}, {\n"
        out << model.imethods.map {|meth|
          "//\n" + 
          "// #{ meth.name }\n" + 
          "//\n" +
          @encoder.encode_method(meth.name) + ": " + generate_method(meth)
        }.join(",\n\n")
        out << "\n});\n"
      end

      #
      # Add class methods 
      #
      unless model.cmethods.empty?
        out << @encoder.encode_runtime(:add_class_methods) + "(#{c}, {\n"
        out << model.cmethods.map {|meth|
          "//\n" + 
          "// #{ meth.name }\n" + 
          "//\n" +
          @encoder.encode_method(meth.name) + ": " + generate_method(meth)
        }.join(",\n\n")
        out << "\n});\n"
      end

      #
      # Add included modules
      #
      unless model.modules.empty? 
        out << @encoder.encode_runtime(:include_modules) + "(#{c}, " 
        out << "[" + model.modules.map {|mod| @encoder.encode_constant(mod.name)}.join(", ") + "]"
        out << ");\n"
      end
      return out
    end

    def generate_world(out="")
      world = RubyJS::WorldModel.new(::RubyJS::Environment)
      world.register_all_entities!

      #
      # Compile all methods
      #
      world.entity_models_sorted.each do |model|
        (model.cmethods + model.imethods).each { |meth|
          meth.node = RubyJS::Compiler.new.sexp_to_node(meth.sexp)
        }
      end 

      world.entity_models_sorted.each {|model|
        out << generate_model(world, model)
      }
      return out
    end

    def generate(js_namespace="RubyJS", out="")
      str = ""
      str << generate_runtime()
      str << generate_world()

      out << "function #{js_namespace}() {\n"
      out << "var " + @vars.to_a.join(",") + ";\n"
      out << str
      out << "\n}\n"
      return out
    end

  end # CodeGenerator

end # module RubyJS
