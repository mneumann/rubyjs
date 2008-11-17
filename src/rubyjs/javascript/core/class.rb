class Class

  #
  # Allocates an instance of the underlying class. 
  #
  def allocate 
    `new #{self}.#{RubyJS.attr :object_constructor}()`
  end

  #
  # Creates a new instance of the underlying class and initializes it
  # with the passed values. 
  #
  def new(*args, &block)
    obj = allocate()
    obj.initialize(*args, &block)
    obj
  end

  def ===(other)
    eql?(other) or other.kind_of?(self)
  end

  def name
    `#{self}.#{RubyJS.attr :classname}`
  end

  alias inspect name

  #
  # Creates a new +Class+ object. The new class inherits from
  # +superclass+, has the name +classname+ and uses the underlying
  # Javascript <tt>object constructor</tt> (unless +nil+). If the given
  # object constructor is +nil+, a new (and unique) object constructor
  # is used instead.
  #
  def self.new(superclass, classname, object_constructor=nil)
    object_constructor ||= `function() {}`
    `new #{self}.#{RubyJS.attr :object_constructor}(#{Class}, #{superclass}, #{classname}, #{object_constructor})`
  end
end
