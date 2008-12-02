module RubyJS; class Compiler

  class LocalVariable
    def encode(encoder)
      encoder.encode_local_variable(self.name)
    end
  end

  class TemporaryVariable
    def encode(encoder)
      encoder.encode_temporary_variable(self.name)
    end
  end

  class GlobalVariable
    def encode(encoder)
      encoder.encode_global_variable(self.name)
    end
  end

  class InstanceVariable
    def encode(encoder)
      encoder.encode_instance_variable(self.name)
    end
  end

end; end # class Compiler; module RubyJS
