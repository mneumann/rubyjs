module Runtime
  INIT = <<-INIT
    var nil;
  INIT

  def SETUP() `
    #{RubyJS.runtime :NilClass}.prototype.toString = function() { return "nil" };
    #{RubyJS.runtime :MetaClass}.#{RubyJS.method :name}  = function() { return "MetaClass" }; 
    #{RubyJS.runtime :MetaClass}.#{RubyJS.method :class} = function() { return this }; 

    nil = new #{RubyJS.runtime :NilClass}();`
    ``
  end

  def NilClass
    ``
  end

  #
  # A null-function (used by HTTPRequest)
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

  def IterJump(return_value, scope)
   `#{self}.#{RubyJS.attr :return_value} = #{return_value}` 
   `#{self}.#{RubyJS.attr :scope} = #{scope}` 
    self
  end

  # TODO
  def to_splat(a)
    a
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

  def rebuild_classes(classes)
    i = 0
   `for (; #{i} < #{classes}.length; ++#{i})
      #{RubyJS.runtime :rebuild_class}(#{classes}[#{i}])` 
   ``
  end

  def define_class(definition) 
    klass = nil
    key = nil

   `#{klass} = #{definition}.#{RubyJS.attr :class} || #{
      Class.new(`#{definition}.#{RubyJS.attr :superclass}`, 
                `#{definition}.#{RubyJS.attr :classname}`, 
                `#{definition}.#{RubyJS.attr :object_constructor}`) };

    for (#{key} in #{definition}.#{RubyJS.attr :instance_methods} || {})
    {
      #{klass}.#{RubyJS.attr :object_constructor}.prototype[#{key}] = #{definition}.#{RubyJS.attr :instance_methods}[#{key}];
    }

    for (#{key} in #{definition}.#{RubyJS.attr :methods} || {})
    {
      #{klass}[#{key}] = #{definition}.#{RubyJS.attr :methods}[#{key}];
    }
    
    for (#{key} = 0; #{key} < (#{definition}.#{RubyJS.attr :modules} || []).length; ++#{key})
    {
      #{klass}.#{RubyJS.attr :modules}.push(#{definition}.#{RubyJS.attr :modules}[#{key}]);
    }`

    return klass
  end

  #
  # MetaClass describes a Class object.
  #
  def MetaClass(_class, superclass, classname, object_constructor) 
    `#{self}.#{RubyJS.attr :class}              = #{_class}` 
    `#{self}.#{RubyJS.attr :superclass}         = #{superclass}` 
    `#{self}.#{RubyJS.attr :classname}          = #{classname}` 
    `#{self}.#{RubyJS.attr :object_constructor} = #{object_constructor}` 
    `#{self}.#{RubyJS.attr :modules}            = []` 
    self
  end



=begin

function #<globalattr:rebuild_class>(c)
{
  var k,i;

  //
  // include modules
  //
  // do that before, because when assigning instance methods of 
  // the super class, a check for === undefined prevents this method 
  // from being overwritten.
  //
  for (i=0; i<c.#<attr:modules>.length; i++)
  {
    for (k in c.#<attr:modules>[i].#<attr:object_constructor>.prototype)
    {
      if (c.#<attr:object_constructor>.prototype[k]===undefined)
      {
        c.#<attr:object_constructor>.prototype[k] = c.#<attr:modules>[i].#<attr:object_constructor>.prototype[k];
      }
    }
  }

  // instance methods
  if (c.#<attr:superclass> != #<nil>)
  {
    for (k in c.#<attr:superclass>.#<attr:object_constructor>.prototype)
    {
      if (c.#<attr:object_constructor>.prototype[k]===undefined)
      {
        c.#<attr:object_constructor>.prototype[k] = c.#<attr:superclass>.#<attr:object_constructor>.prototype[k];
      }
    }
  }

  // inherit class methods from superclass
  if (c.#<attr:superclass> != #<nil>)
  {
    for (k in c.#<attr:superclass>)
    {
      if (c[k]===undefined)
      {
        c[k] = c.#<attr:superclass>[k];
      }
    }
  }

  // set class for instanciated objects
  c.#<attr:object_constructor>.prototype.#<attr:_class> = c;
}


=end
end
