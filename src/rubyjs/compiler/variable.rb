module RubyJS; class Compiler

  class Variable
    attr_reader :name, :reads, :writes

    def initialize(name)
      @name = name.to_s
      @reads, @writes = 0, 0
    end

    def track_read
      @reads += 1
    end

    def track_write
      @writes += 1
    end

    def used?
      @reads > 0 or @writes > 0
    end
  end

  class LocalVariable < Variable
    attr_reader :scope

    def initialize(name, scope)
      super(name)
      @scope = scope
    end
  end

  class TemporaryVariable < LocalVariable; end

  class GlobalVariable < Variable; end

  class InstanceVariable < Variable; end 

end; end # class Compiler; module RubyJS
