module RubyJS

  #
  # Runtime support for RubyJS.
  #
  # The runtime consists of functions that cannot depend on support of 
  # the RubyJS core libraries.
  #
  # The following code is generated:
  #
  #   function RubyJS() {
  #     <% for each function of module Runtime %>
  #       <%= code of that function %> 
  #     <% end %>
  #     SETUP() # invocation of runtime function SETUP
  #   }
  #
  module Runtime

    #
    # This function is initially called to setup the runtime.
    #
    def SETUP
      `#{RubyJS.runtime :NilClass}.prototype.toString = function() { return "nil" }`
      `#{RubyJS.runtime :MetaClass}.#{RubyJS.method :name}  = function() { return "MetaClass" }`
      `#{RubyJS.runtime :MetaClass}.#{RubyJS.method :class} = function() { return this }`
      `#{nil} = new #{RubyJS.runtime :NilClass}()`
      ``
    end

    #
    # The class of +nil+
    #
    def NilClass
      ``
    end

    #
    # MetaClass, the class of +Class+
    #
    # There is only one instance of class MetaClass, and this instance is
    # created when class +Class+ is created.
    #
    def MetaClass
      `#{self}.#{RubyJS.attr :class} = #{RubyJS.runtime :MetaClass}`
      `#{self}.#{RubyJS.attr :superclass} = #{nil}`
      `#{self}.#{RubyJS.attr :classname} = "Class"`
      `#{self}.#{RubyJS.attr :object_constructor} = #{RubyJS.runtime :MetaClass}`
      self
    end

    def add_instance_methods(klass, methods)
      key = nil
     `for (#{key} in #{methods}) #{klass}.#{RubyJS.attr :object_constructor}.prototype[#{key}] = #{methods}[#{key}]`
     ``
    end

    def add_class_methods(klass, methods)
      key = nil
     `for (#{key} in #{methods}) #{klass}[#{key}] = #{methods}[#{key}]`
     `` 
    end

    def include_modules(klass, modules)
     `#{klass}.#{RubyJS.attr :modules} = ((#{klass}.#{RubyJS.attr :modules})||[]).concat(#{modules})`
     `` 
    end

    #
    # Update instance and class method table (Javascript: prototype) of +klass+.
    #
    # Ruby's method lookup order is as follows:
    #
    #   1. methods of class
    #   2. methods of included modules 
    #   3. methods of superclass
    #
    # To guarantee this method lookup order, we overwrite the prototype
    # with methods in reverse lookup order (unless an entry already
    # exists):
    #
    #   1. methods of superclass
    #   2. methods of included modules
    #
    def update_class(klass)
      key = nil 

      #
      # The object_constructor prototype of +klass+
      #
      klass_ocp = `#{klass}.#{RubyJS.attr :object_constructor}.prototype`

      #
      # The superclass of +klass+
      #
      sclass  = `#{klass}.#{RubyJS.attr :superclass}`

      #
      # Contains all the entities whose object_constructor prototypes are
      # used to "extend" the object_constructor prototype of +klass+.
      #
      extend_with = [] 

      #
      # Add first the included modules (in reverse order)
      #
     `#{extend_with} += (#{klass}.#{RubyJS.attr :modules} || []).concat().reverse()`

      #
      # Next, add the superclass
      #
     `#{extend_with}.push(#{sclass} != #{nil} ? #{sclass} : {})`

      #
      # Then, do the assignment
      #
      ocp = nil
     `for (#{i=0}; #{i} < #{extend_with}.length; ++#{i})
      {
        #{ocp} = #{extend_with}[#{i}].#{RubyJS.attr :object_constructor}.prototype; 
        for (#{key} in #{ocp})
        {
          #{klass_ocp}[#{key}] = #{klass_ocp}[#{key}] || #{ocp}[#{key}];
        }
      }`

      #
      # Furthermore, we inherit class methods from the superclass 
      #
      if sclass
       `for (#{key} in #{sclass})
        {
          #{klass}[#{key}] = #{klass}[#{key}] || #{sclass}[#{key}];
        }`
      end

      #
      # And set class for instanciated objects
      #
     `#{klass_ocp}.#{RubyJS.attr :class} = #{klass}`

     ``
    end

    #
    # A null-function
    #
    def fn_null
      ``
    end

    #
    # The identity function
    #
    def fn_id(x)
      x
    end

    #
    # +throw+ in Javascript is a statement which cannot appear inside an
    # expression. To overcome this limitation we wrap +throw+ inside a
    # function. 
    #
    def fn_throw(exception)
      `throw(#{exception})`
      ``
    end

    #
    # Implements the behaviour of Ruby's "and" operator
    #
    def ruby_and(a, b)
      `(#{a} !== #{false} && #{a} !== #{nil}) ? #{b} : #{a}`
    end

    #
    # Implements the behaviour of Ruby's "or" operator
    #
    def ruby_or(a, b)
      `(#{a} !== #{false} && #{a} !== #{nil}) ? #{a} : #{b}`
    end

    #
    # Implements a check for Ruby's sense of "true"-ness:
    #
    # true <==> (not false) and (not nil)
    #
    def ruby_true?(cond)
      `#{cond} !== #{false} && #{cond} !== #{nil}`
    end

    #
    # Implements a check for Ruby's sense of "false"-ness:
    #
    # false <==> false or nil
    #
    def ruby_false?(cond)
      `#{cond} === #{false} || #{cond} === #{nil}`
    end

    #
    # Represents a +break+ from an iterator ("non-local goto").
    #
    def IterJump(return_value, scope)
     `#{self}.#{RubyJS.attr :return_value} = #{return_value}` 
     `#{self}.#{RubyJS.attr :scope} = #{scope}` 
      self
    end

    #
    # Helper function for multiple assignment in iterator parameters.
    # 
    #   undefined -> []
    #   1         -> [1]
    #   [1]       -> [[1]]
    #   []        -> [[]]
    #   [1,2]     -> [1,2]
    # 
    def masgn_iter(a)
     `if (#{a} === undefined) return []`
     `if (#{a}.constructor !== Array || a.length < 2) return [a]`
      return a
    end

    #
    # Call the method in the super class.
    #
    # As +super+ is used quite rarely, we don't optimize for it.
    #
    # TODO: iterator no longer prefixed
    #
    def supercall(object, method, iterator, arguments)
      r = `#{object}[#{method}]` # method in current class
      c = `#{object}.#{RubyJS.attr :class}.#{RubyJS.attr :superclass}`
     `while (#{r} === #{c}.#{RubyJS.attr :object_constructor}.prototype[#{method}]) 
        #{c} = #{c}.#{RubyJS.attr :superclass}`
      return `#{c}.#{RubyJS.attr :object_constructor}.prototype[#{method}].apply(#{object}, [#{iterator}].concat(#{arguments}))`
    end

    def zsupercall(object, method, arguments)
      r = `#{object}[#{method}]` # method in current class
      c = `#{object}.#{RubyJS.attr :class}.#{RubyJS.attr :superclass}`
     `while (#{r} === #{c}.#{RubyJS.attr :object_constructor}.prototype[#{method}]) 
        #{c} = #{c}.#{RubyJS.attr :superclass}`
      return `#{c}.#{RubyJS.attr :object_constructor}.prototype[#{method}].apply(#{object}, #{arguments})`
    end

    #
    # Whether object.kind_of?(klass)
    #
=begin
    def kind_of(object, klass)
      k = `#{object}.#{RubyJS.attr :class}`
     `while (#{k} != #{nil}) {`
       `if (#{k} === #{klass}) return true`
       
        # check included modules
        m = `#{k}.#{RubyJS.attr :modules}`
        i = 0
       `for (; #{i} < #{m}.length; ++#{i}) {
          if (#{m}[#{i}] == #{klass}) return true;
        }`

        k = `#{k}.#{RubyJS.attr :superclass}`
     `}`
      return false
    end
=end

  end # module Runtime

end # module RubyJS
